`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.08.2026 21:14:38
// Design Name: 
// Module Name: mux
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

module mux(
    input [3:0] digit0, digit1, digit2, digit3, digit4, digit5, digit6, digit7,
    input [2:0] sel,
    output logic [3:0] digit_out
    );
    
always @(*) begin
    case (sel)
        0 : digit_out = digit0;
        1 : digit_out = digit1;
        2 : digit_out = digit2;
        3 : digit_out = digit3;
        4 : digit_out = digit4;
        5 : digit_out = digit5;
        6 : digit_out = digit6;
        7 : digit_out = digit7;
        default : digit_out = 4'hF;
    endcase
end

endmodule
