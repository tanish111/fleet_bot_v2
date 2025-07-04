#include <iostream>
#include <string>
#include <limits>
#include <cctype>

int main() {
    double num1, num2;
    char operation;

    std::cout << "Enter first number: ";
    std::cin >> num1;
    if (std::cin.fail()) {
        std::cerr << "Error: Invalid first number.\n";
        return 1;
    }

    std::cout << "Enter second number: ";
    std::cin >> num2;
    if (std::cin.fail()) {
        std::cerr << "Error: Invalid second number.\n";
        return 1;
    }

    std::cout << "Enter operation (+, -, *, /): ";
    std::cin >> operation;

    double result;
    switch (operation) {
        case '+':
            result = num1 + num2;
            break;
        case '-':
            result = num1 - num2;
            break;
        case '*':
            result = num1 * num2;
            break;
        case '/':
            if (num2 == 0) {
                std::cerr << "Error: Division by zero is not allowed.\n";
                return 1;
            }
            result = num1 / num2;
            break;
        default:
            std::cerr << "Error: Invalid operation.\n";
            return 1;
    }

    std::cout << "Result: " << result << std::endl;

    return 0;
}
