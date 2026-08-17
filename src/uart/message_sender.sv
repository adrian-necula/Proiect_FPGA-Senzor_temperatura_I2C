`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.08.2026 00:54:20
// Design Name: 
// Module Name: message_sender
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


module message_sender (
    input clk,
    input rst,
    input start,
    input [3:0] msg_code,
    input [7:0] unknown_char,
    input [47:0] ascii_hex,
    input [47:0] ascii_temp,
    input tx_fifo_full,
    output logic [7:0] tx_fifo_din,
    output logic data_valid,
    output logic tx_fifo_wr_en,
    output logic busy,
    output logic done
);

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

localparam integer NORMAL_BYTES = 64;
localparam integer LONG_BYTES = 128;

localparam integer LEN_INC = 37;
localparam integer LEN_DEC = 37;
localparam integer LEN_RESET = 33;
localparam integer LEN_STATUS = 29;
localparam integer LEN_HELP = 108;
localparam integer LEN_UNKNOWN = 24;
localparam integer LEN_OVERFLOW = 27;
localparam integer LEN_UNDERFLOW = 28;
localparam integer LEN_BTN_INC = 28;
localparam integer LEN_BTN_DEC = 28;
localparam integer LEN_BTN_RESET = 30;
localparam integer LEN_WELCOME = 44;
localparam integer LEN_INVALID = 15;
localparam integer LEN_TEMP = 35;

logic [NORMAL_BYTES-1:0][7:0] normal_buffer;
logic [LONG_BYTES-1:0][7:0] long_buffer;

logic [3:0] active_msg;
logic [7:0] msg_length;
logic [7:0] char_index;

always @(*) begin
    data_valid = busy && (char_index < msg_length);
    tx_fifo_wr_en = data_valid && !tx_fifo_full;
    tx_fifo_din = 8'h00;

    if (data_valid) begin
        if (active_msg == MSG_HELP)
            tx_fifo_din = long_buffer[LONG_BYTES - 1 - char_index];
        else
            tx_fifo_din = normal_buffer[NORMAL_BYTES - 1 - char_index];
    end
end


always @(posedge clk) begin
    if (rst) begin
        normal_buffer <= '0;
        long_buffer <= '0;
        active_msg <= MSG_WELCOME;
        msg_length <= 8'd0;
        char_index <= 8'd0;
        busy <= 1'b0;
        done <= 1'b0;
    end
    else begin
        done <= 1'b0;
        if (!busy && start) begin
            active_msg <= msg_code;
            char_index <= 8'd0;
            busy <= 1'b1;
            
             case (msg_code)

                MSG_INC: begin
                    normal_buffer <= {"Contor incrementat. Valoare: ", ascii_hex, 8'h0D, 8'h0A, {(NORMAL_BYTES-LEN_INC){8'h00}}};
                    msg_length <= LEN_INC;
                end
            
                MSG_DEC: begin
                    normal_buffer <= {"Contor decrementat. Valoare: ", ascii_hex, 8'h0D, 8'h0A, {(NORMAL_BYTES-LEN_DEC){8'h00}}};
                    msg_length <= LEN_DEC;
                end
            
                MSG_RESET: begin
                    normal_buffer <= {"Contor resetat. Valoare: ", ascii_hex, 8'h0D, 8'h0A, {(NORMAL_BYTES-LEN_RESET){8'h00}}};
                    msg_length <= LEN_RESET;
                end
            
                MSG_STATUS: begin
                    normal_buffer <= {"Valoarea contorului: ", ascii_hex, 8'h0D, 8'h0A, {(NORMAL_BYTES-LEN_STATUS){8'h00}}};
                    msg_length <= LEN_STATUS;
                end
            
                MSG_HELP: begin
                    long_buffer <= {"Comenzi:", 8'h0D, 8'h0A, "I/i - Incrementare", 8'h0D, 8'h0A, "D/d - Decrementare", 8'h0D, 8'h0A, "R/r - Reset", 8'h0D, 8'h0A, "S/s - Status", 8'h0D, 8'h0A, "T/t - Temperatura", 8'h0D, 8'h0A, "? - Ajutor", 8'h0D, 8'h0A, {(LONG_BYTES-LEN_HELP){8'h00}}};
                    msg_length <= LEN_HELP;
                end
            
                MSG_UNKNOWN: begin
                    normal_buffer <= {"Comanda necunoscuta: ", unknown_char, 8'h0D, 8'h0A, {(NORMAL_BYTES-LEN_UNKNOWN){8'h00}}};
                    msg_length <= LEN_UNKNOWN;
                end
            
                MSG_OVERFLOW: begin
                    normal_buffer <= {"Overflow. Valoare: ", ascii_hex, 8'h0D, 8'h0A, {(NORMAL_BYTES-LEN_OVERFLOW){8'h00}}};
                    msg_length <= LEN_OVERFLOW;
                end
            
                MSG_UNDERFLOW: begin
                    normal_buffer <= {"Underflow. Valoare: ", ascii_hex, 8'h0D, 8'h0A, {(NORMAL_BYTES-LEN_UNDERFLOW){8'h00}}};
                    msg_length <= LEN_UNDERFLOW;
                end
            
                MSG_BTN_INC: begin
                    normal_buffer <= {"Buton INC. Valoare: ", ascii_hex, 8'h0D, 8'h0A, {(NORMAL_BYTES-LEN_BTN_INC){8'h00}}};
                    msg_length <= LEN_BTN_INC;
                end
            
                MSG_BTN_DEC: begin
                    normal_buffer <= {"Buton DEC. Valoare: ", ascii_hex, 8'h0D, 8'h0A, {(NORMAL_BYTES-LEN_BTN_DEC){8'h00}}};
                    msg_length <= LEN_BTN_DEC;
                end
            
                MSG_BTN_RESET: begin
                    normal_buffer <= {"Buton RESET. Valoare: ", ascii_hex, 8'h0D, 8'h0A, {(NORMAL_BYTES-LEN_BTN_RESET){8'h00}}};
                    msg_length <= LEN_BTN_RESET;
                end
            
                MSG_WELCOME: begin
                    normal_buffer <= {"UART Counter Logger", 8'h0D, 8'h0A, "Apasa ? pentru ajutor", 8'h0D, 8'h0A, {(NORMAL_BYTES-LEN_WELCOME){8'h00}}};
                    msg_length <= LEN_WELCOME;
                end
                
                MSG_TEMP: begin
                    normal_buffer <= {"Temperatura: ", ascii_temp, " grade Celsius", 8'h0D, 8'h0A, {(NORMAL_BYTES-LEN_TEMP){8'h00}}};
                    msg_length <= LEN_TEMP;
                end
            
                default: begin
                    normal_buffer <= {"Mesaj invalid", 8'h0D, 8'h0A, {(NORMAL_BYTES-LEN_INVALID){8'h00}}};
                    msg_length <= LEN_INVALID;
                end
            
            endcase
        end
        
        else if (tx_fifo_wr_en) begin
            if (char_index == msg_length - 1'b1) begin
                char_index <= 8'd0;
                msg_length <= 8'd0;
                busy <= 1'b0;
                done <= 1'b1;
            end
            else begin
                char_index <= char_index + 1'b1;
            end
        end
    end
end

endmodule
