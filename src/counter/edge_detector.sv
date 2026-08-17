`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 17:04:58
// Design Name: 
// Module Name: edge_detector
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


module edge_detector (
    input logic clk,
    input logic rst,
    input logic signal_in,
    output logic pulse_out
);

logic signal_old;

always @(posedge clk) begin
    if (rst) begin
        signal_old <= 1'b0;
        pulse_out <= 1'b0;
    end
    else begin
        pulse_out <= signal_in && !signal_old;
        signal_old <= signal_in;
    end
end

endmodule