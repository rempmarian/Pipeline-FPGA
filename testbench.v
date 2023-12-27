`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CMPEN331
// Engineer: Marian Rempola
// 
// Create Date: 12/02/2023 11:26:46 AM
// Design Name: Pipeline 
// Module Name: testbench-
// Project Name:  Computer Org and Design Final Lab
// Target Devices: FPGA
// 
//////////////////////////////////////////////////////////////////////////////////
 
module testbench();
    reg clock;
    wire [31:0] pc;
    wire [31:0] dinstOut;
    wire ewreg, em2reg, ewmem;
    wire [3:0] ealuc;
    wire ealuimm;
    wire [4:0] edestReg;
    wire [31:0] eqa;
    wire [31:0] eqb;
    wire [31:0] eimm32;
    wire [31:0] mr;
    wire [31:0] mqb;
    wire [31:0] mdo;
    wire [31:0] r;
    wire wwreg, wm2reg;
    wire [31:0] wbr;
    wire [31:0] wdo;
    wire [31:0] b;
    wire [4:0] mdestReg;
    wire [4:0] wdestReg;
 //additionals
    wire [31:0] wbData;
    wire [1:0] stall;
    
    datapath datapath_tb(clock, pc, dinstOut, ewreg, em2reg, ewmem, ealuimm, ealuc, edestReg,eqa, eqb, eimm32, 
                mr, mqb, mdo, r, wwreg, wm2reg, wdestReg, wbr, wdo, b, mdestReg, wbData, stall);

    initial begin
	   clock = 0;
	end
	
	always
	begin
		#100
		clock = ~clock;
	end
endmodule 
