`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 17:00:28
// Design Name: 
// Module Name: button_sync
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


module button_sync (
    input clk,
    input rst,
    input btn_in,
    output logic btn_sync
);

logic btn_meta;

always @(posedge clk) begin
    if (rst) begin
        btn_meta <= 1'b0;
        btn_sync <= 1'b0;
    end
    else begin
        btn_meta <= btn_in;
        btn_sync <= btn_meta;
    end
end

endmodule
