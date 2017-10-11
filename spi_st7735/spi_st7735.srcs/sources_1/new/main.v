`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2017 09:56:01 AM
// Design Name: 
// Module Name: main
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



module main(input wire sysclk,
    input [1:0]btn,   // Button inputs
    output [1:0]led,  // Led outputs
    output led0_b, //blue led output
    output led0_g, //green led output
    output led0_r, //red led output
    inout [12:0]gpio //outputs
    );
    wire lite, ccs, dc, rst, tcs, mosi, miso, sck;
    
    
    parameter commwidth = 48;
    assign gpio[6:0] = {sck,mosi,tcs,rst,dc,ccs,lite};
    assign miso = gpio[7];
    
    //Clock generation:
    wire clock_24mhz;
    clk_wiz_0 cg(.clk_in1(sysclk),.reset(1'b0),.clk_out1(clock_24mhz));
    
    //LCD dimmer control:
    wire [7:0] brightness = 8'd127;
    dimmer lcd_dimmer(.clock(clock_24mhz), .brightness(brightness),.driver(lite));
    
    wire [commwidth-1:0] data_received;
    wire new_data; //new data is present!
    wire spi_busy;
    reg trigger; //used to trigger spi;
    reg [7:0] sub_size;
    reg [2:0] selection; //which device to pick
    reg [15:0] frames_to_send; //number of bytes to send
    reg [commwidth-1:0] data_to_send; //data to send out
    reg rst_reg;
    assign rst = rst_reg;
    reg dc_reg;
    assign dc = dc_reg;
    wire [7:0] chip_selects; ///chip selects
    assign tcs = chip_selects[0]; //tft chip select
    
     spi_master #(.INOUTWIDTH(commwidth)) spm(.sysclk(sysclk),.ss(selection),.data_to_send(data_to_send),
    .how_many_frames(frames_to_send), .sub_size(sub_size), .new_data(new_data), .cs(chip_selects), .data_in(data_received),
    .mosi(mosi),
    .miso(miso),
    .sck(sck),
    .rst(rst),
    .busy(spi_busy),
    .trigger(trigger));

    
    reg [23:0] pause_counter;
    
    reg [3:0] state;
    localparam IDLE = 4'h0;
    localparam SETUP1 = 4'h1;
    localparam SETUP2 = 4'h2;
    localparam SETUP3 = 4'h3;
    localparam SETUP4 = 4'h4;
    localparam SETUP5 = 4'h5;
    localparam SETUP6 = 4'h6;
    localparam SETUP7 = 4'h7;
    localparam SETUP8 = 4'h8;
    localparam SETUP9 = 4'h9;
    localparam DRAW1 = 4'hA;
    localparam DRAW2 = 4'hB;
    localparam DRAW3 = 4'hC;
    
    
    localparam SWRESET = 8'h01; //software reset
    localparam SLPOUT = 8'h11; //sleep out
    localparam DISPON = 8'h29; //display turn on
    localparam CASET = 8'h2A; //set column
    localparam RASET = 8'h2B; //set row
    localparam RAMWR = 8'h2C; //ramwrite
    localparam MADCTL = 8'h36; //axis control
    localparam COLMOD = 8'h3A; //colormode;
    localparam RDDID = 8'h04;
    localparam RDDPM = 8'h0A; //Powermode
    
    always @(posedge sysclk)begin
            case(state)
                IDLE: begin
                    if(btn[1] == 1)begin
                        rst_reg <= 1'b0;
                        sub_size <= 8'd8;
                        selection <= 3'b0; //pick device 0
                        frames_to_send <= 16'd1; //send two bytes and read one byte
                        data_to_send <= SWRESET;
                        state <= SETUP1;
                    end else if(btn[0]==1)begin
                        rst_reg <= 1'b0;
                        sub_size <= 0;
                        selection <=3'b0;
                        frames_to_send <= 16'd1;
                        state <= DRAW1;
                    end
                    else begin
                        trigger <= 1'b0;
                    end
                end
                SETUP1: begin
                   trigger<=1'b1;
                   if (~new_data && spi_busy) begin
                       state <= SETUP2;
                   end                  
                   pause_counter <= 24'b0;
                   end
                SETUP2:begin
                   trigger <=1'b0;
                   if (new_data) state <= SETUP3; //DONE!
                   end
                SETUP3:begin
                   if (&pause_counter)begin //wait until pause is done
                       state <= SETUP4;
                       data_to_send <= SLPOUT;
                   end else begin
                       pause_counter <= pause_counter +1;
                   end
                   end
                SETUP4: begin
                   trigger <=1'b1;
                   if (~new_data && spi_busy) begin
                       state <= SETUP5;
                   end
                   end
                SETUP5: begin
                  trigger <=1'b0;
                  pause_counter <= 24'b0;
                  if (new_data) state <= SETUP6;
                   end
                SETUP6: begin
                   if (&pause_counter)begin //wait until pause is done
                       state <= SETUP7;
                       data_to_send <= DISPON;
                   end else begin
                       pause_counter <= pause_counter +1;
                   end
                end
                SETUP7: begin
                   trigger <=1'b1;
                   if (~new_data & spi_busy) begin
                       state <= SETUP8;
                   end
                end
                SETUP8: begin
                      trigger <=1'b0;
                      pause_counter <= 24'b0;
                      if (new_data) state <= SETUP9; 
                   end
                SETUP9: begin
                   if (&pause_counter)begin //wait until pause is done
                       state <= IDLE;
                       dc_reg<= 1'b1;
                   end else begin
                       pause_counter <= pause_counter +1;
                   end
                end
                DRAW1: begin
                    trigger<=1'b1;
                    if (~new_data && spi_busy) begin
                        state <= DRAW2;
                    end
                    //state <= RW1;
                end   
                DRAW2: begin
                    trigger<=1'b1;
                    if (~new_data && spi_busy) begin
                        state <= DRAW2;
                    end
                    //state <= RW1;
                end
                DRAW3:begin
                    trigger <=1'b0;
                    if (new_data)begin
                        state <= IDLE;
                    end
                end
                default:
                    state <= IDLE;
            endcase
        end
endmodule
