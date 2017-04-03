module aesTestbench ();

timeunit 10ns;
timeprecision 1ns;

// Internal logic signals
logic clk, reset_n, run;
//logic [31:0] key_0, key_1, key_2, key_3;
logic [127:0] msg_en, msg_de, key;
//logic [127:0] key_in, msg_in;
logic ready;

// Instantiate the AES module to be tested
AES AES_module (.*);

//transpose keyTranspose (.in(key_in), .out(key));
//transpose msgTranspose (.in(msg_in), .out(msg_en));

// Test program
initial begin : TEST_PROGRAM
    reset_n = 0;
    run = 0;
    key    = 128'h000102030405060708090a0b0c0d0e0f;
    msg_en = 128'hDAEC3055DF058E1C39E814EA76F6747E;

    #4 reset_n = 1;
    #4 run = 1;
    #4 run = 0;
end

// Clock generation and initialization
always begin : CLOCK_GENERATION
    #1 clk = ~clk;
end

initial begin : CLOCK_INITIALIZATION
    clk = 0;
end

endmodule

// Transpose a byte array from column-major order
//   to row-major order or vice-versa
module transpose (
    input  logic [127:0] in,
    output logic [127:0] out
);

assign out[  7:  0] = in[  7:  0]; // Output byte 0
assign out[ 15:  8] = in[ 39: 32]; // Output byte 1
assign out[ 23: 16] = in[ 71: 64]; // Output byte 2
assign out[ 31: 24] = in[103: 96]; // Output byte 3
assign out[ 39: 32] = in[ 15:  8]; // Output byte 4
assign out[ 47: 40] = in[ 47: 40]; // Output byte 5
assign out[ 55: 48] = in[ 79: 72]; // Output byte 6
assign out[ 63: 56] = in[111:104]; // Output byte 7
assign out[ 71: 64] = in[ 23: 16]; // Output byte 8
assign out[ 79: 72] = in[ 55: 48]; // Output byte 9
assign out[ 87: 80] = in[ 87: 80]; // Output byte 10
assign out[ 95: 88] = in[119:112]; // Output byte 11
assign out[103: 96] = in[ 31: 24]; // Output byte 12
assign out[111:104] = in[ 63: 56]; // Output byte 13
assign out[119:112] = in[ 95: 88]; // Output byte 14
assign out[127:120] = in[127:120]; // Output byte 15

endmodule
