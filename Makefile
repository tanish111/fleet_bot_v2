
CXX = g++
CXXFLAGS = -std=c++11 -Wall

all: calculator test_calculator

calculator: calculator.cpp
	$(CXX) $(CXXFLAGS) calculator.cpp -o calculator

test_calculator: test_calculator.cpp
	$(CXX) $(CXXFLAGS) test_calculator.cpp -o test_calculator

clean:
	rm -f calculator test_calculator
