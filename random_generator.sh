#!/bin/bash

# Random String Generator - 256 bits
# Uses /dev/urandom for cryptographically secure random data

generate_random_string() {
    # Generate 32 bytes (256 bits) of random data and convert to hexadecimal
    xxd -l 32 -p /dev/urandom | tr -d '\n'
}

# Default values
count=1
format="hex"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--number)
            count="$2"
            if ! [[ "$count" =~ ^[0-9]+$ ]] || [ "$count" -le 0 ]; then
                echo "Error: Number must be a positive integer"
                exit 1
            fi
            shift 2
            ;;
        *)
            echo "Error: Unknown option $1"
            exit 1
            ;;
    esac
done

# Check if /dev/urandom is available
if [[ ! -r /dev/urandom ]]; then
    echo "Error: /dev/urandom is not available on this system"
    exit 1
fi

# Generate random strings
for ((i=1; i<=count; i++)); do
    case $format in
        hex)
            random_string=$(xxd -l 32 -p /dev/urandom | tr -d '\n')
            echo "$random_string"
            ;;
        base64)
            random_string=$(dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 | tr -d '\n')
            echo "[$i] $random_string"
            ;;
        binary)
            echo -n "[$i] "
            xxd -l 32 -b /dev/urandom | awk '{for(i=2;i<=9;i++) printf "%s", $i}' | tr -d '\n'
            echo
            ;;
    esac
done
