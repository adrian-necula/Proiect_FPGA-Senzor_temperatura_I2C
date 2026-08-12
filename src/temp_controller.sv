`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.07.2026 20:45:55
// Design Name: 
// Module Name: temp_controller
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


module temp_controller #(
    parameter integer FIRST_READ_DELAY = 1_000_000,
    parameter integer READ_INTERVAL = 24_000_000
)(
    input clk,
    input rst,
    input ready,
    input done,
    input ack,
    input [7:0] dout,
    output logic cmd_start,
    output logic [2:0] cmd,
    output logic [7:0] din,
    output logic [15:0] temperature_raw,
    output logic data_valid,
    output logic ack_error
);

localparam [2:0]
    CMD_START = 3'd0,
    CMD_WRITE = 3'd1,
    CMD_READ_ACK = 3'd2,
    CMD_READ_NACK = 3'd3,
    CMD_STOP = 3'd4;

localparam [7:0]
    SENSOR_ADD_WR = 8'h96,
    SENSOR_ADD_RD = 8'h97,
    TEMP_REG = 8'h00;

typedef enum logic [4:0] {
    IDLE,
    SEND_START,
    WAIT_START,
    SEND_ADD_WR,
    WAIT_ADD_WR,
    SEND_REG,
    WAIT_REG,
    SEND_RESTART,
    WAIT_RESTART,
    SEND_ADD_RD,
    WAIT_ADD_RD,
    SEND_RD_MSB,
    WAIT_RD_MSB,
    SEND_RD_LSB,
    WAIT_RD_LSB,
    SEND_STOP,
    WAIT_STOP
} state_t;

state_t current_state;

logic [7:0] msb;
logic [31:0] wait_counter;
logic first_read;

always @(posedge clk) begin
    if (rst) begin
        current_state <= IDLE;
        cmd_start <= 1'b0;
        cmd <= CMD_START;
        din <= 8'h00;
        msb <= 8'h00;
        temperature_raw <= 16'h0000;
        data_valid <= 1'b0;
        ack_error <= 1'b0;
        wait_counter <= 32'd0;
        first_read <= 1'b1;
    end
    else begin
        cmd_start <= 1'b0;
        data_valid <= 1'b0;
        
        case (current_state)

            IDLE: begin
                ack_error <= 1'b0;
                if (first_read) begin
                    if (wait_counter == FIRST_READ_DELAY - 1) begin
                        wait_counter <= 32'd0;
                        first_read <= 1'b0;
                        current_state <= SEND_START;
                    end
                    else begin
                        wait_counter <= wait_counter + 32'd1;
                    end
                end
                else begin
                    if (wait_counter == READ_INTERVAL - 1) begin
                        wait_counter <= 32'd0;
                        current_state <= SEND_START;
                    end
                    else begin
                        wait_counter <= wait_counter + 32'd1;
                    end
                end
            end

            SEND_START: begin
                if (ready) begin
                    cmd <= CMD_START;
                    din <= 8'h00;
                    cmd_start <= 1'b1;
                    current_state <= WAIT_START;
                end
            end

            WAIT_START: begin
                if (done)
                    current_state <= SEND_ADD_WR;
            end

            SEND_ADD_WR: begin          // adresa senzor + write

                if (ready) begin
                    cmd <= CMD_WRITE;
                    din <= SENSOR_ADD_WR;
                    cmd_start <= 1'b1;
                    current_state <= WAIT_ADD_WR;
                end
            end


            WAIT_ADD_WR: begin
                if (done) begin
                    if (ack) begin
                        current_state <= SEND_REG;
                    end
                    else begin
                        ack_error <= 1'b1;
                        current_state <= SEND_STOP;
                    end
                end
            end

            SEND_REG: begin         // registrul temperaturii

                if (ready) begin
                    cmd <= CMD_WRITE;
                    din <= TEMP_REG;
                    cmd_start <= 1'b1;
                    current_state <= WAIT_REG;
                end
            end

            WAIT_REG: begin
                if (done) begin
                    if (ack) begin
                        current_state <= SEND_RESTART;
                    end
                    else begin
                        ack_error <= 1'b1;
                        current_state <= SEND_STOP;
                    end
                end
            end

            SEND_RESTART: begin         // repeated start
                if (ready) begin
                    cmd <= CMD_START;
                    din <= 8'h00;
                    cmd_start <= 1'b1;
                    current_state <= WAIT_RESTART;
                end
            end

            WAIT_RESTART: begin
                if (done) begin
                    current_state <= SEND_ADD_RD;
                end
            end

            SEND_ADD_RD: begin          // adresa senzor + read
                if (ready) begin
                    cmd <= CMD_WRITE;
                    din <= SENSOR_ADD_RD;
                    cmd_start <= 1'b1;
                    current_state <= WAIT_ADD_RD;
                end
            end

            WAIT_ADD_RD: begin
                if (done) begin
                    if (ack) begin
                        current_state <= SEND_RD_MSB;
                    end
                    else begin
                        ack_error <= 1'b1;
                        current_state <= SEND_STOP;
                    end
                end
            end

            SEND_RD_MSB: begin          // citeste msb si trimite ack
                if (ready) begin
                    cmd <= CMD_READ_ACK;
                    din <= 8'h00;
                    cmd_start <= 1'b1;
                    current_state <= WAIT_RD_MSB;
                end
            end

            WAIT_RD_MSB: begin
                if (done) begin
                    msb <= dout;
                    current_state <= SEND_RD_LSB;
                end
            end

            SEND_RD_LSB: begin          // citeste lsb si trimite nack
                if (ready) begin
                    cmd <= CMD_READ_NACK;
                    din <= 8'h00;
                    cmd_start <= 1'b1;
                    current_state <= WAIT_RD_LSB;
                end
            end

            WAIT_RD_LSB: begin
                if (done) begin
                    temperature_raw <= {msb, dout};
                    current_state <= SEND_STOP;
                end
            end

            SEND_STOP: begin           // stop
                if (ready) begin
                    cmd <= CMD_STOP;
                    din <= 8'h00;
                    cmd_start <= 1'b1;
                    current_state <= WAIT_STOP;
                end
            end

            WAIT_STOP: begin
                if (done) begin
                    if (!ack_error) begin
                        data_valid <= 1'b1;
                    end
                    wait_counter <= 32'd0;
                    current_state <= IDLE;
                end
            end

            default: begin
                current_state <= IDLE;
                wait_counter <= 32'd0;
            end

        endcase
    end
end

endmodule
