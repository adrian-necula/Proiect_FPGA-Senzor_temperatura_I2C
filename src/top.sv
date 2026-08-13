`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.08.2026 01:02:20
// Design Name: 
// Module Name: top
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

module top(
    input clk,
    input rst,
    inout TMP_SDA,
    output TMP_SCL,
    output [7:0] seg,
    output [7:0] an
);

// ctrl - master
wire cmd_start;
wire [2:0] cmd; 
wire [7:0] din;

wire [7:0] dout;
wire ack;
wire ready;
wire done;

// cmd pt waveform
typedef enum logic [2:0] {
    CMD_START = 3'd0,
    CMD_WRITE = 3'd1,
    CMD_READ_ACK = 3'd2,
    CMD_READ_NACK = 3'd3,
    CMD_STOP = 3'd4
} i2c_cmd_t;

i2c_cmd_t cmd_wave;

assign cmd_wave = i2c_cmd_t'(cmd);

// i2c
wire sda_in;
wire sda_out;
wire dummy_sda_out;

// temp
wire [15:0] temperature_raw;
wire data_valid;
wire ack_error;

wire [7:0] temp_celsius;
wire [3:0] temp_fraction;
wire negative;

// display
wire [3:0] digit0;
wire [3:0] digit1;
wire [3:0] digit2;
wire [3:0] digit3;
wire [3:0] digit_out;

wire [19:0] count;
wire [2:0] sel;
wire decimal_point;

assign sel = count[18:16];

// punct dupa unitati
assign decimal_point = (sel == 3'd6);

// sda placa
IOBUF c1 (
    .I(1'b0),       // val care se conduce pe pin
    .T(sda_out),    // 1 = Hi sau Z, 0 = conduce valoarea I
    .O(sda_in),     // val citita de pe pin
    .IO(TMP_SDA)    // pinul fizic
);

// ctrl temp
temp_controller c2 (
    .clk(clk),
    .rst(rst),
    .ready(ready),
    .done(done),
    .ack(ack),
    .dout(dout),
    .cmd_start(cmd_start),
    .cmd(cmd),
    .din(din),
    .temperature_raw(temperature_raw),
    .data_valid(data_valid),
    .ack_error(ack_error)
);

// master i2c
i2c_master #(
    .CLK_FREQ(100_000_000),
    .I2C_FREQ(100_000)
) c3 (
    .clk(clk),
    .rst(rst),
    .cmd_start(cmd_start),
    .cmd(cmd),
    .din(din),
    .sda_in(sda_in),
    .sda_out(sda_out),
    .scl(TMP_SCL),
    .dout(dout),
    .ack(ack),
    .ready(ready),
    .done(done)
);

// dummy pt simulare
i2c_dummy_slave c4 (
    .clk(clk),
    .rst(rst),
    .scl(TMP_SCL),
    .sda_in(sda_in),
    .sda_out(dummy_sda_out)
);

// conversie temp
temp_converter c5 (
    .temperature_raw(temperature_raw),
    .temp_celsius(temp_celsius),
    .temp_fraction(temp_fraction),
    .negative(negative)
);

// temp -> cifre
temp_to_digits c6 (
    .temp_celsius(temp_celsius),
    .temp_fraction(temp_fraction),
    .digit0(digit0),
    .digit1(digit1),
    .digit2(digit2),
    .digit3(digit3)
);

// num pt multiplexare
num c7 (
    .rst(rst),
    .clk(clk),
    .count(count)
);

// mux display
mux c8 (
    .digit0(4'hF),
    .digit1(4'hF),
    .digit2(4'hF),
    .digit3(4'hF),
    .digit4(digit0),
    .digit5(digit1),
    .digit6(digit2),
    .digit7(digit3),
    .sel(sel),
    .digit_out(digit_out)
);

// cifra -> 7seg
transcodor_7seg c9 (
    .digit(digit_out),
    .decimal_point(decimal_point),
    .seg(seg)
);

// selectare anod
decodor_anod c10 (
    .sel(sel),
    .an(an)
);

endmodule