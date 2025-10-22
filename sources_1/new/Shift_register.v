`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2025 18:18:00
// Design Name: 
// Module Name: Shift_register
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


module Shift_register(
    input wire clk, // System clock
    input wire rst_n, //Reset
    input wire load,    //load parallel(tx) data for transmission
    input wire shift_en,    // enable shifing
    input wire sda_in,  //input from sda line
    input wire [7:0] data_in,   //data to load in tx mode
    output reg sda_out, // serial data output
    output reg [7:0] data_out   //rx output after 8 bit received

    );
    
     reg [7:0] shift_reg;
    
     always @(posedge clk or negedge rst_n) begin
     if(!rst_n) begin
         shift_reg <= 8'b0;
         sda_out <= 1'b1;
         data_out <= 8'b0;
     end
     else if(load) begin
         shift_reg <= data_in;
         sda_out <= data_in[7];
         data_out <= data_in;
     end
     else if(shift_en) begin
         shift_reg <= {shift_reg[6:0], sda_in};
         sda_out <= shift_reg[7];
         data_out <= {shift_reg[6:0], sda_in};
     end
     else begin
         data_out <= shift_reg;
     end
     end
    
endmodule