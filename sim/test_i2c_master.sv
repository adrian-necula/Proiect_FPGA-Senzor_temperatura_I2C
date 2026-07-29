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
localparam integer I2C_FREQ = 1_000_000;

localparam logic [2:0]
    CMD_START = 3'd0,
    CMD_WRITE = 3'd1,
    CMD_READ_ACK = 3'd2,
    CMD_READ_NACK = 3'd3,
    CMD_STOP = 3'd4;

logic clk;
logic rst;
logic cmd_start;
logic [2:0] cmd;
logic [7:0] din;

logic scl;
logic [7:0] dout;
logic ack;
logic ready;
logic done;

wire sda;
logic slave_low;

integer i;

assign sda = slave_low ? 1'b0 : 1'bz;
pullup(sda);

initial begin
    clk = 1'b0;
    forever #5 clk = !clk;
end

task send_cmd(
    input [2:0] command,
    input [7:0] data
);
begin
    wait(ready == 1'b1);

    @(negedge clk);
    cmd = command;
    din = data;
    cmd_start = 1'b1;

    @(negedge clk);
    cmd_start = 1'b0;
end
endtask

task simple_cmd(
    input [2:0] command
);
begin
    send_cmd(command, 8'h00);

    wait(ready == 1'b0);
    wait(ready == 1'b1);
end
endtask

task write_byte(             // master transmite un byte, slave raspunde cu ack
    input [7:0] data
);
begin
    send_cmd(CMD_WRITE, data);

    wait(ready == 1'b0);

    repeat (8)
    @(posedge scl);

    @(negedge scl);
    slave_low = 1'b1;       // slave trimite ack, sda = 0

    @(posedge scl);
    @(negedge scl);

    slave_low = 1'b0;       // slave elibereaza sda

    wait(ready == 1'b1);
end
endtask

task read_byte(             // slave transmite un byte, master raspunde cu nack
    input [7:0] data
);
begin
    send_cmd(CMD_READ_NACK, 8'h00);

    wait(ready == 1'b0);

    for (i = 7; i >= 0; i = i - 1) begin        // msb -> lsb
        if (data[i] == 1'b0)
            slave_low = 1'b1;
        else
            slave_low = 1'b0;

        @(posedge scl);
        @(negedge scl);
    end

    slave_low = 1'b0;

    wait(ready == 1'b1);
end
endtask

initial begin
    rst = 1'b1;
    cmd_start = 1'b0;
    cmd = CMD_START;
    din = 8'h00;
    slave_low = 1'b0;

    repeat (5)
    @(posedge clk);

    @(negedge clk);
    rst = 1'b0;

    repeat (3)
    @(posedge clk);

    simple_cmd(CMD_START);

    write_byte(8'hA5);  // master trimite A5, slave raspunde ack

    simple_cmd(CMD_START);  // start repetat
    
    read_byte(8'h3C);   // slave trimite 3C, master raspunde nack

    simple_cmd(CMD_STOP);   // stop

    repeat (10)
    @(posedge clk);

    $finish;
end

i2c_master #(
    .CLK_FREQ(CLK_FREQ),
    .I2C_FREQ(I2C_FREQ)
) dut (
    .clk(clk),
    .rst(rst),
    .cmd_start(cmd_start),
    .cmd(cmd),
    .din(din),
    .sda(sda),
    .scl(scl),
    .dout(dout),
    .ack(ack),
    .ready(ready),
    .done(done)
);

endmodule