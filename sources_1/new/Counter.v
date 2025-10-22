`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2025 18:17:39
// Design Name: 
// Module Name: Counter
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


module Counter(
    input wire clk, // System clock
    input wire rst_n, //Reset
    input wire enable, // Start counting at 1
    input wire clear,   // Clear counter 
    output reg [3:0] count_bit,   // current value of bit
    output reg total_bit // 8 bits count

    );
    
    always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        count_bit <= 4'd0;
        total_bit <= 1'b0;
    end 
    else if(clear) begin
        count_bit <= 4'd0;
        total_bit <= 1'b0;
    end 
    else if(enable) begin
    if(count_bit == 4'd7) begin
        count_bit <= 4'd0;
        total_bit <= 1'b1;
    end
    else begin
        count_bit <= count_bit + 4'd1;
        total_bit <= 1'b0;
    end
    end
    end
endmodule
