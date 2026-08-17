`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.08.2026 17:06:08
// Design Name: 
// Module Name: uart_rx
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


module uart_rx
    #(parameter integer CLK_FREQ = 100_000_000,
      parameter integer BAUD_RATE = 9_600
)(
    input clk,
    input rst,
    input rx_in,

    output logic [7:0] rx_data,
    output logic rx_done,
    output logic sample_acquisition 
);

localparam integer CLKS_PER_BIT = CLK_FREQ/BAUD_RATE; // 10416
localparam integer HALF_BIT = CLKS_PER_BIT/2; // 5208
localparam integer COUNTER_WIDTH = $clog2(CLKS_PER_BIT); // 14 biti

typedef enum logic [1:0] {
    RX_IDLE,
    RX_START,
    RX_DATA,
    RX_STOP
} rx_state_t;

rx_state_t current_state;

logic rx_meta;
logic rx_sync;

logic [COUNTER_WIDTH-1:0] clock_count;
logic [2:0] bit_index;
logic [7:0] data_reg;

always @(posedge clk) begin
    if (rst) begin
        rx_meta <= 1'b1;
        rx_sync <= 1'b1;
    end
    else begin
        rx_meta <= rx_in;
        rx_sync <= rx_meta;
    end
end

always @(posedge clk) begin
    if (rst) begin
        current_state <= RX_IDLE;
        clock_count <= '0;
        bit_index <= 3'd0;
        data_reg <= 8'd0;
        rx_data <= 8'd0;
        rx_done <= 1'b0;
        sample_acquisition <= 1'b0;
    end
    else begin
        rx_done <= 1'b0;
        sample_acquisition <= 1'b0;

        case (current_state)

            RX_IDLE: begin
                clock_count <= '0;
                bit_index <= 3'd0;

                if (rx_sync == 1'b0) begin
                    current_state <= RX_START;
                end
            end

            RX_START: begin
                if (clock_count == HALF_BIT - 1) begin
                    clock_count <= '0;
                    sample_acquisition <= 1'b1;

                    if (rx_sync == 1'b0) begin
                        current_state <= RX_DATA;
                    end
                    else begin
                        current_state <= RX_IDLE;
                    end
                end
                else begin
                    clock_count <= clock_count + 1'b1;
                end
            end

            RX_DATA: begin
                if (clock_count == CLKS_PER_BIT - 1) begin
                    clock_count <= '0;
                    data_reg[bit_index] <= rx_sync;
                    sample_acquisition <= 1'b1;

                    if (bit_index == 3'd7) begin
                        bit_index <= 3'd0;
                        current_state <= RX_STOP;
                    end
                    else begin
                        bit_index <= bit_index + 3'd1;
                    end
                end
                else begin
                    clock_count <= clock_count + 1'b1;
                end
            end

            RX_STOP: begin
                if (clock_count == CLKS_PER_BIT - 1) begin
                    clock_count <= '0;
                    sample_acquisition <= 1'b1;

                    if (rx_sync == 1'b1) begin
                        rx_data <= data_reg;
                        rx_done <= 1'b1;
                    end

                    current_state <= RX_IDLE;
                end
                else begin
                    clock_count <= clock_count + 1'b1;
                end
            end

            default: begin
                current_state <= RX_IDLE;
                clock_count <= '0;
                bit_index <= 3'd0;
                data_reg <= 8'd0;
                rx_data <= 8'd0;
                rx_done <= 1'b0;
                sample_acquisition <= 1'b0;
            end

        endcase
    end
end

endmodule
