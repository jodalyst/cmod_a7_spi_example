`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2017 04:20:10 PM
// Design Name: 
// Module Name: main_sys_tb
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


module main_sys_tb;

    reg sysclk;
    reg [1:0] btn;
    wire g;
    wire [1:0]led;  // Led outputs
    wire led0_b; //blue led output
    wire led0_g; //green led output
    wire led0_r; //red led output
    

    main_system uut(.sysclk(sysclk), .btn(btn), .g({sck,miso,mosi,cs}), .led(led),.led0_b(led0_b),
    .led0_g(led0_g), .led0_r(led0_r));

    always #5 sysclk =!sysclk;
	initial begin
	   sysclk = 0;
	   btn[0] = 0;
	   btn[1] = 0;
	   //miso = 0;
	   #100;
	   btn[1] = 1;
	   #200;
	   btn[0] = 0;
	   #2000;
	end




endmodule
