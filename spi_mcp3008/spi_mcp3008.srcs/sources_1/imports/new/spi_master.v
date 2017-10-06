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
// Revision 0.03 core functionality working
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//Version 2...you need your sysclk to be 2 times SCLK speed!
module spi_master(input sysclk,
    input [2:0] ss, //for selecting slaves from input side
    input [7:0] data_in, 
    input [15:0] how_many_bytes, //if we want repeated reading...or writing..how long of a continuous are we going to deal with
    input miso,
    output reg sck,
    output reg mosi,
    output reg [7:0] cs, //for selecting slaves on output side (one hot wiring)
    output reg [7:0] data_out,
    output reg busy, 
    output reg new_data,
	output reg load,
    input rst,
    input trigger //active high
    );
	 reg [7:0] buffer_in; //buffer for data to be received from slave (and sent "out" to user)

    reg [7:0] buffer_out; //"buffer for data to be sent to slave
    //output reg [7:0] buffer_in; //buffer for data to be received from slave (and sent "out" to user)
    localparam IDLE = 4'h0,
        PRERUN1 = 4'h1,
        PRERUN2 = 4'h2,
        RUN = 4'h3,
        FINISH = 4'h4;
        
    reg [15:0] bytes_to_run;
    reg [15:0] byte_count;
    reg [4:0] state;
    reg [3:0] count;
    

    always @(posedge sysclk) begin
        if (rst)begin
            state <= IDLE;//simply return to idle..abandon all hope
        end else begin 
			  case (state)
					IDLE: begin
						 sck <= 1'b0; //always assume we are this in IDLE!
						 if (trigger)begin
							  buffer_out <= data_in;
							  buffer_in<= 8'b0;
							  bytes_to_run <= how_many_bytes;
							  cs <= ~(8'b1<<(ss)); //pull sel down, leave others up
							  data_out <= 8'b0; //empty output register
							  count <= 3'b0; //reset count
							  state <= PRERUN1; //move onto PRERUN
							  busy <= 1'b1;
							  new_data <= 1'b0;
							  byte_count <= 16'b0;
							  load <=1'b0;
						 end else begin
							  cs <= ~(8'b0);  //all high in rest state
							  mosi <= 1'b0;  //all low in rest state
							  busy <= 1'b0;//low for busy
							  load <= 1;
							  new_data <= 1'b0;
							  //and remain in IDLE
						 end
					end 
					PRERUN1: begin
						 sck <= 1'b0; //register
						 buffer_out <= {buffer_out[6:0],1'b0}; //push new data in now that both sides have measured
						 mosi <= buffer_out[7]; //new value on mosi
						 count <= count +1;
						 state <= PRERUN2;
					end
					PRERUN2: begin
						 sck <= 1'b1;
						 state <= RUN;
					end
					RUN: begin
						 if (sck)begin //about to be on rising edge!
						     buffer_in <= {miso,buffer_in[7:1]};//take a measurement and shove in
							  if (count == 4'd8)begin //we've read 8 bits in...time to decide are we done or keep goin!
							      new_data <= 1'b1;  //set the new data flag!
							      data_out <= {miso,buffer_in[7:1]}; //load the data_out with what is in buffer_in (from the slave)
							      if (byte_count +1'b1 == bytes_to_run)begin  //we done
						             sck <= 1'b0; //clock can shut off.
				                   state <= FINISH; //we've run the number of bits we needed!
							      end
							      else begin
											buffer_out <= {data_in[6:0],1'b0}; //grab fresh set of data
											mosi <= data_in[7]; //new value on mosi
					                 count <= 3'b1;
										  byte_count <= byte_count +1'b1; //one more byte!
										  state <= RUN; //not needed, but for clarity
									     sck <= ~sck; //keep going, child.
									 end
								 end
								else begin
									buffer_out <= {buffer_out[6:0],1'b0}; //push new data in now that both sides have measured
									mosi <= buffer_out[7]; //new value on mosi
									sck <= ~sck; //keep clock on
									count <= count +1;
									new_data <= 1'b0; //deassert new_data (usually keeps at 0...coming from a 
								end
							end
							else begin
								sck= ~sck;
							end
					end
					FINISH: begin
						 cs <= ~(8'b0);
						 state <= IDLE;
					end
				endcase
			end
		end
endmodule

//minimal only in charge of 
/*
module spi_write_1_byte(input clock, input 
    output reg dev_trigger,
    output reg done);
    reg [3:0] state;
    localparam IDLE = 4'h0,
    localparam START1 = 4'h1;
    localparam RUN1
    always @(posedge fastclk)begin
            if (clock_25mhz)begin
                case(state)
                    IDLE: begin
                        dc <= 1'b1;
                        trigger <= 1'b0;
                        rst <=1 1'b0;
                        if(btn[1] == 1)begin
                            selection <= 3'b0; //pick device 0
                            bytes_to_send <= 16'b1; //send one byte
                            data_to_send <= SWRESET;
                            state <= START1;
                    end
                    START1: begin
                        trigger<=1'b1;
                        state <= RUN1
                        pause_counter <= 24'b0;
                    end
                    RUN1:begin
                        trigger <=1'b0;
                        if (data
                    end
                    PAUSE1:begin
                        if (&pause_counter)begin
                            state <= START2;
                            data_to_send <= SLPOUT;
                        end else begin
                            pause_counter <= pause_counter +1;
                        end
                    end
                    START2: begin
                        trigger <=1 1'b1;
                        state <= RUN2;
                endcase
            end
     end
endmodule
*/
