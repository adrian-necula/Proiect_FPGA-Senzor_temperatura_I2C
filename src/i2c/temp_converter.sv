`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.08.2026 17:52:56
// Design Name: 
// Module Name: temp_converter
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

module temp_converter (
    input [15:0] temperature_raw,
    output logic [7:0] temp_celsius,
    output logic [3:0] temp_fraction,
    output logic negative
);

integer temp_value;

always @(*) begin
    temp_value = ($signed(temperature_raw[15:3]) * 10) / 16;
    if (temp_value < 0) begin
        negative = 1'b1;
        temp_value = -temp_value;
    end
    else begin
        negative = 1'b0;
    end
    temp_celsius = temp_value / 10;
    temp_fraction = temp_value % 10;
end

endmodule
