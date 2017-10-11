`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/04/2017 04:50:44 PM
// Design Name: 
// Module Name: dimmer
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


module dimmer(input clock,
    input [7:0] brightness,
    output driver
    );
    
    reg [7:0]counter;
    always @(posedge clock)begin
        counter<= counter+1;
    end
    assign driver= counter<brightness?1'b1:1'b0;
endmodule
