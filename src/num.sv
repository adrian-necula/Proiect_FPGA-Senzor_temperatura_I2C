`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.08.2026 21:12:00
// Design Name: 
// Module Name: num
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

module num(
    input rst,
    input clk,
    output logic [19:0] count
    );
    
always @(posedge clk) begin
    if (rst) begin
        count <= 20'd0;
    end
    else begin
        count <= count + 20'd1;
    end
end

endmodule