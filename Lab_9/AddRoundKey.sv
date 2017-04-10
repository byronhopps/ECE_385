module AddRoundKey (
     input logic [127:0] msg, key,
    output logic [127:0] out
);

assign out = msg ^ key;

endmodule
