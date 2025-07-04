#include <iostream>
#include <cassert>
#include <string>
#include <sstream>
#include <vector>
#include <fstream>

// Function to simulate running the calculator and capturing its output
std::string runCalculator(const std::string& input) {
    std::string temp_input_file = "temp_input.txt";
    std::string temp_output_file = "temp_output.txt";

    // Write input to a temporary file
    std::ofstream input_file(temp_input_file);
    input_file << input;
    input_file.close();

    // Run the calculator with input from file and redirect output to another file
    std::string command = "./calculator < " + temp_input_file + " > " + temp_output_file + " 2>&1";
    system(command.c_str());

    // Read output from the temporary file
    std::ifstream output_file(temp_output_file);
    std::stringstream buffer;
    buffer << output_file.rdbuf();
    output_file.close();

    // Clean up temporary files
    remove(temp_input_file.c_str());
    remove(temp_output_file.c_str());

    return buffer.str();
}

// Helper to trim whitespace from strings
std::string trim(const std::string& str) {
    size_t first = str.find_first_not_of(' \t\n\r');
    if (std::string::npos == first) {
        return str;
    }
    size_t last = str.find_last_not_of(' \t\n\r');
    return str.substr(first, (last - first + 1));
}

// Test cases
void testAddition() {
    std::cout << "Running testAddition..." << std::endl;
    std::string input = "5\n3\n+\n";
    std::string output = runCalculator(input);
    std::string expected_output = "Enter first number: Enter second number: Enter operation (+, -, *, /): Result: 8\n";
    assert(trim(output) == trim(expected_output));
    std::cout << "testAddition PASSED" << std::endl;
}

void testSubtraction() {
    std::cout << "Running testSubtraction..." << std::endl;
    std::string input = "10\n4\n-\n";
    std::string output = runCalculator(input);
    std::string expected_output = "Enter first number: Enter second number: Enter operation (+, -, *, /): Result: 6\n";
    assert(trim(output) == trim(expected_output));
    std::cout << "testSubtraction PASSED" << std::endl;
}

void testMultiplication() {
    std::cout << "Running testMultiplication..." << std::endl;
    std::string input = "7\n6\n*\n";
    std::string output = runCalculator(input);
    std::string expected_output = "Enter first number: Enter second number: Enter operation (+, -, *, /): Result: 42\n";
    assert(trim(output) == trim(expected_output));
    std::cout << "testMultiplication PASSED" << std::endl;
}

void testDivision() {
    std::cout << "Running testDivision..." << std::endl;
    std::string input = "20\n5\n/\n";
    std::string output = runCalculator(input);
    std::string expected_output = "Enter first number: Enter second number: Enter operation (+, -, *, /): Result: 4\n";
    assert(trim(output) == trim(expected_output));
    std::cout << "testDivision PASSED" << std::endl;
}

void testDivisionByZero() {
    std::cout << "Running testDivisionByZero..." << std::endl;
    std::string input = "10\n0\n/\n";
    std::string output = runCalculator(input);
    std::string expected_output = "Enter first number: Enter second number: Enter operation (+, -, *, /): Error: Division by zero is not allowed.\n";
    assert(trim(output) == trim(expected_output));
    std::cout << "testDivisionByZero PASSED" << std::endl;
}

void testInvalidInput() {
    std::cout << "Running testInvalidInput..." << std::endl;
    std::string input = "abc\n3\n+\n";
    std::string output = runCalculator(input);
    std::string expected_output = "Enter first number: Error: Invalid first number.\n";
    assert(trim(output) == trim(expected_output));
    std::cout << "testInvalidInput PASSED" << std::endl;
}

void testInvalidOperation() {
    std::cout << "Running testInvalidOperation..." << std::endl;
    std::string input = "5\n3\nx\n";
    std::string output = runCalculator(input);
    std::string expected_output = "Enter first number: Enter second number: Enter operation (+, -, *, /): Error: Invalid operation.\n";
    assert(trim(output) == trim(expected_output));
    std::cout << "testInvalidOperation PASSED" << std::endl;
}

int main() {
    std::cout << "Starting calculator tests..." << std::endl;

    testAddition();
    testSubtraction();
    testMultiplication();
    testDivision();
    testDivisionByZero();
    testInvalidInput();
    testInvalidOperation();

    std::cout << "All tests completed." << std::endl;
    return 0;
}