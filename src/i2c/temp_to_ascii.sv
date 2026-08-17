`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 17:31:32
// Design Name: 
// Module Name: temp_to_ascii
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


module temp_to_ascii(
    input [7:0] temp_celsius,
    input [3:0] temp_fraction,
    input negative,
    output logic [47:0] ascii_temp
);

always @(*) begin

    ascii_temp[47:40] = (temp_celsius >= 8'd100 && negative) ? 8'h2D : 8'h20;    // semn pentru temp negativa cu 3 cifre sau spatiu

    ascii_temp[39:32] = (temp_celsius >= 8'd100) ? (8'h30 + (temp_celsius / 8'd100)) : ((temp_celsius >= 8'd10 && negative) ? 8'h2D : 8'h20);   // cifra sutelor, semn sau spatiu

    ascii_temp[31:24] = (temp_celsius >= 8'd10) ? (8'h30 + ((temp_celsius / 8'd10) % 8'd10)) : (negative ? 8'h2D : 8'h20);  // cifra zecilor, semn sau spatiu

    ascii_temp[23:16] = 8'h30 + (temp_celsius % 8'd10); // cifra unitatilor

    ascii_temp[15:8] = 8'h2E; // punct zecimal

    ascii_temp[7:0] = 8'h30 + temp_fraction;    // zecimala

end

endmodule
