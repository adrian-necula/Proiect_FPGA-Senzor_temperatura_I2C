`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 17:08:59
// Design Name: 
// Module Name: uart_tx
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


module uart_tx
    #(parameter integer CLK_FREQ = 100_000_000,
      parameter integer BAUD_RATE = 9_600
)(
    input clk,
    input rst,
    input tx_start,
    input [7:0] tx_data,

    output logic tx_out,
    output logic tx_busy,
    output logic tx_done,
    output logic bit_start
);

localparam integer CLKS_PER_BIT = CLK_FREQ/BAUD_RATE; // 10416
localparam integer COUNTER_WIDTH = $clog2(CLKS_PER_BIT); // 14 biti

typedef enum logic [1:0] {
    TX_IDLE,
    TX_START,
    TX_DATA,
    TX_STOP
} tx_state_t;

tx_state_t current_state;

logic [COUNTER_WIDTH-1:0] clock_count;
logic [2:0] bit_index;
logic [7:0] data_reg;

always @(posedge clk) begin
    if (rst) begin
        current_state <= TX_IDLE;
        clock_count <= '0;
        bit_index <= 3'd0;
        data_reg <= 8'd0;
        tx_out <= 1'b1;
        tx_busy <= 1'b0;
        tx_done <= 1'b0;
        bit_start <= 1'b0;
    end
    else begin
        tx_done <= 1'b0;
        bit_start <= 1'b0;

        case (current_state)

            TX_IDLE: begin
                tx_out <= 1'b1;
                tx_busy <= 1'b0;

                if (tx_start) begin
                    data_reg <= tx_data;
                    clock_count <= '0;
                    bit_index <= 3'd0;
                    tx_out <= 1'b0;
                    tx_busy <= 1'b1;
                    bit_start <= 1'b1;
                    current_state <= TX_START;
                end
            end

            TX_START: begin
                if (clock_count == CLKS_PER_BIT - 1) begin
                    clock_count <= '0;
                    tx_out <= data_reg[0];
                    bit_start <= 1'b1;
                    current_state <= TX_DATA;
                end
                else begin
                    clock_count <= clock_count + 1'b1;
                end
            end

            TX_DATA: begin
                if (clock_count == CLKS_PER_BIT - 1) begin
                    clock_count <= '0;
                    bit_start <= 1'b1;

                    if (bit_index == 3'd7) begin
                        tx_out <= 1'b1;
                        current_state <= TX_STOP;
                    end
                    else begin
                        bit_index <= bit_index + 3'd1;
                        tx_out <= data_reg[bit_index + 3'd1];
                    end
                end
                else begin
                    clock_count <= clock_count + 1'b1;
                end
            end

            TX_STOP: begin
                if (clock_count == CLKS_PER_BIT - 1) begin
                    clock_count <= '0;
                    tx_busy <= 1'b0;
                    tx_done <= 1'b1;
                    current_state <= TX_IDLE;
                end
                else begin
                    clock_count <= clock_count + 1'b1;
                end
            end

            default: begin
                current_state <= TX_IDLE;
                clock_count <= '0;
                bit_index <= 3'd0;
                data_reg <= 8'd0;
                tx_out <= 1'b1;
                tx_busy <= 1'b0;
                tx_done <= 1'b0;
                bit_start <= 1'b0;
            end

        endcase
    end
end

endmodule