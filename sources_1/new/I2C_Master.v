`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 21.10.2025 18:19:05
// Design Name:
// Module Name: I2C_Master
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


module I2C_Master(
    input wire clk,
    input wire rst_n,
    input wire sda_in,
    input wire scl_in,
    input wire trigger_in,
    input wire [6:0] real_addrs,
    output reg sda_out,
    output reg scl_out,
    output reg sda_en,
    output reg data_to_slave,
    output reg [7:0] transition_done,
    output reg error_flag
    );

    // Defining FSM states of i2c Master
    localparam M_Idle = 4'd0;
    localparam M_Start = 4'd1;
    localparam M_Addr_send = 4'd2;
    localparam M_Addr_ack = 4'd3;
    localparam M_Write_data = 4'd4;
    localparam M_Read_data = 4'd5;
    localparam M_Data_ack = 4'd6;
    localparam M_Stop = 4'd7;
    localparam M_Error = 4'd8;

    // Internal variables
    reg [3:0] State, next_state;
    reg [7:0] Shift_reg, next_Shift_reg;
    reg [3:0] count_bit, next_count_bit;
    reg rw_flag;

    // Sequential logic - update state and registers
    always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        State <= M_Idle;
        count_bit <= 4'd0;
        Shift_reg <= 8'd0;
        sda_out <= 1'b1;
        sda_en <= 1'b0;
        scl_out <= 1'b1;
        transition_done <= 8'b0;
        error_flag <= 1'b0;
        data_to_slave <= 1'b0;
        rw_flag <= 1'b0;
    end
    else begin
        State <= next_state;
        count_bit <= next_count_bit;
        Shift_reg <= next_Shift_reg;
    end
    end

    // Combinational logic - next state and outputs
    always @(*) begin
    // Default values
        next_state = State;
        next_count_bit = count_bit;
        next_Shift_reg = Shift_reg;
        sda_en = 1'b0;
        sda_out = 1'b1;
        scl_out = 1'b1;
        transition_done = 8'b0;
        error_flag = 1'b0;
    
    case(State)
        M_Idle: begin
        if(trigger_in) begin
            next_state = M_Start;
        end
    end
    
        M_Start: begin
            sda_en = 1'b1;
            sda_out = 1'b0;
            scl_out = 1'b1;
            next_state = M_Addr_send;
            next_count_bit = 4'd7;
            next_Shift_reg = {real_addrs, 1'b0};
        end
    
        M_Addr_send: begin
            sda_en = 1'b1;
            sda_out = Shift_reg[7];
            scl_out = 1'b0;
            next_Shift_reg = {Shift_reg[6:0], 1'b0};
        if(count_bit == 4'd0) begin
            next_state = M_Addr_ack;
        end
        else begin
            next_count_bit = count_bit - 4'd1;
        end
        end
    
        M_Addr_ack: begin
            sda_en = 1'b0;
            scl_out = 1'b1;
        if(sda_in == 1'b0) begin
            next_state = M_Write_data;
            next_count_bit = 4'd7;
            next_Shift_reg = 8'hAA; // Example data
        end
        else begin
            next_state = M_Error;
        end
        end
    
        M_Write_data: begin
            sda_en = 1'b1;
            sda_out = Shift_reg[7];
            scl_out = 1'b0;
            next_Shift_reg = {Shift_reg[6:0], 1'b0};
        if(count_bit == 4'd0) begin
            next_state = M_Data_ack;
        end
        else begin
            next_count_bit = count_bit - 4'd1;
        end
        end
    
        M_Data_ack: begin
            sda_en = 1'b0;
            scl_out = 1'b1;
        if(sda_in == 1'b0) begin
            next_state = M_Stop;
        end
        else begin
            next_state = M_Error;
        end
        end
    
        M_Stop: begin
            sda_en = 1'b1;
            sda_out = 1'b0;
            scl_out = 1'b1;
            transition_done = 8'b1;
            next_state = M_Idle;
        end
        
        M_Error: begin
            error_flag = 1'b1;
            next_state = M_Idle;
        end
        
        default: next_state = M_Idle;
        endcase
    end
    
    
endmodule
