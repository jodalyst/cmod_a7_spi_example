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
    inout [12:0]pio //outputs
    );
    wire lite, ccs, dc, rst, tcs, si, so, sck;
    
    reg [7:0] brightness;
    assign pio[6:0] = {sck,si,tcs,rst,dc,ccs,lite};
    assign so = pio[7];
    
    reg dc_reg;
    assign dc = dc_reg;
    
    //make the main clock:
    reg [1:0] clock_counter;
    reg [2:0] slow_clock_counter;
    wire clock_25mhz;
    wire clock_125mhz;
    wire rst;
    wire fastclk;
    assign rst = 1'b0;
    
    reg rst_reg;
    assign rst = rst_reg;
    
    clk_wiz_0 cw(.clk_out1(fastclk),.reset(rst), .clk_in1(sysclk));
    always @(posedge fastclk)begin
        if (clock_counter == 2'b11) clock_counter <= 2'b00;
        else clock_counter <= clock_counter +1;
        if (slow_clock_counter==3'b111) slow_clock_counter <= 3'b000;
        else slow_clock_counter <= slow_clock_counter +1;
    end
    assign clock_25mhz = &clock_counter;
    assign clock_125mhz = &slow_clock_counter;
    assign led[1] = clock_25mhz;
    //led flashing "heartbeat" code...
    reg [23:0] r;
    always @(posedge clock_25mhz)
        begin
            if(btn[0] == 1)
                r <= 0;
            else
                r <= r + 1;
            if (&r) brightness<=brightness +1;
        end
   
    assign led0_r =1'b1; //r[20]?1'b1:1'b0;   //6hz 25% pwm
    assign led0_g =1'b1; //r[21]?1'b1:1'b0;   //12hz
    assign led0_b =r[22]?1'b1:1'b0;  //3Hz
    assign led[0] = r[23];
    //assign pio[8] = r[23];
    reg led_out_reg;
    assign pio[8] = btn[1];
    //------------------------
    //----------------------
    //assign lite = 1'b0;
    dimmer lcd_dimmer(.clock(fastclk), .brightness(brightness),.driver(lite));

    
    //wires for the spi master
    //wire [2:0] selection; //selection control
    //wire [7:0] data_to_send; //data we'd like to send out
    wire [7:0] data_received;
    wire new_data; //new data is present!
    wire spi_busy;
    
    reg trigger; //used to trigger spi;
    reg [2:0] selection; //which device to pick
    reg [15:0] bytes_to_send; //number of bytes to send
    reg [7:0] data_to_send; //data to send out
    wire [7:0] chip_selects; ///chip selects
    assign tcs = chip_selects[0]; //tft chip select
    assign ccs = chip_selects[1]; //card reader chip select
    
    spi_master spm(.sysclk(clock_25mhz),.ss(selection),.data_in(data_to_send),
    .how_many_bytes(bytes_to_send), .new_data(new_data), .cs(chip_selects),
    .mosi(si),
    .miso(so),
    .sck(sck),
    .rst(rst),
    .busy(spi_busy),
    .trigger(trigger));
    
    assign pio[12:9] = state;
    reg [3:0] state;
    localparam IDLE = 4'hA;
    localparam START1 = 4'h1;
    localparam RUN1 = 4'h2;
    localparam PAUSE1 = 4'h3;
    localparam START2 = 4'h4;
    localparam RUN2 = 4'h5;
    localparam PAUSE2 = 4'h6;
    localparam START3 = 4'h7;
    localparam RUN3 = 4'h8;
    localparam PAUSE3 = 4'h9;
    
    reg [23:0] pause_counter;
    
    localparam SWRESET = 8'h01; //software reset
    localparam SLPOUT = 8'h11; //sleep out
    localparam DISPON = 8'h29; //display turn on
    localparam CASET = 8'h2A; //set column
    localparam RASET = 8'h2B; //set row
    localparam RAMWR = 8'h2C; //ramwrite
    localparam MADCTL = 8'h36; //axis control
    localparam COLMOD = 8'h3A; //colormode;
    always @(posedge fastclk)begin
        if (clock_125mhz)begin
            case(state)
                IDLE: begin
                    led_out_reg <= 1'b0;
                    dc_reg <= 1'b1;
                    trigger <= 1'b0;
                    rst_reg <=1'b0;
                    if(btn[1] == 1)begin
                        selection <= 3'b0; //pick device 0
                        bytes_to_send <= 16'b1; //send one byte
                        data_to_send <= SWRESET;
                        state <= START1;
                    end
                end
                START1: begin
                    trigger<=1'b1;
                    if (~new_data && spi_busy) begin
                        state <= RUN1;
                    end
                    state <= RUN1;
                    pause_counter <= 24'b0;
                end
                RUN1:begin
                    trigger <=1'b0;
                    if (new_data) state <= PAUSE1;
                end
                PAUSE1:begin
                    if (&pause_counter)begin //wait until pause is done
                        state <= START2;
                        data_to_send <= SLPOUT;
                    end else begin
                        pause_counter <= pause_counter +1;
                    end
                end
                START2: begin
                    trigger <=1'b1;
                    if (~new_data && spi_busy) begin
                        state <= RUN2;
                    end
                end
                RUN2: begin
                   trigger <=1'b0;
                   pause_counter <= 24'b0;
                   if (new_data) state <= PAUSE2;
                   
                end
                PAUSE2: begin
                    if (&pause_counter)begin //wait until pause is done
                        state <= START3;
                        data_to_send <= DISPON;
                    end else begin
                        pause_counter <= pause_counter +1;
                    end
                end
                START3: begin
                    trigger <=1'b1;
                    if (~new_data & spi_busy) begin
                        state <= RUN3;
                    end
                end
                RUN3: begin
                   trigger <=1'b0;
                   pause_counter <= 24'b0;
                   if (new_data) state <= IDLE; 
                end
                default:
                    state <= IDLE;
            endcase
        end
    end
                
                
    
    
    ///logic analyzer below:
    //ila_0 myila(.clk(sysclk),.probe0(sck),
    // .probe1(si), .probe2(so),.probe3(ccs),
    // .probe4(new_data), .probe5(trigger));
    
        
    
endmodule
