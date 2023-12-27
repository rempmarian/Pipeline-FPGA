`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The Pennsylvania State University
// Engineer: Marian Rempola
//
// Create Date: 12/02/2023 02:59:26 PM
// Design Name: Marian Rempola
// Project Name: Final Project
//////////////////////////////////////////////////////////////////////////////////

//-------------------------------------------------------------------------------------------------------------------

// ----------------NOTE----------------
// To implement stalls: we need to add MUX and check rs and rt reg: if new instruction = destReg of the previous 2 instructions
// if =, we implement a stall (don't move to next instruction, don't iterate the pc)
// if !=, proceed normally

//-------------------------------------------------------------------------------------------------------------------

module datapath (clock, pc, dinstOut, ewreg, em2reg, ewmem, ealuimm, ealuc, edestReg,eqa, eqb, eimm32, 
                mr, mqb, mdo, r, wwreg, wm2reg, wdestReg, wbr, wdo, b, mdestReg, wbData, stall);
    input wire clock; 
    output wire [31:0] pc;
    output wire [31:0] dinstOut;
    output wire ewreg;
    output wire em2reg;
    output wire ewmem;
    output wire ealuimm;
	output wire [3:0] ealuc;
	output wire [4:0] edestReg;
	output wire [31:0] eqa;
	output wire [31:0] eqb;
	output wire [31:0] eimm32;
	output wire [31:0] mr;
    output wire [31:0] mqb;
    output wire [31:0] mdo;
    output wire [31:0] r;
    output wire wwreg;
    output wire wm2reg;
    output wire [4:0] wdestReg;
    output wire [31:0] wbr;
    output wire [31:0] wdo;
	
	wire [31:0] instOut;
    wire [31:0] nextPC;
	wire wreg;
	wire m2reg;
	wire wmem;
	wire aluimm;
    wire [3:0] aluc;
    wire [4:0] destReg;
    wire [31:0] qa;
    wire [31:0] qb;
    wire [31:0] imm32;
    wire [15:0] imm;
    output wire [31:0] b;
    output wire [4:0] mdestReg;
    output wire [31:0] wbData;
    output wire [1:0] stall;
    
    //Modules
    pc pc_dp(clock, nextPC, stall, pc);
    
    stall _stall_dp(dinstOut[25:21], dinstOut[20:16], edestReg, mdestReg, stall);
    
    instructionMemory im_dp(pc, instOut);
    
    pcAdder pcAdder_dp(pc, nextPC);
    
    ifID ifID_dp(clock, stall, instOut, dinstOut);
    
    controlUnit controlUnit_dp(dinstOut[31:26], dinstOut[5:0], wreg, m2reg, wmem, aluc, aluimm, regrt);
    
    mux1 mux1_dp(dinstOut[15:11], dinstOut[20:16], regrt, destReg);
    
    regFile regFile_dp(clock, wwreg, dinstOut[25:21], dinstOut[20:16], wdestReg, wbData, qa, qb);
    
    immExtend immExtend_dp(dinstOut[15:0], imm32);
    
    dataMemory dataMemory_dp(mr, mqb, mwmem, clock, mdo);
    
    idEXE idEXE_dp(clock, wreg, m2reg, wmem, aluc, aluimm, destReg, qa, qb, imm32,
            ewreg, em2reg, ewmem, ealuc, ealuimm, edestReg, eqa, eqb, eimm32);
    
    mux2 mux2_dp(ealuimm, eqb, eimm32, b);
    
    alu alu_dp(eqa, b, ealuc, r);
    
    exeMEM exeMEM_dp(clock, ewreg, em2reg, ewmem, edestReg,r, eqb, mwreg, mm2reg, 
                mwmem, mdestReg, mr, mqb);
    
    memWB memWB_dp(clock, mwreg, mm2reg, mdestReg, mr, mdo, 
            wwreg, wm2reg, wdestReg, wbr, wdo);
   
    wbMux wbMux_dps(wbr, wdo, wm2reg, wbData);
endmodule

//-------------------------------------------------------------------------------------------------------------------

module pc(clock, nextPC, stall, pc);
    input wire clock;
    input wire [31:0] nextPC;
    input wire [1:0] stall;
    output reg [31:0] pc;
    
    //set initial pc = 100
	initial begin
	pc <= 32'd100;
	end
    
    //set pc according to stalls
	always @(posedge clock) begin   
	   if (stall == 1) begin
	       pc[31:0] = pc[31:0];
	   end
	   else begin
	       pc = nextPC;
	   end
	end 
endmodule 

//-------------------------------------------------------------------------------------------------------------------

module stall(rs, rt, edestReg, mdestReg, stall);
    input [4:0] rs;
    input [4:0] rt;
    input [4:0] edestReg;
    input [4:0] mdestReg;
    output reg [1:0] stall;
    
    initial begin
        stall = 0;
    end
    
    always @(*) begin
        if (rs == edestReg | rt == edestReg | rs == mdestReg | rt == mdestReg) 
        begin
            stall = 1;
        end
        else begin
            stall = 0;
        end
    end
endmodule

//-------------------------------------------------------------------------------------------------------------------

module instructionMemory(pc, instOut);

    input wire [31:0] pc;
    output reg [31:0] instOut;
    //internal memory of 2D reg array 
    reg [31:0] memory [0:127];

    initial begin
    //instructions for final
        //add $3, $1, $2
	   memory[100] = {
	       6'b000000,
	       5'b00001, 
	       5'b00010, 
	       5'b00011, 
	       5'b00000,
	       6'b100000
	   }; 
	   
	   //sub $4, $9, $3
	   memory[104] = {
	       6'b000000,
	       5'b01001,
	       5'b00011,
	       5'b00100,
	       5'b00000,
	       6'b100010
	   }; 
	   
	   	   
	   //or $5, $3, $9
	   memory[108] = {
	       6'b000000,
	       5'b00011,
	       5'b01001,
	       5'b00101,
	       5'b00000,
	       6'b100101
	   }; 
	   
	   //xor $6, $3, $9
	   memory[112] = {
	       6'b000000,
	       5'b00011,
	       5'b01001,
	       5'b00110,
	       5'b00000,
	       6'b100110
	   }; 
	   
	   //and $7, $3, $9
       memory[116] = {
            6'b000000, 
            5'b00011, 
            5'b01001, 
            5'b00111, 
            5'b00000, 
            6'b100100
        }; 
    end
    
    
	always @(pc) begin  
	//instOut = memory[pc]
	   instOut <= memory[pc];
	end 
	
endmodule

//-------------------------------------------------------------------------------------------------------------------

module pcAdder (pc, nextPC);

    input wire [31:0] pc;
    output reg [31:0] nextPC;

	always @(*) begin  
	   //increment nextPC by 4
	   nextPC <= pc + 4; 
	end 
endmodule

//-------------------------------------------------------------------------------------------------------------------

module ifID(clock, stall, instOut, dinstOut);
    input wire clock;
    input wire [1:0] stall;
    input wire [31:0] instOut;
    output reg [31:0] dinstOut;

    //dinstOut is set according to stalls
	always @(posedge clock) begin  
	   if (stall == 1) begin //itself to stall
	       dinstOut = dinstOut;
	   end
	   else begin
	       dinstOut = instOut;
	   end
	end 
endmodule

//-------------------------------------------------------------------------------------------------------------------

module controlUnit(op, func, wreg, m2reg, wmem, aluc, aluimm, regrt);
    input [5:0] op;
    input [5:0] func;
    output reg wreg, m2reg, wmem;
    output reg [3:0] aluc;
    output reg aluimm, regrt;   
    
    always@(*) begin
        case(op)
            6'b000000:
                case(func)
                    //add 
                    6'b100000: 
                    begin 
                        wreg = 1;
                        m2reg = 0;
                        wmem = 0;
                        aluc = 4'b0010;
                        aluimm = 0;
                        regrt = 0;       
                    end  
                    
                    //sub
                    6'b100010: 
                    begin
                        wreg = 1;
                        m2reg = 0;
                        wmem = 0;
                        aluc = 4'b0110;
                        aluimm = 0;
                        regrt = 0; 
                    end
                    
                    //or
                    6'b100101:
                    begin 
                        wreg = 1; 
                        m2reg = 0; 
                        wmem = 0; 
                        aluc = 4'b0001;
                        aluimm = 0;
                        regrt = 0;
                    end
            
                    //xor
                    6'b100110:
                    begin 
                        wreg = 1; 
                        m2reg = 0; 
                        wmem = 0; 
                        aluc = 4'b0011;
                        aluimm = 0;
                        regrt = 0;
                    end

                    //and
                    6'b100100:
                    begin
                        wreg = 1; 
                        m2reg = 0; 
                        wmem = 0; 
                        aluc = 4'b0000;
                        aluimm = 0;
                        regrt = 0;
                    end
                endcase  
            
            //lw
            6'b100011: 
            begin
                //set values of control signals for LW instruction
                wreg = 1;
                m2reg = 1;
                wmem = 0;
                aluc = 4'b0010;
                aluimm = 1;
                regrt = 1;
            end
        endcase
    end

endmodule

//******************MUX1(Reg MUX)******************

module mux1 (rd, rt, regrt, destReg);
    input [4:0] rd;
    input [4:0] rt;
    input regrt;
    output reg [4:0] destReg;
    
    always@(*) begin
        if (regrt == 1) begin
            destReg <= rt;
        end
        else begin
            destReg <= rd;
        end
    end
endmodule

//-------------------------------------------------------------------------------------------------------------------

module regFile(clock, wwreg, rs, rt, wdestReg, wbData, qa, qb);
    
    input wire clock;
    input wire wwreg;
    input [4:0] rs;
    input [4:0] rt;
    input wire [4:0] wdestReg;
    input [31:0] wbData;
    output reg [31:0] qa;
    output reg [31:0] qb;
    
    //internal register 2D
    reg [31:0] RF [31:0];
    
    initial begin
        RF[0] = 'h00000000;
        RF[1] = 'hA00000AA;
        RF[2] = 'h10000011;
        RF[3] = 'h20000022;    
        RF[4] = 'h30000033;
        RF[5] = 'h40000044;
        RF[6] = 'h50000055;
        RF[7] = 'h60000066;
        RF[8] = 'h70000077;
        RF[9] = 'h80000088;
        RF[10] = 'h90000099;
    end

    
    always @(*)
        begin
            qa = RF[rs];
            qb = RF[rt];
        end
    always @(negedge clock)
        begin
            if(wwreg == 1)
                begin
                    RF[wdestReg] = wbData;
                end
            end
endmodule

//-------------------------------------------------------------------------------------------------------------------

module immExtend(imm, imm32);
	input wire [15:0] imm;
	output reg [31:0] imm32;
	
	always @(*) begin
	   imm32 [31:0] <= {{16{imm[15]}}, imm[15:0]};
	end
endmodule

//-------------------------------------------------------------------------------------------------------------------

module dataMemory (mr, mqb, mwmem, clock, mdo);
    input wire [31:0] mr;
    input wire [31:0] mqb;
    input wire mwmem;
    input wire clock;
    output reg [31:0] mdo;
    //internal memory of 2D reg array 
    reg [31:0] mem [0:127];
    
    initial begin
        mem[0]=32'hA00000AA;
        mem[4]=32'h10000011;
        mem[8]=32'h20000022;
        mem[12]=32'h30000033;
        mem[16]=32'h40000044;
        mem[20]=32'h50000055;
        mem[24]=32'h60000066;
        mem[28]=32'h70000077;
        mem[32]=32'h80000088;
        mem[36]=32'h90000099;
        
    end
    
    always @(*) begin
        mdo = mem[mr];
    end
    
    always @(negedge clock) begin
        if (mwmem == 1) begin
            mem[mqb] = mem[mr];
        end
    end
endmodule

//-------------------------------------------------------------------------------------------------------------------

module idEXE(clock, wreg, m2reg, wmem, aluc, aluimm, destReg, qa, qb, imm32,
            ewreg, em2reg, ewmem, ealuc, ealuimm, edestReg, eqa, eqb, eimm32);
    input wire clock;
    input wire wreg;
    input wire m2reg;
    input wire wmem;
    input wire [3:0] aluc;
    input wire aluimm;
    input wire [4:0] destReg;
    input wire [31:0] qa;
    input wire [31:0] qb;
    input wire [31:0] imm32;
    output reg ewreg;
    output reg em2reg;
    output reg ewmem;
	output reg [3:0] ealuc;
	output reg ealuimm;
	output reg [4:0] edestReg;
	output reg [31:0] eqa;
	output reg [31:0] eqb;
	output reg [31:0] eimm32;

	always@(posedge clock) begin
		ewreg = wreg;
		em2reg = m2reg;
		ewmem = wmem;
		ealuc = aluc;
		ealuimm = aluimm;
		edestReg = destReg;
		eqa = qa;
		eqb = qb;
		eimm32 = imm32; 
	end

endmodule

//******************MUX2(ALU MUX)******************

module mux2(ealuimm, eqb, eimm32, b);
    input ealuimm;
    input [31:0] eqb;
    input [31:0] eimm32;
    output reg [31:0] b;
    
    always@(*) begin
        if (ealuimm == 1) begin
            b <= eimm32;
        end
        else begin
            b <= eqb;
        end
    end
endmodule

//-------------------------------------------------------------------------------------------------------------------

module alu(eqa, b, ealuc, r);
    input wire [31:0] eqa;
    input wire [31:0] b;
    input wire [3:0] ealuc;
    output reg [31:0] r;
    
    always @(*) begin
    //computation of eqa and b through ealuc op, output to r
        case (ealuc)
            4'b0010: begin
                r = eqa+b;
            end
        endcase 
    end
endmodule

//-------------------------------------------------------------------------------------------------------------------

module exeMEM(clock, ewreg, em2reg, ewmem, edestReg,r, eqb, mwreg, mm2reg, 
                mwmem, mdestReg, mr, mqb);
    input wire clock;
    input wire ewreg;
    input wire em2reg;
    input wire ewmem;
    input wire [4:0] edestReg;
    input wire [31:0] r;
    input wire [31:0] eqb;
    output reg mwreg;
    output reg mm2reg;
    output reg mwmem;
    output reg [4:0] mdestReg;
    output reg [31:0] mr;
    output reg [31:0] mqb;
    
    always @(posedge clock) begin
        mwreg = ewreg;
        mm2reg = em2reg;
        mwmem = ewmem;
        mdestReg = edestReg;
        mr = r;
        mqb = eqb;
    end
endmodule

//-------------------------------------------------------------------------------------------------------------------

module memWB(clock, mwreg, mm2reg, mdestReg, mr, mdo, 
            wwreg, wm2reg, wdestReg, wbr, wdo);
    input wire clock;
    input wire mwreg;
    input wire mm2reg;
    input [4:0] mdestReg;
    input [31:0] mr;
    input [31:0] mdo;
    output reg wwreg;
    output reg wm2reg;
    output reg [4:0] wdestReg;
    output reg [31:0] wbr;
    output reg [31:0] wdo;
    
    always @(posedge clock) begin
        wwreg = mwreg;
        wm2reg = mm2reg;
        wdestReg = mdestReg;
        wbr = mr;
        wdo = mdo;
    end
    
endmodule

//-------------------------------------------------------------------------------------------------------------------

module wbMux(wbr, wdo, wm2reg, wbData);
    input wire [31:0] wbr;
    input wire [31:0] wdo;
    input wire wm2reg;
    output reg [31:0] wbData;
   
    always @(*)
        begin
            if (wm2reg == 1) begin
                wbData <= wdo;
            end
            else if (wm2reg == 0) begin
                wbData <= wbr;
            end
        end
endmodule  
