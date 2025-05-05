`timescale 1ns/1ps
module uart_tx(
	input wire clk, //系統時脈
	input wire rst, //非同步重置信號
	input wire tx_start, //啟動傳送
	input wire [7:0] data_in, //要傳送的資料
	output reg tx, //傳送的UART訊號
	output reg busy //傳送中旗標
); 
	
	//狀態定義
	parameter IDLE = 3'b000;
	parameter START = 3'b001;
	parameter DATA = 3'b010;
	parameter STOP = 3'b011;
	parameter DONE = 3'b100;
	
	reg [2:0] state;
	reg [3:0] bit_cnt; //資料位元計數器
	reg [7:0] shift_reg; //暫存傳送資料
	reg [3:0] baud_cnt; //控制傳送間隔(假設16個clk pre bit)
	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state <= IDLE;
			tx <= 1'b1; // TX閒置為高
			busy <= 0;
			bit_cnt <= 0;
			shift_reg <= 0;
			baud_cnt <= 0;
			
		end else begin
			case (state)
				IDLE: begin
					tx <= 1'b1;
					busy <= 0;
						if (tx_start) begin
							shift_reg <= data_in;
							state <= START;
							busy <= 1;
							baud_cnt <= 0;
						end
				end
				
				START: begin
					tx <= 1'b0;
					if (baud_cnt == 15) begin
						baud_cnt <= 0;
						bit_cnt <= 0;
						state <= DATA;
					end else begin
						baud_cnt <= baud_cnt + 1;
					end
				end
				
				DATA: begin
					tx <= shift_reg[bit_cnt];
					if (baud_cnt ==15) begin
						baud_cnt <= 0;
						if (bit_cnt == 7)
							state <= STOP;
						else
							bit_cnt <= bit_cnt + 1;
					end else begin
							baud_cnt <= baud_cnt + 1;
					end
				end
				
				STOP: begin
					tx <= 1'b1;
					if (baud_cnt == 15) begin
						baud_cnt <= 0;
						state <= DONE;
					end else begin
						baud_cnt <= baud_cnt + 1;
					end
				end
				
				DONE: begin
					state <= IDLE;
				end
				default: state <= IDLE;
			endcase
		end
		
	end
endmodule	