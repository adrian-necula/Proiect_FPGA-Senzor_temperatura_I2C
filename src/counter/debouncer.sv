`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 17:03:37
// Design Name: 
// Module Name: debouncer
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


module debouncer #(
    parameter integer MAX_COUNT = 2_000_000
)(
    input clk,
    input rst,
    input btn_in,
    output logic btn_stable
);

logic [20:0] counter;

always @(posedge clk) begin
    if (rst) begin
        counter <= 21'd0;
        btn_stable <= 1'b0;
    end
    else begin
        if (btn_in == btn_stable) begin
            counter <= 21'd0;
        end
        else begin
            if (counter == MAX_COUNT - 1) begin
                btn_stable <= btn_in;
                counter <= 21'd0;
            end
            else begin
                counter <= counter + 21'd1;
            end
        end
    end
end

endmodule
