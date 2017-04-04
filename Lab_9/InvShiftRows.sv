module InvShiftRows (
    input  logic [127:0] in,
    output logic [127:0] out
);

assign out[127:120] = in[127:120]; // Output byte 15
assign out[119:112] = in[ 23: 16]; // Output byte 14
assign out[111:104] = in[ 47: 40]; // Output byte 13
assign out[103: 96] = in[ 71: 64]; // Output byte 12
assign out[ 95: 88] = in[ 95: 88]; // Output byte 11
assign out[ 87: 80] = in[119:112]; // Output byte 10
assign out[ 79: 72] = in[ 15:  8]; // Output byte 9
assign out[ 71: 64] = in[ 39: 32]; // Output byte 8
assign out[ 63: 56] = in[ 63: 56]; // Output byte 7
assign out[ 55: 48] = in[ 87: 80]; // Output byte 6
assign out[ 47: 40] = in[111:104]; // Output byte 5
assign out[ 39: 32] = in[  7:  0]; // Output byte 4
assign out[ 31: 24] = in[ 31: 24]; // Output byte 3
assign out[ 23: 16] = in[ 55: 48]; // Output byte 2
assign out[ 15:  8] = in[ 79: 72]; // Output byte 1
assign out[  7:  0] = in[103: 96]; // Output byte 0

endmodule
