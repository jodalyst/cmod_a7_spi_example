`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2017 09:00:59 PM
// Design Name: 
// Module Name: main_system
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


module main_system(input wire sysclk,
    input [1:0]btn,   // Button inputs
    output [1:0]led,  // Led outputs
    output led0_b, //blue led output
    output led0_g, //green led output
    output led0_r, //red led output
    output [8:1]pio
    );
    wire lite, ccs, dc, rst, tcs, si, so, sck;
    
    assign pio[8:1] = {lite, ccs, dc, rst, tcs, si, so, sck};
    reg [4:0] clock_counter;
    wire clock_30mhz;
    wire rst;
    wire fastclk;
    clk_wiz_0 cw(.clk_out1(fastclk),.reset(rst), .clk_in1(sysclk));
    always @(posedge fastclk)begin
        clock_counter <= clock_counter +1;
        if (clock_counter == 4'b1111) clock_counter <= 4'b0;
    end
    assign clock_30mhz = clock_counter==&clock_counter;
        
    
endmodule
