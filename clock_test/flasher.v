`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2017 06:34:40 PM
// Design Name: 
// Module Name: flasher
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


module flasher(
    input wire sysclk,
    input [1:0]btn,   // Button inputs
    output [1:0]led,  // Led outputs
    output led0_b, //blue led output
    output led0_g, //green led output
    output led0_r //red led output
    );
    reg [23:0] r;
    
    always @(posedge sysclk)
        begin
            if(btn[0] == 1)
                r <= 0;
            else
                r <= r + 1;
        end
   
    assign led0_r =r[20]?1'b1:1'b0;   //6hz 25% pwm
    assign led0_g =r[21]?1'b1:1'b0;   //12hz
    assign led0_b =r[22]?1'b1:1'b0;  //3Hz
    assign led = r[23];
endmodule
