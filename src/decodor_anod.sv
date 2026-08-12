`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.08.2026 00:54:05
// Design Name: 
// Module Name: decodor_anod
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module decodor_anod(
    input [2:0] sel,
    output reg [7:0] an
);

always @(*) begin

    case (sel)
        3'd0: an = 8'b11111110;
        3'd1: an = 8'b11111101;
        3'd2: an = 8'b11111011;
        3'd3: an = 8'b11110111;
        3'd4: an = 8'b11101111;
        3'd5: an = 8'b11011111;
        3'd6: an = 8'b10111111;
        3'd7: an = 8'b01111111;

        default: an = 8'b11111111;

    endcase

end

endmodule