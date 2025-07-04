#include <iostream>
#include <string>
#include <cstdlib>
#include <unistd.h>
#include <fstream>
#include <sstream>
#include <thread>
#include <chrono>

class InstructionManager {
private:
    std::string hostname;
    int counter;
    
    // Get hostname of the machine
    std::string getHostname() {
        char hostname_buffer[256];
        if (gethostname(hostname_buffer, sizeof(hostname_buffer)) == 0) {
            return std::string(hostname_buffer);
        }
        return "unknown-host";
    }
    
    // Execute shell command and return output
    std::string executeCommand(const std::string& command) {
        std::string result;
        FILE* pipe = popen(command.c_str(), "r");
        if (!pipe) {
            std::cerr << "Error: Failed to execute command: " << command << std::endl;
            return "";
        }
        
        char buffer[128];
        while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
            result += buffer;
        }
        
        int status = pclose(pipe);
        if (status != 0) {
            std::cerr << "Command failed with status: " << status << std::endl;
        }
        
        return result;
    }
    
    // Check if output contains error
    bool hasError(const std::string& output) {
        return output.find("Error:") != std::string::npos;
    }
    
    // Execute gemini command with given prompt
    void executeGeminiCommand(const std::string& prompt) {
        std::string command = "echo '\"Implementation MODE:- Read GEMINI.md " + prompt + "\"' | gemini -y -c --model gemini-2.5-flash";
        std::cout << "Executing Gemini command..." << std::endl;
        std::string result = executeCommand(command);
        std::cout << "Gemini result: " << result << std::endl;
    }
    
    // The fallback prompt for when get_instructions fails
    std::string getFallbackPrompt() {
        return "Creation MODE:- Read GEMINI.md use git log and memory tool to get all the task done then use sequentialthinking to make a plan for finding new instructions using this and then search on google for new improvements which are not yet implemented in git log atleast 5-10 new instructions which are not conflicting and there dependents should also be propoetly initiallyized so mostly no on needs to wait and check git log and instuctions.txt for old instructions and then use ./random_generator.sh to generate commit id's by ./random_generator.sh -n <no. of inst> and in proper format apeend in instructions.txt it should be assigne in equally to all contributos use instructions.txt to get hostname of all contributors then check each individual instruction using ./format_checker.sh and push it propertly to main repo";
    }

public:
    InstructionManager() : counter(1) {
        hostname = getHostname();
        std::cout << "Initialized InstructionManager for hostname: " << hostname << std::endl;
    }
    
    void run() {
        std::cout << "Starting instruction management loop..." << std::endl;
        
        while (true) {
            std::cout << "\n=== Iteration " << counter << " ===" << std::endl;
            
            // Build get_instructions command
            std::string getInstructionsCmd = "./get_instruction.sh " + hostname + " " + std::to_string(counter);
            std::cout << "Executing: " << getInstructionsCmd << std::endl;
            
            // Execute get_instructions command
            std::string instructionOutput = executeCommand(getInstructionsCmd);
            
            if (hasError(instructionOutput)) {
                std::cout << "get_instructions returned error, using fallback prompt..." << std::endl;
                executeGeminiCommand(getFallbackPrompt());
            } else {
                std::cout << "Successfully retrieved instruction, sending to Gemini..." << std::endl;
                // Remove newlines and escape quotes for command line
                std::string cleanOutput = instructionOutput;
                // Replace quotes with escaped quotes
                size_t pos = 0;
                while ((pos = cleanOutput.find("\"", pos)) != std::string::npos) {
                    cleanOutput.replace(pos, 1, "\\\"");
                    pos += 2;
                }
                executeGeminiCommand(cleanOutput);
            }
            
            // Increment counter for next iteration
            counter++;
            
            // Wait before next iteration (to avoid overwhelming the system)
            std::cout << "Waiting 5 seconds before next iteration..." << std::endl;
            std::this_thread::sleep_for(std::chrono::seconds(5));
        }
    }
    
    // Method to run a single iteration (for testing)
    void runOnce() {
        std::cout << "Running single iteration..." << std::endl;
        
        std::string getInstructionsCmd = "./get_instruction.sh " + hostname + " " + std::to_string(counter);
        std::cout << "Executing: " << getInstructionsCmd << std::endl;
        
        std::string instructionOutput = executeCommand(getInstructionsCmd);
        
        if (hasError(instructionOutput)) {
            std::cout << "get_instructions returned error, using fallback prompt..." << std::endl;
            executeGeminiCommand(getFallbackPrompt());
        } else {
            std::cout << "Successfully retrieved instruction, sending to Gemini..." << std::endl;
            std::string cleanOutput = instructionOutput;
            size_t pos = 0;
            while ((pos = cleanOutput.find("\"", pos)) != std::string::npos) {
                cleanOutput.replace(pos, 1, "\\\"");
                pos += 2;
            }
            executeGeminiCommand(cleanOutput);
        }
        
        counter++;
        
        // Wait for 10 seconds before finishing
        std::cout << "Waiting 10 seconds before finishing..." << std::endl;
        std::this_thread::sleep_for(std::chrono::seconds(10));
    }
};

void printUsage(const char* programName) {
    std::cout << "Usage: " << programName << " [options]" << std::endl;
    std::cout << "Options:" << std::endl;
    std::cout << "  --once    Run only one iteration instead of infinite loop" << std::endl;
    std::cout << "  --help    Show this help message" << std::endl;
}

int main(int argc, char* argv[]) {
    bool runOnce = false;
    
    // Parse command line arguments
    for (int i = 1; i < argc; i++) {
        std::string arg = argv[i];
        if (arg == "--once") {
            runOnce = true;
        } else if (arg == "--help") {
            printUsage(argv[0]);
            return 0;
        } else {
            std::cerr << "Unknown option: " << arg << std::endl;
            printUsage(argv[0]);
            return 1;
        }
    }
    
    try {
        InstructionManager manager;
        
        if (runOnce) {
            manager.runOnce();
        } else {
            manager.run();
        }
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}
