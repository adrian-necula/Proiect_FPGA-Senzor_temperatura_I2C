`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 23:54:04
// Design Name: 
// Module Name: uart_senzor_command_control
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


module uart_senzor_command_control (
    input clk,
    input rst,
    input [2:0] command,
    input [7:0] rx_fifo_data,
    input rx_fifo_empty,
    input [13:0] count,
    input btn_inc_pulse,
    input btn_dec_pulse,
    input btn_reset_pulse,
    input message_done,
    output logic rx_fifo_rd_en,
    output logic inc,
    output logic dec,
    output logic count_reset,
    output logic message_start,
    output logic [3:0] message_code,
    output logic [7:0] unknown_char
);

localparam [2:0]
    CMD_INC = 3'd0,
    CMD_DEC = 3'd1,
    CMD_RESET = 3'd2,
    CMD_STATUS = 3'd3,
    CMD_HELP = 3'd4,
    CMD_UNKNOWN = 3'd5,
    CMD_TEMP = 3'd6;

localparam [3:0]
    MSG_INC = 4'd0,
    MSG_DEC = 4'd1,
    MSG_RESET = 4'd2,
    MSG_STATUS = 4'd3,
    MSG_HELP = 4'd4,
    MSG_UNKNOWN = 4'd5,
    MSG_OVERFLOW = 4'd6,
    MSG_UNDERFLOW = 4'd7,
    MSG_BTN_INC = 4'd8,
    MSG_BTN_DEC = 4'd9,
    MSG_BTN_RESET = 4'd10,
    MSG_WELCOME = 4'd11,
    MSG_TEMP = 4'd12;

typedef enum logic [1:0] {
    WAIT_EVENT,
    START_MESSAGE,
    WAIT_MESSAGE
} command_state_t;

command_state_t current_state;

logic welcome_pending;
logic btn_inc_pending;
logic btn_dec_pending;
logic btn_reset_pending;

always @(posedge clk) begin
    if (rst) begin
        current_state <= WAIT_EVENT;
        rx_fifo_rd_en <= 1'b0;
        inc <= 1'b0;
        dec <= 1'b0;
        count_reset <= 1'b0;
        message_start <= 1'b0;
        message_code <= MSG_WELCOME;
        unknown_char <= 8'h00;
        welcome_pending <= 1'b1;
        btn_inc_pending <= 1'b0;
        btn_dec_pending <= 1'b0;
        btn_reset_pending <= 1'b0;
    end
    else begin
        rx_fifo_rd_en <= 1'b0;
        inc <= 1'b0;
        dec <= 1'b0;
        count_reset <= 1'b0;
        message_start <= 1'b0;

        if (btn_reset_pulse)
            btn_reset_pending <= 1'b1;

        if (btn_inc_pulse && !btn_dec_pulse)
            btn_inc_pending <= 1'b1;

        if (btn_dec_pulse && !btn_inc_pulse)
            btn_dec_pending <= 1'b1;

        case (current_state)

            WAIT_EVENT: begin
                if (welcome_pending) begin
                    message_code <= MSG_WELCOME;
                    welcome_pending <= 1'b0;
                    current_state <= START_MESSAGE;
                end
                else if (btn_reset_pending) begin
                    count_reset <= 1'b1;
                    message_code <= MSG_BTN_RESET;
                    btn_reset_pending <= btn_reset_pulse;
                    current_state <= START_MESSAGE;
                end
                else if (!rx_fifo_empty) begin
                    rx_fifo_rd_en <= 1'b1;

                    case (command)

                        CMD_INC: begin
                            inc <= 1'b1;

                            if (count == 14'h270F)
                                message_code <= MSG_OVERFLOW;
                            else
                                message_code <= MSG_INC;
                        end

                        CMD_DEC: begin
                            dec <= 1'b1;

                            if (count == 14'h0000)
                                message_code <= MSG_UNDERFLOW;
                            else
                                message_code <= MSG_DEC;
                        end

                        CMD_RESET: begin
                            count_reset <= 1'b1;
                            message_code <= MSG_RESET;
                        end

                        CMD_STATUS: begin
                            message_code <= MSG_STATUS;
                        end
                        
                        CMD_TEMP: begin
                            message_code <= MSG_TEMP;
                        end

                        CMD_HELP: begin
                            message_code <= MSG_HELP;
                        end

                        default: begin
                            unknown_char <= rx_fifo_data;
                            message_code <= MSG_UNKNOWN;
                        end

                    endcase

                    current_state <= START_MESSAGE;
                end
                else if (btn_inc_pending) begin
                    inc <= 1'b1;

                    if (count == 14'h270F)
                        message_code <= MSG_OVERFLOW;
                    else
                        message_code <= MSG_BTN_INC;

                    btn_inc_pending <= btn_inc_pulse && !btn_dec_pulse; // pastreaza o noua apasare in acelasi ciclu
                    current_state <= START_MESSAGE;
                end
                else if (btn_dec_pending) begin
                    dec <= 1'b1;

                    if (count == 14'h0000)
                        message_code <= MSG_UNDERFLOW;
                    else
                        message_code <= MSG_BTN_DEC;

                    btn_dec_pending <= btn_dec_pulse && !btn_inc_pulse;  // pastreaza o noua apasare in acelasi ciclu
                    current_state <= START_MESSAGE;
                end
            end

            START_MESSAGE: begin
                message_start <= 1'b1;
                current_state <= WAIT_MESSAGE;
            end

            WAIT_MESSAGE: begin
                if (message_done)
                    current_state <= WAIT_EVENT;
            end

            default: begin
                current_state <= WAIT_EVENT;
            end

        endcase
    end
end

endmodule
