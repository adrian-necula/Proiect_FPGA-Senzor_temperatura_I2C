`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.07.2026 14:22:18
// Design Name: 
// Module Name: i2c_master
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

module i2c_master #(
    parameter integer CLK_FREQ = 100_000_000,
    parameter integer I2C_FREQ = 100_000
)(
    input clk,
    input rst,
    input cmd_start,
    input [2:0] cmd,
    input [7:0] din,
    input  logic sda_in,
    output logic sda_out,
    output logic scl,
    output logic [7:0] dout,
    output logic ack,
    output logic ready,
    output logic done
);

localparam integer DIVIDER = CLK_FREQ/(4*I2C_FREQ);

localparam logic [2:0]
    CMD_START = 3'd0,
    CMD_WRITE = 3'd1,
    CMD_READ_ACK = 3'd2,
    CMD_READ_NACK = 3'd3,
    CMD_STOP = 3'd4;

localparam logic [1:0]
    PHASE_0 = 2'd0,  // pregateste SDA cat timp SCL este 0
    PHASE_1 = 2'd1,    // ridica SCL la 1
    PHASE_2 = 2'd2, // citeste sau mentine SDA cat timp SCL este 1 
    PHASE_3 = 2'd3;     // coboara SCL si trece la bitul urmator

typedef enum logic [2:0] {
    IDLE,       // bus liber
    START,      // cond start
    HOLD,       // asteptare urm comanda
    WRITE,      // trimite cei 8 biti
    WRITE_ACK,  // elibereaza sda si citeste confirmarea slave
    READ,       // primeste cei 8 biti de la slave
    READ_ACK,   // dupa citirea unui byte, master transmite ack sau nack
    STOP        // cond stop
} i2c_state_t;

i2c_state_t current_state;

integer contor_clk;

logic faza_tick;
logic [1:0] faza;
logic [2:0] bit_index;

logic [7:0] date_tx;
logic [7:0] date_rx;

logic nack;     // nack = 0 -> masterul trim ACK | nack = 1 -> masterul trim NACK

assign faza_tick = (contor_clk == DIVIDER - 1);
assign ready = (current_state == IDLE)||(current_state == HOLD);

always @(posedge clk) begin
    if (rst) begin
        current_state <= IDLE;
        contor_clk <= 0;
        faza <= PHASE_0;
        bit_index <= 0;
        date_tx <= 0;
        date_rx <= 0;
        scl <= 1'b1;
        sda_out <= 1'b1;
        dout <= 0;
        ack <= 1'b0;
        nack <= 1'b0;
        done <= 1'b0;
    end
    else begin
        done <= 1'b0;
        if (faza_tick)
            contor_clk <= 0;
        else
            contor_clk <= contor_clk + 1;

        case (current_state)

            IDLE: begin
                scl <= 1'b1;
                sda_out <= 1'b1;
                faza <= PHASE_0;
                
                if (cmd_start && cmd == CMD_START) begin
                    contor_clk <= 0;
                    current_state <= START;
                end
            end

            START: begin
                if (faza_tick) begin
                
                    case (faza)
                        PHASE_0: begin
                            scl <= 1'b1;
                            sda_out <= 1'b1;
                            faza <= PHASE_1;
                        end

                        PHASE_1: begin
                            scl <= 1'b1;
                            sda_out <= 1'b0;
                            faza <= PHASE_2;
                        end

                        PHASE_2: begin
                            scl <= 1'b1;
                            sda_out <= 1'b0;
                            faza <= PHASE_3;
                        end

                        PHASE_3: begin
                            scl <= 1'b0;
                            sda_out <= 1'b0;
                            faza <= PHASE_0;
                            done <= 1'b1;
                            current_state <= HOLD;
                        end

                    endcase
                end
            end

            HOLD: begin
                scl <= 1'b0;
                sda_out <= 1'b1;
                faza <= PHASE_0;
                
                if (cmd_start) begin
                    contor_clk <= 0;

                    case (cmd)

                        CMD_START: begin
                            current_state <= START;
                        end

                        CMD_WRITE: begin
                            date_tx <= din;
                            bit_index <= 3'd7;
                            ack <= 1'b0;
                            current_state <= WRITE;
                        end

                        CMD_READ_ACK: begin         // se preg receptionare byte
                            date_rx <= 0;
                            bit_index <= 3'd7;
                            nack <= 1'b0;           // masterul trimite ACK
                            current_state <= READ;
                        end

                        CMD_READ_NACK: begin        // se citeste byte
                            date_rx <= 0;
                            bit_index <= 3'd7;
                            nack <= 1'b1;           // masterul trimite NACK
                            current_state <= READ;
                        end

                        CMD_STOP: begin
                            current_state <= STOP;
                        end

                        default: begin
                            current_state <= HOLD;
                        end

                    endcase
                end
            end

            WRITE: begin
                if (faza_tick) begin
                
                    case (faza)

                        PHASE_0: begin
                            scl <= 1'b0;
                            sda_out <= date_tx[bit_index];
                            faza <= PHASE_1;
                        end

                        PHASE_1: begin
                            scl <= 1'b1;
                            faza <= PHASE_2;
                        end

                        PHASE_2: begin
                            scl <= 1'b1;
                            faza <= PHASE_3;
                        end

                        PHASE_3: begin
                            scl <= 1'b0;
                            faza <= PHASE_0;
                            if (bit_index == 0)
                                current_state <= WRITE_ACK;
                            else
                                bit_index <= bit_index - 1'b1;
                        end

                    endcase
                end
            end

            WRITE_ACK: begin
                if (faza_tick) begin

                    case (faza)

                        PHASE_0: begin
                            scl <= 1'b0;
                            sda_out <= 1'b1;
                            faza <= PHASE_1;
                        end

                        PHASE_1: begin
                            scl <= 1'b1;
                            faza <= PHASE_2;
                        end

                        PHASE_2: begin
                            scl <= 1'b1;
                            ack <= !sda_in;
                            faza <= PHASE_3;
                        end

                        PHASE_3: begin
                            scl <= 1'b0;
                            faza <= PHASE_0;
                            done <= 1'b1;
                            current_state <= HOLD;
                        end

                    endcase
                end
            end

            READ: begin
                if (faza_tick) begin
                
                    case (faza)

                        PHASE_0: begin
                            scl <= 1'b0;
                            sda_out <= 1'b1;
                            faza <= PHASE_1;
                        end

                        PHASE_1: begin
                            scl <= 1'b1;
                            faza <= PHASE_2;
                        end

                        PHASE_2: begin
                            scl <= 1'b1;
                            date_rx[bit_index] <= sda_in;
                            faza <= PHASE_3;
                        end

                        PHASE_3: begin
                            scl <= 1'b0;
                            faza <= PHASE_0;

                            if (bit_index == 0) begin
                                dout <= date_rx;
                                current_state <= READ_ACK;
                            end
                            else begin
                                bit_index <= bit_index - 1'b1;
                            end
                        end

                    endcase
                end
            end

            READ_ACK: begin
                if (faza_tick) begin
                
                    case (faza)

                        PHASE_0: begin
                            scl <= 1'b0;
                            if (nack)
                                sda_out <= 1'b1;
                            else
                                sda_out <= 1'b0;
                            faza <= PHASE_1;
                        end

                        PHASE_1: begin
                            scl <= 1'b1;
                            faza <= PHASE_2;
                        end

                        PHASE_2: begin
                            scl <= 1'b1;
                            faza <= PHASE_3;
                        end

                        PHASE_3: begin
                            scl <= 1'b0;
                            sda_out <= 1'b1;
                            faza <= PHASE_0;
                            done <= 1'b1;
                            current_state <= HOLD;
                        end

                    endcase
                end
            end

            STOP: begin
                if (faza_tick) begin
                
                    case (faza)

                        PHASE_0: begin
                            scl <= 1'b0;
                            sda_out <= 1'b0;
                            faza <= PHASE_1;
                        end

                        PHASE_1: begin
                            scl <= 1'b1;
                            sda_out <= 1'b0;
                            faza <= PHASE_2;
                        end

                        PHASE_2: begin
                            scl <= 1'b1;
                            sda_out <= 1'b1;
                            faza <= PHASE_3;
                        end

                        PHASE_3: begin
                            scl <= 1'b1;
                            sda_out <= 1'b1;
                            faza <= PHASE_0;
                            done <= 1'b1;
                            current_state <= IDLE;
                        end

                    endcase
                end
            end

            default: begin
                current_state <= IDLE;
                scl <= 1'b1;
                sda_out <= 1'b1;
                faza <= PHASE_0;
            end

        endcase
    end
end

endmodule
