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
    inout [3:0]g //inouts (see xdc file)
    );
    wire cs, mosi,miso,sck; //chip select, si, so, sck
        
    assign g[3:0] = {sck,miso,mosi,cs}; //link pins to wires with understandable names



    //some random heartbeat crap for LEDs to know it is uploading    
    assign led[1] = sysclk;
    //led flashing "heartbeat" code...
    reg [23:0] r;
    always @(posedge sysclk)
        begin
            if(btn[0] == 1)
                r <= 0;
            else
                r <= r + 1;
            if (&r) brightness<=8'd127;
        end
    assign led0_r =1'b1; //r[20]?1'b1:1'b0;   //6hz 25% pwm
    assign led0_g =1'b1; //r[21]?1'b1:1'b0;   //12hz
    assign led0_b =r[22]?1'b1:1'b0;  //3Hz
    assign led[0] = r[23];
    //assign pio[8] = r[23];
    //done
    
    

    wire [7:0] data_received;
    wire new_data; //new data is present!
    wire spi_busy;
    reg trigger; //used to trigger spi;
    reg [2:0] selection; //which device to pick
    reg [15:0] bytes_to_send; //number of bytes to send
    reg [7:0] data_to_send; //data to send out
    wire [7:0] chip_selects; ///chip selects
    assign cs = chip_selects[0]; //tft chip select
    
    spi_master spm(.sysclk(clock_25mhz),.ss(selection),.data_in(data_to_send),
    .how_many_bytes(bytes_to_send), .new_data(new_data), .cs(chip_selects),
    .mosi(si),
    .miso(so),
    .sck(sck),
    .rst(rst),
    .busy(spi_busy),
    .trigger(trigger));
    
    reg [3:0] state;
    localparam IDLE = 4'h0;
    localparam START1 = 4'h1;
    localparam WRITE1 = 4'h2;
    localparam READ1 = 4'h3;
    localparam START2 = 4'h4;
    localparam RUN2 = 4'h5;
    localparam PAUSE2 = 4'h6;
    localparam START3 = 4'h7;
    localparam RUN3 = 4'h8;
    localparam PAUSE3 = 4'h9;
    localparam START4 = 4'hA;
    localparam RUN4 = 4'hB;
    localparam PAUSE4 = 4'hC;
        
    always @(posedge sysclk)begin
        case(state)
            IDLE: begin
                if(btn[1] == 1)begin
                    selection <= 3'b0; //pick device 0
                    bytes_to_send <= 16'b4; //send two bytes and read one byte
                    data_to_send <= 8'h1;
                    state <= START1;
                end else begin
                    trigger <= 1'b0;
                end
            end
            START1: begin
                trigger<=1'b1;
                if (~new_data && spi_busy) begin
                    state <= RUN1;
                end
                state <= RUN1;
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
            default:
                state <= IDLE;
        endcase
    end
            
                
    
    
    ///logic analyzer below:
    //ila_0 myila(.clk(sysclk),.probe0(sck),
    // .probe1(si), .probe2(so),.probe3(ccs),
    // .probe4(new_data), .probe5(trigger));
    
        
    
endmodule
