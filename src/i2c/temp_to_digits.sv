`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.08.2026 18:46:21
// Design Name: 
// Module Name: temp_to_digits
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

module temp_to_digits(
    input [7:0] temp_celsius,
    input [3:0] temp_fraction,
    output reg [3:0] digit0,
    output reg [3:0] digit1,
    output reg [3:0] digit2,
    output reg [3:0] digit3
);

always @(*) begin
    if (temp_celsius >= 10)
        digit3 = (temp_celsius / 10) % 10;
    else
        digit3 = 4'hF;     // blank
    
    digit2 = temp_celsius % 10;
    digit1 = temp_fraction;
    digit0 = 4'hA;         // grad
end

endmodule
