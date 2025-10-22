`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 21.10.2025 18:19:22
// Design Name:
// Module Name: I2C_Slave
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




module I2C_Slave(
    input wire clk,
    input wire rst_n,
    input wire sda_in,
    input wire scl_in,
    input wire [6:0] slave_addr,
    output reg sda_out,
    output reg sda_en,
    output reg trigger_out,
    output reg [7:0] data_to_master,
    output reg error_flag
    );
    
    // Defining FSM states of i2c Slave
    localparam Idle = 4'd0;
    localparam Start_detect = 4'd1;
    localparam Addr_receive = 4'd2;
    localparam Addr_check = 4'd3;
    localparam Addr_ack = 4'd4;
    localparam Data_rx = 4'd5;
    localparam Data_tx = 4'd6;
    localparam Data_ack = 4'd7;
    localparam Stop = 4'd8;
    localparam Error_state = 4'd9;
    
    // Internal variables
    reg [3:0] State, next_state;
    reg [7:0] shift_reg, next_shift_reg;
    reg [3:0] count_bit, next_count_bit;
    reg rw_bit, next_rw_bit;
    reg Addr_match, next_Addr_match;
    reg sda_in_1, sda_in_2;
    reg scl_in_1, scl_in_2;
    
    // Detect start and stop conditions
    wire start_condition = (sda_in_2 == 1'b1 && sda_in_1 == 1'b0) && (scl_in_1 == 1'b1);
    wire stop_condition = (sda_in_2 == 1'b0 && sda_in_1 == 1'b1) && (scl_in_1 == 1'b1);
    wire scl_posedge = (scl_in_2 == 1'b0 && scl_in_1 == 1'b1);
    
    // Synchronization - double register for metastability
    always @(posedge clk) begin
        sda_in_2 <= sda_in_1;
        sda_in_1 <= sda_in;
        scl_in_2 <= scl_in_1;
        scl_in_1 <= scl_in;
    end
    
    // Update state register
    always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        State <= Idle;
        count_bit <= 4'd0;
        shift_reg <= 8'd0;
        Addr_match <= 1'b0;
        rw_bit <= 1'b0;
        sda_out <= 1'b1;
        sda_en <= 1'b0;
        trigger_out <= 1'b0;
        data_to_master <= 8'b0;
        error_flag <= 1'b0;
    end
    else begin
        State <= next_state;
        count_bit <= next_count_bit;
        shift_reg <= next_shift_reg;
        Addr_match <= next_Addr_match;
        rw_bit <= next_rw_bit;
    
    // Shift in data on SCL rising edge during address/data receive
    if(scl_posedge && (State == Addr_receive || State == Data_rx)) begin
        shift_reg <= {shift_reg[6:0], sda_in_1};
    end
    end
    end
    
    // Next state logic and output logic
    always @(*) begin
    // Default values
        next_state = State;
        next_count_bit = count_bit;
        next_shift_reg = shift_reg;
        next_Addr_match = Addr_match;
        next_rw_bit = rw_bit;
        sda_en = 1'b0;
        sda_out = 1'b1;
        trigger_out = 1'b0;
        error_flag = 1'b0;
    
    case(State)
        Idle: begin
            next_count_bit = 4'd0;
            next_Addr_match = 1'b0;
        if(start_condition) begin
            next_state = Start_detect;
        end
        end
    
        Start_detect: begin
            next_state = Addr_receive;
            next_count_bit = 4'd7;
        end
    
        Addr_receive: begin
        if(count_bit == 4'd0) begin
            next_state = Addr_check;
        end
        else begin
            next_count_bit = count_bit - 4'd1;
        end
        end
    
        Addr_check: begin
        if(shift_reg[7:1] == slave_addr) begin
            next_Addr_match = 1'b1;
            next_rw_bit = shift_reg[0];
            next_state = Addr_ack;
        end
        else begin
            next_Addr_match = 1'b0;
            next_state = Idle;
        end
        end
    
        Addr_ack: begin
            sda_en = 1'b1;
            sda_out = 1'b0;
        if(rw_bit == 1'b0) begin
            next_state = Data_rx;
            next_count_bit = 4'd7;
        end
        else begin
            next_state = Data_tx;
        end
        end
    
        Data_rx: begin
        if(count_bit == 4'd0) begin
            next_state = Data_ack;
        end
        else begin
            next_count_bit = count_bit - 4'd1;
        end
        end
    
        Data_ack: begin
            sda_en = 1'b1;
            sda_out = 1'b0;
            trigger_out = 1'b1;
            data_to_master = shift_reg;
            next_state = Stop;
        end
    
        Data_tx: begin
            sda_en = 1'b0;
            next_state = Stop;
        end
        
        Stop: begin
            if(stop_condition) begin
            next_state = Idle;
        end
        end
        
        Error_state: begin
            error_flag = 1'b1;
            next_state = Idle;
        end
        
        default: next_state = Error_state;
        endcase
    end
endmodule
