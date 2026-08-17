`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 17:09:48
// Design Name: 
// Module Name: counter14b
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


module counter14b(
    input clk,
    input rst,
    input inc,
    input dec,
    input count_reset,
    output logic [13:0] count,
    output logic overflow,
    output logic underflow
    );
    
always @(posedge clk) begin
    if (rst) begin
        count <= '0;
        overflow <= 1'b0;
        underflow <= 1'b0;
    end
    else begin
        overflow <= 1'b0;
        underflow <= 1'b0;

        if (count_reset) begin
            count <= '0;
        end
        else if (inc && !dec) begin
            if (count == 14'h270F) begin
                count <= 14'h0000;
                overflow <= 1'b1;
            end
            else begin
                count <= count + 1'b1;
            end
        end
        else if (dec && !inc) begin
            if (count == 14'h0000) begin
                count <= 14'h270F;
                underflow <= 1'b1;
            end
            else begin
                count <= count - 1'b1;
            end
        end
    end
end

endmodule