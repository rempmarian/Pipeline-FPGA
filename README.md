# Pipeline-FPGA
# Author: Marian Rempola
# Date: December, 2023

# Abstract 
This project is a model of a Pipeline FPGA Lab with the addition of stalls in order to prevent data hazards. In this lab, I added a stall module to check if the new instruction, specifically rs and rt operand registers, are equivalent to the destination register of the previous two instructions. Since this would create a data hazard, in the stall module, we would assign a 1 to stall in order to indicate the corresponding modules to stall the instruction instead of moving on to the next instruction (this is forwarded to the IFID and the PC modules). In the pc module (program counter), we ensure that if stall is on, we don’t proceed to the next instruction. Similarly, in the IFID phase module, we will not consider the next instruction if there is a stall. 

# Introduction
The architecture of the FPGA  pipeline with stalls is provided in the project description. The architecture consists of the stages IF, ID, EXE, MEM, and WB stages; namely, the instruction fetch, instruction decode, execution, memory access, and write back stages respectively. There are two multiplexers (MUXs) between each stage to connect the outputs of the previous stage to the next stage. Doing so allows multiple stages to perform, namely, it allows pipelining. 
 
