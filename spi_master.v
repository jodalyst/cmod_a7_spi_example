`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: jodalyst
// Engineer: jodalyst
// 
// Create Date: 09/26/2017 07:38:04 PM
// Design Name: SPI_master module
// Module Name: spi_master
// Project Name:  SPI_demo
// Target Devices:  Artix-7 on CMOD A7-35T by Digilent
// Tool Versions:  Vivado
// Description: 
// 
// Dependencies:  On CMOD by Digilent this thing needs a faster clock than what it comes with
// in order to be able to run in worthwhile SPI clock domains, so you'll need to use a clock
// multiplier from 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//I'm the SPI-Fucking Master
//sysclk for spi_master must be twice the desired SPI clock rate!
module spi_master(input sysclk,
    input [2:0] ss, //for selecting slaves from input side
    input [7:0] data_in, 
    input miso,
    output reg sck,
    output reg mosi,
    output reg [7:0] cs, //for selecting slaves on output side (one hot wiring)
    output reg [7:0] data_out,
    output busy, 
    output new_data,
    input rst,
    input trigger, //active high
    );

    reg [7:0] buffer_out;
    reg [7:0] buffer_in;

    localparam IDLE = 4'h0,
        RUN = 4'h1,
        
        
    reg [4:0] state;
    reg [3:0] count;

    always @(posedge sysclk) begin
        case (state)
            IDLE: begin
                if (trigger)begin
                    buffer_out <= data_in;
                    cs <= ~(8'b1<<(ss)); //pull sel down, leave others up
                    sck <= 1'b0;
                    count <= 3'b0; //reset count
                    state <= RUN;                     
                end else begin
                    cs <= 8'b1;  //all high in rest state
                    sck <= 1'b0; //low in rest state
                    mosi <= 1'b0;  //all low in rest state
                    //and remain in IDLE
                end
            end 
            RUN: begin
                sck <= ~sck; 
                if (~sck)begin
                    buffer_out <= {1'b0,buffer_out[7:1]};
                    mosi <= buffer_out[0];
                    count <= count +1;
                    




            end



    end
endmodule
