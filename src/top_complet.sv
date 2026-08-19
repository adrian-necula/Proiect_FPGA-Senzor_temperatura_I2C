`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.08.2026 01:53:44
// Design Name: 
// Module Name: top_complet
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


module top_complet
    #(parameter integer CLK_FREQ = 100_000_000,
      parameter integer BAUD_RATE = 9_600,
      parameter integer DEBOUNCE_COUNT = 2_000_000
)(
    input clk,
    input rst,
    input uart_rx_in,
    input btn_inc,
    input btn_dec,
    input btn_count_reset,
    inout TMP_SDA,
    output TMP_SCL,
    output uart_tx_out,
    output [13:0] led,
    output [7:0] seg,
    output [7:0] an
);

// clock
wire clk_sys;
wire clk_locked;
wire rst_global;

// i2c ctrl - master
wire cmd_start;
wire [2:0] cmd;
wire [7:0] din;

wire [7:0] dout;
wire ack;
wire ready;
wire done;

// cmd i2c pt waveform
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

// temperatura
wire [15:0] temperature_raw;
wire data_valid_temp;
wire ack_error;

wire [7:0] temp_celsius;
wire [3:0] temp_fraction;
wire negative;

wire [47:0] ascii_temp;

// cifre temperatura
wire [3:0] temp_digit0;
wire [3:0] temp_digit1;
wire [3:0] temp_digit2;
wire [3:0] temp_digit3;

// uart rx
wire [7:0] rx_data;
wire rx_done;
wire sample_acquisition;

// fifo rx
wire [7:0] rx_fifo_din;
wire rx_fifo_wr_en;
wire rx_fifo_full;

wire [7:0] rx_fifo_dout;
wire rx_fifo_rd_en;
wire rx_fifo_empty;

// comanda uart
wire [2:0] command;

// butoane
wire btn_inc_sync;
wire btn_dec_sync;
wire btn_reset_sync;

wire btn_inc_stable;
wire btn_dec_stable;
wire btn_reset_stable;

wire btn_inc_pulse;
wire btn_dec_pulse;
wire btn_reset_pulse;

// control counter
wire inc;
wire dec;
wire count_reset;

// counter
wire [13:0] count;
wire overflow;
wire underflow;

wire [47:0] ascii_hex;

// cifre counter
wire [3:0] count_digit0;
wire [3:0] count_digit1;
wire [3:0] count_digit2;
wire [3:0] count_digit3;

// message sender
wire message_start;
wire [3:0] message_code;
wire [7:0] unknown_char;
wire message_busy;
wire message_done;

// fifo tx
wire [7:0] tx_fifo_din;
wire data_valid;
wire tx_fifo_wr_en;
wire tx_fifo_full;

wire [7:0] tx_fifo_dout;
wire tx_fifo_rd_en;
wire tx_fifo_empty;

// uart tx
wire [7:0] tx_data;
wire tx_start;
wire tx_busy;
wire tx_done;
wire bit_start;

// display
wire [19:0] mux_count;
wire [2:0] sel;
wire [3:0] digit_out;
wire decimal_point;

// reset global
assign rst_global = rst | !clk_locked;

// afisare counter pe leduri
assign led = count;

// fifo rx
assign rx_fifo_din = rx_data;
assign rx_fifo_wr_en = rx_done && !rx_fifo_full;

// fifo tx
assign tx_data = tx_fifo_dout;
assign tx_start = !tx_fifo_empty && !tx_busy;
assign tx_fifo_rd_en = tx_start;

// multiplexare display
assign sel = mux_count[18:16];

// punct dupa unitatile temperaturii
assign decimal_point = (sel == 3'd6);


// clock wizard
clk_wiz_uart_senzor c1 (
    .clk_out1(clk_sys),
    .reset(rst),
    .locked(clk_locked),
    .clk_in1(clk)
);

// sda placa
IOBUF c2 (
    .I(1'b0),       // val care se conduce pe pin
    .T(sda_out),    // 1 = Hi sau Z, 0 = conduce valoarea I
    .O(sda_in),     // val citita de pe pin
    .IO(TMP_SDA)    // pinul fizic
);

// ctrl temperatura
temp_controller c3 (
    .clk(clk_sys),
    .rst(rst_global),
    .ready(ready),
    .done(done),
    .ack(ack),
    .dout(dout),
    .cmd_start(cmd_start),
    .cmd(cmd),
    .din(din),
    .temperature_raw(temperature_raw),
    .data_valid(data_valid_temp),
    .ack_error(ack_error)
);

// master i2c
i2c_master #(
    .CLK_FREQ(CLK_FREQ),
    .I2C_FREQ(100_000)
) c4 (
    .clk(clk_sys),
    .rst(rst_global),
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
i2c_dummy_slave c5 (
    .clk(clk_sys),
    .rst(rst_global),
    .scl(TMP_SCL),
    .sda_in(sda_in),
    .sda_out(dummy_sda_out)
);

// conversie temperatura
temp_converter c6 (
    .temperature_raw(temperature_raw),
    .temp_celsius(temp_celsius),
    .temp_fraction(temp_fraction),
    .negative(negative)
);

// temperatura -> cifre
temp_to_digits c7 (
    .temp_celsius(temp_celsius),
    .temp_fraction(temp_fraction),
    .digit0(temp_digit0),
    .digit1(temp_digit1),
    .digit2(temp_digit2),
    .digit3(temp_digit3)
);

// temperatura -> ascii
temp_to_ascii c8 (
    .temp_celsius(temp_celsius),
    .temp_fraction(temp_fraction),
    .negative(negative),
    .ascii_temp(ascii_temp)
);

// uart rx
uart_rx #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
) c9 (
    .clk(clk_sys),
    .rst(rst_global),
    .rx_in(uart_rx_in),
    .rx_data(rx_data),
    .rx_done(rx_done),
    .sample_acquisition(sample_acquisition)
);

// fifo rx
fifo_uart_senzor c10 (
    .clk(clk_sys),
    .srst(rst_global),
    .din(rx_fifo_din),
    .wr_en(rx_fifo_wr_en),
    .rd_en(rx_fifo_rd_en),
    .dout(rx_fifo_dout),
    .full(rx_fifo_full),
    .empty(rx_fifo_empty)
);

// decodare comanda
uart_senzor_command_decoder c11 (
    .data_in(rx_fifo_dout),
    .command(command)
);

// buton INC
button_sync c12 (
    .clk(clk_sys),
    .rst(rst_global),
    .btn_in(btn_inc),
    .btn_sync(btn_inc_sync)
);

debouncer #(
    .MAX_COUNT(DEBOUNCE_COUNT)
) c13 (
    .clk(clk_sys),
    .rst(rst_global),
    .btn_in(btn_inc_sync),
    .btn_stable(btn_inc_stable)
);

edge_detector c14 (
    .clk(clk_sys),
    .rst(rst_global),
    .signal_in(btn_inc_stable),
    .pulse_out(btn_inc_pulse)
);

// buton DEC
button_sync c15 (
    .clk(clk_sys),
    .rst(rst_global),
    .btn_in(btn_dec),
    .btn_sync(btn_dec_sync)
);

debouncer #(
    .MAX_COUNT(DEBOUNCE_COUNT)
) c16 (
    .clk(clk_sys),
    .rst(rst_global),
    .btn_in(btn_dec_sync),
    .btn_stable(btn_dec_stable)
);

edge_detector c17 (
    .clk(clk_sys),
    .rst(rst_global),
    .signal_in(btn_dec_stable),
    .pulse_out(btn_dec_pulse)
);

// buton RESET counter
button_sync c18 (
    .clk(clk_sys),
    .rst(rst_global),
    .btn_in(btn_count_reset),
    .btn_sync(btn_reset_sync)
);

debouncer #(
    .MAX_COUNT(DEBOUNCE_COUNT)
) c19 (
    .clk(clk_sys),
    .rst(rst_global),
    .btn_in(btn_reset_sync),
    .btn_stable(btn_reset_stable)
);

edge_detector c20 (
    .clk(clk_sys),
    .rst(rst_global),
    .signal_in(btn_reset_stable),
    .pulse_out(btn_reset_pulse)
);

// control comenzi
uart_senzor_command_control c21 (
    .clk(clk_sys),
    .rst(rst_global),
    .command(command),
    .rx_fifo_data(rx_fifo_dout),
    .rx_fifo_empty(rx_fifo_empty),
    .count(count),
    .btn_inc_pulse(btn_inc_pulse),
    .btn_dec_pulse(btn_dec_pulse),
    .btn_reset_pulse(btn_reset_pulse),
    .message_done(message_done),
    .rx_fifo_rd_en(rx_fifo_rd_en),
    .inc(inc),
    .dec(dec),
    .count_reset(count_reset),
    .message_start(message_start),
    .message_code(message_code),
    .unknown_char(unknown_char)
);


// counter
counter14b c22 (
    .clk(clk_sys),
    .rst(rst_global),
    .inc(inc),
    .dec(dec),
    .count_reset(count_reset),
    .count(count),
    .overflow(overflow),
    .underflow(underflow)
);

// counter -> ascii
counter_to_ascii c23 (
    .count(count),
    .ascii_hex(ascii_hex)
);

// counter -> cifre
binary_to_decimal c24 (
    .binary(count),
    .digit0(count_digit0),
    .digit1(count_digit1),
    .digit2(count_digit2),
    .digit3(count_digit3)
);

// generare mesaj
message_sender c25 (
    .clk(clk_sys),
    .rst(rst_global),
    .start(message_start),
    .msg_code(message_code),
    .unknown_char(unknown_char),
    .ascii_hex(ascii_hex),
    .ascii_temp(ascii_temp),
    .tx_fifo_full(tx_fifo_full),
    .tx_fifo_din(tx_fifo_din),
    .data_valid(data_valid),
    .tx_fifo_wr_en(tx_fifo_wr_en),
    .busy(message_busy),
    .done(message_done)
);

// fifo tx
fifo_uart_senzor c26 (
    .clk(clk_sys),
    .srst(rst_global),
    .din(tx_fifo_din),
    .wr_en(tx_fifo_wr_en),
    .rd_en(tx_fifo_rd_en),
    .dout(tx_fifo_dout),
    .full(tx_fifo_full),
    .empty(tx_fifo_empty)
);

// uart tx
uart_tx #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
) c27 (
    .clk(clk_sys),
    .rst(rst_global),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx_out(uart_tx_out),
    .tx_busy(tx_busy),
    .tx_done(tx_done),
    .bit_start(bit_start)
);

// num pt multiplexare
num c28 (
    .rst(rst_global),
    .clk(clk_sys),
    .count(mux_count)
);

// mux display
mux c29 (
    // counter dreapta
    .digit0(count_digit0),
    .digit1(count_digit1),
    .digit2(count_digit2),
    .digit3(count_digit3),

    // temperatura stanga
    .digit4(temp_digit0),
    .digit5(temp_digit1),
    .digit6(temp_digit2),
    .digit7(temp_digit3),

    .sel(sel),
    .digit_out(digit_out)
);

// cifra -> 7seg
transcodor_7seg c30 (
    .digit(digit_out),
    .decimal_point(decimal_point),
    .seg(seg)
);

// selectare anod
decodor_anod c31 (
    .rst(rst_global),
    .sel(sel),
    .an(an)
);

endmodule