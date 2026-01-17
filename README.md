# advent-of-hardcaml-2025
A collection of solutions to [Advent of Code](https://adventofcode.com/2025) written in HardCaml!

## [Day 01 Part 1](https://adventofcode.com/2025/day/1):
- The HW module processes amounts between 0 and 99 and a direction of left or right
- The inital amount given in the file is truncated to its last 2 digits by the test bench
- The hardware module will always increment and decrement its current position every cycle, depending on the input direction and the current position
- By doing so, the module will keep its internal position state always bounded between 0 and 255, which can be represented by 8 bits
- If the internal state ever becomes divisible by 100, then the resulting total will be incremented

# Usage
Following the installation outlined in this [Template Project](https://github.com/janestreet/hardcaml_template_project),
Change into the main directory and run
```
dune exec day01/test.exe
```
to build and get your answer
