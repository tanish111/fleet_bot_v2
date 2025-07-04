#!/bin/bash

# Instruction Extractor Script
# Usage: ./get_instruction <hostname> <n>
# Extracts the nth instruction for the given hostname from instructions.txt

# Function to parse a single instruction (handles single-line format)
parse_instruction() {
    local input="$1"
    
    # Check if input starts with @ and ends with @
    if [[ ! "$input" =~ ^@.*@$ ]]; then
        echo "Error: Invalid format - instruction must be encapsulated in @...@"
        return 1
    fi
    
    # Remove the outer @ symbols
    local content="${input:1:${#input}-2}"
    
    # Split by $ to get header and text instruction
    if [[ ! "$content" =~ \$.*\$ ]]; then
        echo "Error: Invalid format - missing text instruction delimiters"
        return 1
    fi
    
    # Extract header (before first $)
    local header="${content%%\$*}"
    
    # Extract text instruction (between $ symbols)
    local temp="${content#*\$}"
    local text_instruction="${temp%\$*}"
    
    # Parse header: hostname:commit-code:{deps}
    if [[ ! "$header" =~ ^([^:]+):([^:]+):\{([^}]*)\}$ ]]; then
        echo "Error: Invalid header format - expected hostname:commit-code:{deps}"
        return 1
    fi
    
    local hostname="${BASH_REMATCH[1]}"
    local commit_code="${BASH_REMATCH[2]}"
    local dependencies="${BASH_REMATCH[3]}"
    
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
    
    # Read the file line by line
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Check if this is a complete single-line instruction
        if [[ "$line" =~ ^@.*@$ ]]; then
            # Extract hostname from the instruction
            if [[ "$line" =~ ^@([^:]+): ]]; then
                local inst_hostname="${BASH_REMATCH[1]}"
                if [[ "$inst_hostname" == "$target_hostname" ]]; then
                    instructions+=("$line")
                fi
            fi
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
    echo "  -f, --file FILE    Path to instructions file (default: instructions.txt)"
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