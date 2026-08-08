`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.07.2026 20:52:45
// Design Name: 
// Module Name: test_i2c_master
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

module test_i2c_master;

localparam integer CLK_FREQ = 100_000_000;
localparam integer I2C_FREQ = 100_000;

typedef enum logic [2:0] {
    CMD_START = 3'd0,
    CMD_WRITE = 3'd1,
    CMD_READ_ACK = 3'd2,
    CMD_READ_NACK = 3'd3,
    CMD_STOP = 3'd4
} i2c_cmd_t;

i2c_cmd_t cmd;

logic clk;
logic rst;
logic cmd_start;
logic [7:0] din;
logic scl;
logic master_sda_out;
logic slave_sda_out;
logic sda_bus;
logic [7:0] dout;
logic ack;
logic ready;
logic done;
logic [7:0] slave_rx_data;

// simulare magistra sda
always @(*) begin
    sda_bus = master_sda_out & slave_sda_out;
end

initial begin
    clk = 1'b0;
    forever #5 clk = !clk;
end

// task comenzi
task I2C_SEND_CMD;
    input i2c_cmd_t command;
    input [7:0] data;
    begin
        wait(ready == 1'b1);    // asteapta pana cand master este pregatit

        @(negedge clk);
        cmd = command;
        din = data;
        cmd_start = 1'b1;

        @(negedge clk);         // opreste impuls cmd_start

        cmd_start = 1'b0;

        wait(ready == 1'b0);    // asteapta executarea comenzii
        wait(ready == 1'b1);

    end

endtask

initial begin
    rst = 1'b1;
    cmd_start = 1'b0;
    cmd = CMD_START;
    din = 8'h00;

    repeat (5)
    @(posedge clk);

    @(negedge clk);
    rst = 1'b0;

    repeat (3)
    @(posedge clk);

    I2C_SEND_CMD(CMD_START, 8'h00);     // start

    I2C_SEND_CMD(CMD_WRITE, 8'hA5);     // master transmite A5
                                        // dummy slave receptioneaza A5 si raspunde cu ack
    
    I2C_SEND_CMD(CMD_START, 8'h00);     // repeated start

    I2C_SEND_CMD(CMD_READ_NACK, 8'h00); // dummy slave transmite 3C
                                        // master raspunde cu nack

    I2C_SEND_CMD(CMD_STOP, 8'h00);      // stop

    repeat (10)
    @(posedge clk);

    $finish;

end

i2c_master #(
    .CLK_FREQ(CLK_FREQ),
    .I2C_FREQ(I2C_FREQ)
) dut_master (
    .clk(clk),
    .rst(rst),
    .cmd_start(cmd_start),
    .cmd(cmd),
    .din(din),
    .sda_in(sda_bus),
    .sda_out(master_sda_out),
    .scl(scl),
    .dout(dout),
    .ack(ack),
    .ready(ready),
    .done(done)
);

i2c_dummy_slave dut_slave (
    .clk(clk),
    .rst(rst),
    .scl(scl),
    .sda_in(sda_bus),
    .sda_out(slave_sda_out),
    .rx_data(slave_rx_data)
);

endmodule
