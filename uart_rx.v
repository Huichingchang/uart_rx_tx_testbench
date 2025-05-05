`timescale 1ns/1ps
module uart_rx (
    input wire clk,
    input wire rst,
    input wire rx,
    output reg [7:0] data_out,
    output reg done
);
    parameter IDLE = 3'd0;
    parameter START = 3'd1;
    parameter DATA = 3'd2;
    parameter STOP = 3'd3;
    parameter DONE_STATE = 3'd4;

    reg [2:0] state;
    reg [3:0] sample_cnt;
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            sample_cnt <= 0;
            bit_cnt <= 0;
            shift_reg <= 0;
            data_out <= 0;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (~rx) begin
                        state <= START;
                        sample_cnt <= 0;
                    end
                end

                START: begin
                    sample_cnt <= sample_cnt + 1;
                    if (sample_cnt == 7) begin
                        if (~rx) begin
                            state <= DATA;
                            sample_cnt <= 0;
                            bit_cnt <= 0;
                        end else begin
                            state <= IDLE;
                        end
                    end
                end

                DATA: begin
                    sample_cnt <= sample_cnt + 1;
                    if (sample_cnt == 15) begin
                        shift_reg <= {rx, shift_reg[7:1]};
                        bit_cnt <= bit_cnt + 1;
                        sample_cnt <= 0;
                        if (bit_cnt == 7)
                            state <= STOP;
                    end
                end

                STOP: begin
                    sample_cnt <= sample_cnt + 1;
                    if (sample_cnt == 15) begin
                        if (rx) begin
                            data_out <= shift_reg;
                            done <= 1;
                        end
                        state <= DONE_STATE;
                        sample_cnt <= 0;
                    end
                end

                DONE_STATE: begin
                    state <= IDLE;
                    done <= 0;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
