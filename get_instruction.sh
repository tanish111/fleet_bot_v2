#!/bin/bash

# Instruction Extractor Script
# Usage: ./get_instruction <hostname> <n>
# Extracts the nth instruction for the given hostname from instructions.txt

# Function to parse a single instruction (handles multi-line format)
parse_instruction() {
    local input="$1"
    
    # Check if input starts with @ and ends with @
    if [[ ! "$input" =~ ^@.*@$ ]]; then
        echo "Error: Invalid format - instruction must be encapsulated in @...@"
        return 1
    fi
    
    # Split the input into lines
    local lines
    IFS=$'\n' read -rd '' -a lines <<< "$input"
    
    # First line should be the header: @hostname:commit-code:{deps}
    local header_line="${lines[0]}"
    
    # Extract hostname, commit-code, and dependencies from header
    if [[ ! "$header_line" =~ ^@([^:]+):([^:]+):\{([^}]*)\}$ ]]; then
        echo "Error: Invalid header format - expected @hostname:commit-code:{deps}"
        return 1
    fi
    
    local hostname="${BASH_REMATCH[1]}"
    local commit_code="${BASH_REMATCH[2]}"
    local dependencies="${BASH_REMATCH[3]}"
    
    # Find the text instruction (lines that start with $)
    local text_instruction=""
    local found_text=false
    
    for line in "${lines[@]}"; do
        if [[ "$line" =~ ^\$(.*)$ ]]; then
            if [[ $found_text == true ]]; then
                text_instruction="${text_instruction} ${BASH_REMATCH[1]}"
            else
                text_instruction="${BASH_REMATCH[1]}"
                found_text=true
            fi
        fi
    done
    
    # Remove trailing "@" if present
    text_instruction="${text_instruction%@}"
    
    if [[ $found_text == false ]]; then
        echo "Error: No text instruction found (should start with $)"
        return 1
    fi
    
    # Output parsed components
    echo "=== INSTRUCTION #$current_instruction_num ==="
    echo "Hostname: $hostname"
    echo "Commit Code: $commit_code"
    echo "Dependencies: $dependencies"
    echo "Text Instruction: $text_instruction"
    echo "===================================="
    
    return 0
}

# Function to extract instructions for a specific hostname
extract_instructions_for_hostname() {
    local target_hostname="$1"
    local instructions_file="$2"
    
    if [[ ! -f "$instructions_file" ]]; then
        echo "Error: Instructions file '$instructions_file' not found"
        return 1
    fi
    
    local instructions=()
    local current_instruction=""
    local in_instruction=false
    
    # Read the file line by line
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Check if line starts with @ but is not just @
        if [[ "$line" =~ ^@[^@]*$ ]] && [[ "$line" != "@" ]]; then
            # This is the start of an instruction
            in_instruction=true
            current_instruction="$line"
        elif [[ "$line" == "@" ]]; then
            # This is the end of an instruction
            if [[ $in_instruction == true ]]; then
                current_instruction="${current_instruction}@"
                
                # Check if this instruction is for our target hostname
                local inst_hostname=""
                # Extract hostname from the first line of the instruction
                local first_line="${current_instruction%%$'\n'*}"
                if [[ "$first_line" =~ ^@([^:]+): ]]; then
                    inst_hostname="${BASH_REMATCH[1]}"
                fi
                
                if [[ "$inst_hostname" == "$target_hostname" ]]; then
                    instructions+=("$current_instruction")
                fi
                
                current_instruction=""
                in_instruction=false
            fi
        elif [[ $in_instruction == true ]] && [[ -n "$line" ]]; then
            # This is a continuation of the current instruction
            current_instruction="${current_instruction}"$'\n'"$line"
        fi
    done < "$instructions_file"
    
    # Return the instructions array (store in global variable)
    host_instructions=("${instructions[@]}")
}

# Function to display help
show_help() {
    echo "Usage: $0 <hostname> <n> [options]"
    echo ""
    echo "Arguments:"
    echo "  hostname    The hostname to filter instructions for"
    echo "  n          The instruction number to retrieve (1-indexed)"
    echo ""
    echo "Options:"
    echo "  -f, --file FILE    Path to instructions file (default: demo_appliation/instructions.txt)"
    echo "  -l, --list         List all instructions for the hostname"
    echo "  -c, --count        Show count of instructions for the hostname"
    echo "  -r, --raw          Output raw instruction without parsing"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 agent1 1                    # Get first instruction for agent1"
    echo "  $0 agent1 2 --raw             # Get second instruction raw format"
    echo "  $0 agent1 --list              # List all instructions for agent1"
    echo "  $0 agent1 --count             # Count instructions for agent1"
}

# Parse command line arguments
hostname=""
instruction_num=""
instructions_file="instructions.txt"
list_mode=false
count_mode=false
raw_mode=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--file)
            instructions_file="$2"
            shift 2
            ;;
        -l|--list)
            list_mode=true
            shift
            ;;
        -c|--count)
            count_mode=true
            shift
            ;;
        -r|--raw)
            raw_mode=true
            shift
            ;;
        -*)
            echo "Error: Unknown option $1"
            show_help
            exit 1
            ;;
        *)
            if [[ -z "$hostname" ]]; then
                hostname="$1"
            elif [[ -z "$instruction_num" ]]; then
                instruction_num="$1"
            else
                echo "Error: Too many arguments"
                show_help
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate required arguments
if [[ -z "$hostname" ]]; then
    echo "Error: Hostname is required"
    show_help
    exit 1
fi

if [[ $list_mode == false && $count_mode == false && -z "$instruction_num" ]]; then
    echo "Error: Instruction number is required (or use --list/--count)"
    show_help
    exit 1
fi

# Validate instruction number if provided
if [[ -n "$instruction_num" ]]; then
    if ! [[ "$instruction_num" =~ ^[0-9]+$ ]] || [[ "$instruction_num" -le 0 ]]; then
        echo "Error: Instruction number must be a positive integer"
        exit 1
    fi
fi

# Extract instructions for the hostname
declare -a host_instructions
extract_instructions_for_hostname "$hostname" "$instructions_file"

# Handle different modes
if [[ $count_mode == true ]]; then
    echo "Instructions for hostname '$hostname': ${#host_instructions[@]}"
    exit 0
fi

if [[ $list_mode == true ]]; then
    if [[ ${#host_instructions[@]} -eq 0 ]]; then
        echo "No instructions found for hostname '$hostname'"
        exit 1
    fi
    
    echo "All instructions for hostname '$hostname':"
    echo "================================================"
    for i in "${!host_instructions[@]}"; do
        echo ""
        current_instruction_num=$((i + 1))
        if [[ $raw_mode == true ]]; then
            echo "=== INSTRUCTION #$current_instruction_num (RAW) ==="
            echo "${host_instructions[i]}"
        else
            parse_instruction "${host_instructions[i]}"
        fi
    done
    exit 0
fi

# Get specific instruction number
if [[ $instruction_num -gt ${#host_instructions[@]} ]]; then
    echo "Error: Instruction number $instruction_num not found. Only ${#host_instructions[@]} instructions available for hostname '$hostname'"
    exit 1
fi

if [[ ${#host_instructions[@]} -eq 0 ]]; then
    echo "Error: No instructions found for hostname '$hostname'"
    exit 1
fi

# Get the nth instruction (convert to 0-indexed)
target_instruction="${host_instructions[$((instruction_num - 1))]}"
current_instruction_num="$instruction_num"

echo "Retrieving instruction #$instruction_num for hostname '$hostname':"
echo ""

if [[ $raw_mode == true ]]; then
    echo "=== RAW INSTRUCTION ==="
    echo "$target_instruction"
else
    parse_instruction "$target_instruction"
fi 