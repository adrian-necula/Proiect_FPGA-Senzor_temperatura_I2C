`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.08.2026 15:43:31
// Design Name: 
// Module Name: test_top
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

module test_top();

logic clk;
logic rst;

wire TMP_SDA;
wire TMP_SCL;
wire [7:0] seg;
wire [7:0] an;
wire sda_bus;

initial begin
    clk = 1'b0;
    forever #5 clk = !clk;
end


initial begin
    rst <= 1'b1;

    repeat (5) begin
    @(posedge clk);
    end

    rst <= 1'b0;
end

// bus i2c pt sim
assign sda_bus = dut.sda_out & dut.dummy_sda_out;
assign TMP_SDA = sda_bus;

// rulare sim
initial begin
    #15_000_000;
    $finish;
end

// top
top dut (
    .clk(clk),
    .rst(rst),
    .TMP_SDA(TMP_SDA),
    .TMP_SCL(TMP_SCL),
    .seg(seg),
    .an(an)
);

endmodule