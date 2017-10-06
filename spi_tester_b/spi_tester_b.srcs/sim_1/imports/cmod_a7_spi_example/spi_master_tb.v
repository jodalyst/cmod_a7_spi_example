`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:06:35 09/28/2017
// Design Name:   spi_master
// Module Name:   /afs/athena.mit.edu/user/j/o/jodalyst/6111work/spi_dev/spi_master_tb.v
// Project Name:  spi_dev
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: spi_master
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module spi_master_tb;

	// Inputs
	reg sysclk;
	reg [2:0] ss;
	reg [7:0] data_in;
	reg [15:0] how_many_bytes;
	reg miso;
	reg rst;
	reg trigger;

	// Outputs
	wire sck;
	wire mosi;
	wire [7:0] cs;
	wire [7:0] data_out;
	wire busy;
	wire new_data;
	wire spi_busy;

	// Instantiate the Unit Under Test (UUT)
	spi_master uut (
		.sysclk(sysclk), 
		.ss(ss), 
		.data_in(data_in), 
		.how_many_bytes(how_many_bytes), 
		.miso(miso), 
		.sck(sck), 
		.mosi(mosi), 
		.cs(cs), 
		.data_out(data_out), 
		.busy(busy), 
		.new_data(new_data), 
		.rst(rst), 
		.trigger(trigger)
	);

	always #10 sysclk =!sysclk;
	initial begin
		// Initialize Inputs
		sysclk = 0;
		ss = 0;
		data_in = 0;
		how_many_bytes = 0;
		miso = 0;
		rst = 0;
		trigger = 0;

		// Wait 100 ns for global reset to finish
		#100;
      rst = 1;
		#50;
		rst = 0;
		ss = 3'b000;
		
		data_in = 8'h01;
		how_many_bytes = 1;
		#30;
		trigger=1;
		#30;
		trigger=0;
		#800;
		data_in = 8'h11;
		#30;
		trigger = 1;
		#20;
		trigger=0;
		data_in = 8'h29;
		#800;
		trigger = 1;
		#30;
		trigger=0;
		#800;
		
		miso= 0;
		#90;
		miso=1;
		#200;
		miso=0;
		#100;
		miso=1;
		#150;
		miso=0;
		#30;
		miso=1;
		#200;
		miso=0;
		#2000;
		// Add stimulus here

	end
      
endmodule

