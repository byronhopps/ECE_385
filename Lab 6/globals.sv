// Values for the PCMUX selection bits
package PCMUX;
    parameter PC_PLUS1 = 2'b00;
    parameter ADDR_SUM = 2'b01;
    parameter DATA_BUS = 2'b10;
endpackage

package ADDR1MUX;
    parameter SR1 = 1'b0;
    parameter PC  = 1'b1;
endpackage

package ADDR2MUX;
    parameter ZERO  = 2'b00;
    parameter IR_5  = 2'b01;
    parameter IR_8  = 2'b10;
    parameter IR_10 = 2'b11;
endpackage

package SR1MUX;
    parameter IR_8_6  = 1'b0;
    parameter IR_11_9 = 1'b1;
endpackage

package SR2MUX;
    parameter SR2_OUT = 1'b0;
    parameter IR_SEXT = 1'b1;
endpackage

package DRMUX;
    parameter IR_11_9 = 1'b0;
    parameter ONES    = 1'b1;
endpackage

package ALU_OPS;
    parameter ADD = 2'b00;
    parameter AND = 2'b01;
    parameter NOT = 2'b10;
endpackage
