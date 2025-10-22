
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2025 18:18:27
// Design Name: 
// Module Name: Start_Stop_detector
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


module Start_Stop_detector(
     input wire clk, // System clock
     input wire rst_n, //Reset
     input wire sda_in, //input to sda
     input wire scl_in, 
     output reg start_detect,   // when start condition is valid - 1
     output reg stop_detect   // when stop condition is valid - 1

    );
    
    reg sda_d, scl_d;   // for edge detection
    
    always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sda_d <= 1'b1;
        scl_d <= 1'b1;
        start_detect <= 1'b0;
        stop_detect <= 1'b0;
    end
    else begin
        sda_d <= sda_in;
        scl_d <= scl_in;
    
    if(sda_d == 1'b1 && sda_in == 1'b0 && scl_in == 1'b1) begin
        start_detect <= 1'b1;
    end
    else begin
        start_detect <= 1'b0;
    end
    if(sda_d == 1'b0 && sda_in == 1'b1 && scl_in == 1'b1) begin
        stop_detect <= 1'b1;
    end
    else begin
        stop_detect <= 1'b0;
    end
    end
    end

endmodule