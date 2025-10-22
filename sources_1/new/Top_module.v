`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2025 18:19:48
// Design Name: 
// Module Name: Top_module
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

module Top_module(
    input wire clk,
    input wire rst_n,
    inout wire sda,
    input wire scl
);

    wire sda_master_out;
    wire sda_slave_out;
    wire sda_master_en;
    wire sda_slave_en;
    wire signal_trigger;
    wire [7:0] data_bus;
    wire scl_master_out;
    
    // Tri-state control for SDA line

   assign sda = sda_master_en ? sda_master_out : sda_slave_en ? sda_slave_out :1'bz;
    
    // I2C Slave instantiation
    I2C_Slave slave_inst(
        .clk(clk),
        .rst_n(rst_n),
        .sda_in(sda),
        .scl_in(scl),
        .slave_addr(7'h50),
        .sda_out(sda_slave_out),
        .sda_en(sda_slave_en),
        .trigger_out(signal_trigger),
        .data_to_master(data_bus),
        .error_flag()
    );
    
    // I2C Master instantiation
    I2C_Master master_inst(
        .clk(clk),
        .rst_n(rst_n),
        .sda_in(sda),
        .scl_in(scl),     
        .trigger_in(signal_trigger),
        .real_addrs(7'h60),
        .sda_out(sda_master_out),
        .scl_out(scl_master_out),
        .sda_en(sda_master_en),
        .data_to_slave(),
        .transition_done(),
        .error_flag()
    );
        
endmodule
