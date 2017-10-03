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
    inout [7:0]pio //outputs
    );
    wire lite, ccs, dc, rst, tcs, si, so, sck;
    
    assign pio[6:0] = {sck,si,tcs,rst,dc,ccs,lite};
    assign so = pio[7];
    
    //make the main clock:
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
    
    reg [23:0] r;

        always @(posedge clock_30mhz)
            begin
                if(btn[0] == 1)
                    r <= 0;
                else
                    r <= r + 1;
            end
       
        assign led0_r =1'b1; //r[20]?1'b1:1'b0;   //6hz 25% pwm
        assign led0_g =1'b1; //r[21]?1'b1:1'b0;   //12hz
        assign led0_b =r[22]?1'b1:1'b0;  //3Hz
        assign led = r[23];

    
    //------------------------
    //----------------------
    assign lite = 1'b0;   
    
    
    //wires for the spi master
    wire [2:0] selection; //selection control
    wire [7:0] data_to_send; //data we'd like to send out
    wire [7:0] data_received;
    wire new_data; //new data is present!
    wire [7:0] chip_selects;
    wire [15:0] bytes_to_send; //number of bytes to send (can be huge)
    

    assign dc = 1'b1;
    
    
    wire trigger; //used to trigger spi;
    assign selection = 3'b0; //selecting only zero ones
    
    assign bytes_to_send = 16'b1; //just set to send one byte;
    
    assign data_to_send = 8'b0;
    
    assign tcs = chip_selects[0];
    assign ccs = chip_selects[1];
    
    spi_master spm(.sysclk(clock_30mhz),.ss(selection),.data_in(data_to_send),
    .how_many_bytes(bytes_to_send), .new_data(new_data), .cs(chip_selects),
    .mosi(si),
    .miso(so),
    .sck(sck),
    .rst(rst),
    .trigger(trigger));
    
    
    ///logic analyzer below:
    ila_0 myila(.clk(sysclk),.probe0(sck),
     .probe1(si), .probe2(so),.probe3(ccs),
     .probe4(new_data), .probe5(trigger));
    
        
    
endmodule
