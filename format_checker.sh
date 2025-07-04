#!/bin/bash

# Format Checker for Instruction Format
# Expected format: @<hostname>:<commit-code>:{<dependency_instruction>}$<text_instruction>$@

# Function to check if a string is a valid 256-bit hex (64 characters, only hex digits)
is_valid_256bit_hex() {
    local hex_string="$1"
    [[ ${#hex_string} -eq 64 && "$hex_string" =~ ^[a-fA-F0-9]{64}$ ]]
}

# Function to validate hostname (basic validation - not null, valid characters)
is_valid_hostname() {
    local hostname="$1"
    if [[ -z "$hostname" ]]; then
        echo "Error: Hostname cannot be null"
        return 1
    fi
    if [[ ! "$hostname" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        echo "Error: Invalid hostname format"
        return 1
    fi
}

# Function to validate dependency instructions (comma-separated 256-bit hex)
validate_dependencies() {
    local deps="$1"
    if [[ -z "$deps" ]]; then
        return 0  # Empty dependencies are allowed
    fi
    
    IFS=',' read -ra DEP_ARRAY <<< "$deps"
    for dep in "${DEP_ARRAY[@]}"; do
        dep=$(echo "$dep" | tr -d ' ')
        if ! is_valid_256bit_hex "$dep"; then
            echo "Error: Invalid dependency hex '$dep' - must be 256-bit hex (64 characters)"
            return 1
        fi
    done
}

# Function to check the complete format
check_format() {
    local input="$1"
    
    # Check if input starts with @ and ends with @
    if [[ ! "$input" =~ ^@.*@$ ]]; then
        echo "Error: Instruction must be encapsulated in @...@"
        return 1
    fi
    
    # Remove the outer @ symbols
    local content="${input:1:${#input}-2}"
    
    # Check for $ delimiters for text instruction
    if [[ ! "$content" =~ \$.*\$ ]]; then
        echo "Error: Text instruction must be encapsulated in \$...\$"
        return 1
    fi
    
    # Extract parts before the first $
    local before_text="${content%%\$*}"
    
    # Parse the before_text part: <hostname>:<commit-code>:{<dependency_instruction>}
    
    # Split by first colon to get hostname
    if [[ ! "$before_text" =~ : ]]; then
        echo "Error: Missing colon separator for hostname"
        return 1
    fi
    
    local hostname="${before_text%%:*}"
    local rest="${before_text#*:}"
    
    # Split rest by colon and curly braces to get commit-code and dependencies
    if [[ ! "$rest" =~ :\{ ]]; then
        echo "Error: Invalid format - expected :<commit-code>:{<dependencies>}"
        return 1
    fi
    
    local commit_code="${rest%%:*}"
    local deps_part="${rest#*:\{}"
    local dependencies="${deps_part%\}*}"
    
    # Validate each component
    if ! is_valid_hostname "$hostname"; then
        return 1
    fi
    
    if [[ -z "$commit_code" ]]; then
        echo "Error: Commit-code cannot be null"
        return 1
    fi
    if ! is_valid_256bit_hex "$commit_code"; then
        echo "Error: Commit-code must be 256-bit hex (64 characters)"
        return 1
    fi
    
    if ! validate_dependencies "$dependencies"; then
        return 1
    fi
    
    echo "PASSED"
    return 0
}

# Function to generate a sample valid instruction
generate_sample() {
    echo "Generating sample instruction..."
    
    # Generate random 256-bit hex strings
    commit_code=$(xxd -l 32 -p /dev/urandom | tr -d '\n')
    dep1=$(xxd -l 32 -p /dev/urandom | tr -d '\n')
    dep2=$(xxd -l 32 -p /dev/urandom | tr -d '\n')
    
    local sample="@localhost:$commit_code:{$dep1,$dep2}\$Install package and configure settings\$@"
    echo ""
    echo "Sample valid instruction:"
    echo "$sample"
    echo ""
    return 0
}

# Main script logic
if [[ $# -eq 0 ]]; then
    echo "Error: No instruction provided"
    exit 1
fi

check_format "$1"
