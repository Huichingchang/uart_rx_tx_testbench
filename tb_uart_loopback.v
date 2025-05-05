`timescale 1ns/1ps
module tb_uart_loopback;

	reg clk;
	reg rst;
	reg tx_start;
	reg [7:0] data_in;
	wire tx;
	wire rx;
	wire busy;
	wire [7:0] data_out;
	wire done;
	
	// Clock generation: 100MHz = 10ns period
	always #5 clk = ~clk;
	
	// Instantiate uart_tx
	uart_tx u_tx (
		.clk(clk),
		.rst(rst),
		.tx_start(tx_start),
		.data_in(data_in),
		.tx(tx),
		.busy(busy)
	);
	
	// Loopback line
	assign rx = tx;
	
	// Instantiate uart_rx
	uart_rx u_rx (
		.clk(clk),
		.rst(rst),
		.rx(rx),
		.data_out(data_out),
		.done(done)
	);
		
   initial begin
		clk = 0;
		rst = 1;
		tx_start = 0;
		data_in = 8'h00;
	
		#100; // wait for reset deassertion
		rst = 0;
		
		#50;
		data_in = 8'hA5;
		tx_start = 1;
		
		#10;
		tx_start = 0;
		
		// wait for rx done
		wait (done == 1);
		
		#100;
		$finish;
	end
endmodule