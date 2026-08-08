`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.08.2026 13:56:02
// Design Name: 
// Module Name: i2c_dummy_slave
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

module i2c_dummy_slave (
    input logic clk,
    input logic rst,
    input logic scl,
    input logic sda_in,     // val citita de slave
    output logic sda_out,   // val transmisa de slave
    output logic [7:0] rx_data  // byte receptionat de la master
);

localparam logic [7:0] TX_DATA = 8'h3C;

typedef enum logic [2:0] {
    WAIT_START,
    RECEIVE,
    SEND_ACK,
    WAIT_RESTART,
    TRANSMIT,
    READ_NACK,
    WAIT_STOP
} state_t;

state_t current_state;

logic scl_old;
logic sda_old;
logic [2:0] bit_index;

always @(posedge clk) begin
    if (rst) begin
        current_state <= WAIT_START;
        scl_old <= 1'b1;
        sda_old <= 1'b1;
        sda_out <= 1'b1;
        rx_data <= 8'h00;
        bit_index <= 3'd7;
    end
    else begin
        scl_old <= scl;
        sda_old <= sda_in;

        case (current_state)

            WAIT_START: begin
                sda_out <= 1'b1;
                if (sda_old && !sda_in && scl) begin // cond de start
                    rx_data <= 8'h00;
                    bit_index <= 3'd7;
                    current_state <= RECEIVE;
                end
            end
            
            RECEIVE: begin
                if (scl && !scl_old) begin
                    rx_data[bit_index] <= sda_in;
                    if (bit_index == 0)
                        current_state <= SEND_ACK;
                    else
                        bit_index <= bit_index - 1'b1;
                end
            end
            
            SEND_ACK: begin
                if (!scl && scl_old)
                    sda_out <= 1'b0;
                if (scl && !scl_old)
                    current_state <= WAIT_RESTART;
            end

            WAIT_RESTART: begin     // elibereaza sda si asteapta repeated start
                if (!scl && scl_old)
                    sda_out <= 1'b1;
                if (sda_old && !sda_in && scl) begin
                    bit_index <= 3'd7;
                    current_state <= TRANSMIT;
                end
            end

            TRANSMIT: begin     // transmite valoarea 3C
                if (!scl && scl_old)
                    sda_out <= TX_DATA[bit_index];
                if (scl && !scl_old) begin
                    if (bit_index == 0)
                        current_state <= READ_NACK;
                    else
                        bit_index <= bit_index - 1'b1;
                end
            end

            READ_NACK: begin    // elibereaza sda pentru nack master
                if (!scl && scl_old)
                    sda_out <= 1'b1;
                if (scl && !scl_old) begin
                    if (sda_in == 1'b1)
                        current_state <= WAIT_STOP;
                end
            end

            WAIT_STOP: begin
                sda_out <= 1'b1;
                if (!sda_old && sda_in && scl)
                    current_state <= WAIT_START;
            end

            default: begin
                current_state <= WAIT_START;
                sda_out <= 1'b1;
            end
            
        endcase
    end
end

endmodule