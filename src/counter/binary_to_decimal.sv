`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 17:53:04
// Design Name: 
// Module Name: binary_to_decimal
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


module binary_to_decimal(
    input [13:0] binary,
    output logic [3:0] digit0,
    output logic [3:0] digit1,
    output logic [3:0] digit2,
    output logic [3:0] digit3
    );
    
always @(*) begin
    digit0 = binary % 10;
    digit1 = (binary / 10) % 10;
    digit2 = (binary / 100) % 10;
    digit3 = (binary / 1000) % 10;
end
endmodule
