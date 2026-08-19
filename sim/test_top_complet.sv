`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.08.2026 14:41:43
// Design Name: 
// Module Name: test_top_complet
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

module test_top_complet();

localparam integer CLKS_PER_BIT = 100;

logic clk;
logic rst;
logic uart_rx_in;
logic btn_inc;
logic btn_dec;
logic btn_count_reset;

wire uart_tx_out;
wire TMP_SDA;
wire TMP_SCL;
wire [13:0] led;
wire [7:0] seg;
wire [7:0] an;

wire sda_bus;

integer message_count;

// clock 100 MHz
initial begin
    clk = 1'b0;
    forever #5 clk = !clk;
end

// numarare mesaje
always @(posedge clk) begin
    if (rst) begin
        message_count <= 0;
    end
    else begin
        if (dut.message_done) begin
            message_count <= message_count + 1;
        end
    end
end

// trimitere byte UART
task send_uart_byte;
    input [7:0] data;
    integer i;
    begin
        uart_rx_in <= 1'b0;
        repeat (CLKS_PER_BIT) begin
            @(posedge clk);
        end
        for (i = 0; i < 8; i = i + 1) begin
            uart_rx_in <= data[i];
            repeat (CLKS_PER_BIT) begin
                @(posedge clk);
            end
        end
        uart_rx_in <= 1'b1;
        repeat (CLKS_PER_BIT) begin
            @(posedge clk);
        end
    end
endtask

// buton INC
task press_inc;
    begin
        btn_inc <= 1'b1;
        repeat (10) begin
            @(posedge clk);
        end
        btn_inc <= 1'b0;
        repeat (10) begin
            @(posedge clk);
        end
    end
endtask

// buton DEC
task press_dec;
    begin
        btn_dec <= 1'b1;
        repeat (10) begin
            @(posedge clk);
        end
        btn_dec <= 1'b0;
        repeat (10) begin
            @(posedge clk);
        end
    end
endtask

// buton RESET
task press_reset;
    begin
        btn_count_reset <= 1'b1;
        repeat (10) begin
            @(posedge clk);
        end
        btn_count_reset <= 1'b0;
        repeat (10) begin
            @(posedge clk);
        end
    end
endtask

// bus i2c pt simulare
assign sda_bus = dut.sda_out & dut.dummy_sda_out;
assign TMP_SDA = sda_bus;

// stimuli
initial begin
    rst <= 1'b1;
    uart_rx_in <= 1'b1;
    btn_inc <= 1'b0;
    btn_dec <= 1'b0;
    btn_count_reset <= 1'b0;

    // reset
    repeat (5) begin
        @(posedge clk);
    end
    rst <= 1'b0;

    // welcome
    wait (message_count >= 1);

    // temperatura 25.0 grade
    wait (dut.data_valid_temp == 1'b1);
    wait (dut.temperature_raw == 16'h0C80);

    // D: 0 -> 9999
    send_uart_byte(8'h44);
    wait (dut.count == 14'd9999);
    wait (message_count >= 2);

    // I: 9999 -> 0
    send_uart_byte(8'h49);
    wait (dut.count == 14'd0);
    wait (message_count >= 3);

    // I: 0 -> 1
    send_uart_byte(8'h49);
    wait (dut.count == 14'd1);
    wait (message_count >= 4);

    // S: status
    send_uart_byte(8'h53);
    wait (message_count >= 5);

    // T: temperatura
    send_uart_byte(8'h54);
    wait (message_count >= 6);

    // ?: ajutor
    send_uart_byte(8'h3F);
    wait (message_count >= 7);

    // X: comanda necunoscuta
    send_uart_byte(8'h58);
    wait (message_count >= 8);

    // R: reset counter
    send_uart_byte(8'h52);
    wait (dut.count == 14'd0);
    wait (message_count >= 9);

    // buton INC
    press_inc();
    wait (dut.count == 14'd1);
    wait (message_count >= 10);

    // buton DEC
    press_dec();
    wait (dut.count == 14'd0);
    wait (message_count >= 11);

    // buton INC
    press_inc();
    wait (dut.count == 14'd1);
    wait (message_count >= 12);

    // buton RESET
    press_reset();
    wait (dut.count == 14'd0);
    wait (message_count >= 13);

    // asteptare terminare UART
    wait (dut.tx_fifo_empty == 1'b1);
    wait (dut.tx_busy == 1'b0);
    repeat (20) begin
        @(posedge clk);
    end
    $finish;

end

// limita simulare
initial begin
    #30_000_000;
    $finish;
end

top_complet #(
    .BAUD_RATE(1_000_000),
    .DEBOUNCE_COUNT(4)
) dut (
    .clk(clk),
    .rst(rst),
    .uart_rx_in(uart_rx_in),
    .btn_inc(btn_inc),
    .btn_dec(btn_dec),
    .btn_count_reset(btn_count_reset),
    .TMP_SDA(TMP_SDA),
    .TMP_SCL(TMP_SCL),
    .uart_tx_out(uart_tx_out),
    .led(led),
    .seg(seg),
    .an(an)
);

endmodule