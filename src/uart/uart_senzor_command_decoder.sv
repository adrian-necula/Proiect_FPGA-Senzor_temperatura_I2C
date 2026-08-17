`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 17:25:24
// Design Name: 
// Module Name: uart_senzor_command_decoder
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


module uart_senzor_command_decoder(
    input [7:0] data_in,
    output logic [2:0] command
    );
    
localparam [2:0] 
    CMD_INC = 3'd0,
    CMD_DEC = 3'd1,
    CMD_RESET = 3'd2,
    CMD_STATUS = 3'd3,
    CMD_HELP = 3'd4,
    CMD_UNKNOWN = 3'd5,
    CMD_TEMP = 3'd6;

always @(*) begin
    case (data_in)
        8'h49, 8'h69: command = CMD_INC; // I/i
        8'h44, 8'h64: command = CMD_DEC; // D/d
        8'h52, 8'h72: command = CMD_RESET; // R/r
        8'h53, 8'h73: command = CMD_STATUS; // S/s
        8'h54, 8'h74: command = CMD_TEMP; // T/t
        8'h3F: command = CMD_HELP; // ?
        default: command = CMD_UNKNOWN;
    endcase
end
    
endmodule
