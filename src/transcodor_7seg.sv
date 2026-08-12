`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.08.2026 00:50:56
// Design Name: 
// Module Name: transcodor_7seg
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

module transcodor_7seg(
    input [3:0] digit,
    input decimal_point,
    output reg [7:0] seg
);

always @(*) begin

    case (digit)
        4'd0: seg = 8'b00000011;
        4'd1: seg = 8'b10011111;
        4'd2: seg = 8'b00100101;
        4'd3: seg = 8'b00001101;
        4'd4: seg = 8'b10011001;
        4'd5: seg = 8'b01001001;
        4'd6: seg = 8'b01000001;
        4'd7: seg = 8'b00011111;
        4'd8: seg = 8'b00000001;
        4'd9: seg = 8'b00001001;

        4'hA: seg = 8'b00111001;   // grad
        4'hF: seg = 8'b11111111;   // blank

        default: seg = 8'b11111111;

    endcase

    if (decimal_point) begin
        seg[0] = 1'b0;
    end

end

endmodule