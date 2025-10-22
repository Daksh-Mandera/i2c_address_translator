`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2025 19:33:03
// Design Name: 
// Module Name: I2C_testbench
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

module I2C_testbench;

    reg clk;
    reg rst_n;
    reg scl;
    
    wire sda;                 
    reg sda_drive_en;         
    reg sda_drive_val;       

    // Tri-state driver for SDA line
    assign sda = sda_drive_en ? sda_drive_val : 1'bz;

    // Instantiate DUT
    Top_module uut (
        .clk(clk),
        .rst_n(rst_n),
        .sda(sda),
        .scl(scl)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, I2C_testbench);
    end

    initial begin
        // Initialize
        rst_n = 0;
        scl = 1;
        sda_drive_en = 0;
        sda_drive_val = 1;
        
        #50;
        rst_n = 1;
        #50;

        $display("Starting I2C Transaction");
        
        // START condition
        start_condition();
        $display("Time %0t: START condition generated", $time);

        // Send 7-bit slave address 
        send_byte(8'b10100000);
        $display("Time %0t: Address 0x50 + W sent", $time);

        // Wait for ACK from slave
        ack_by_slave();
        $display("Time %0t: Slave ACK received", $time);

        // Send data byte
        send_byte(8'b00111100);
        $display("Time %0t: Data 0x3C sent", $time);

        // Wait for ACK
        ack_by_slave();
        $display("Time %0t: Data ACK received", $time);

        // STOP condition
        stop_condition();
        $display("Time %0t: STOP condition generated", $time);

        #200;
        $display("Test Complete");
        $finish;
    end

    // Task definitions 
    task start_condition;
        begin
            sda_drive_en = 1;
            sda_drive_val = 1;
            scl = 1; 
            #20;
            sda_drive_val = 0; 
            #20;
            scl = 0; 
            #20;
        end
    endtask

    task stop_condition;
        begin
            sda_drive_en = 1;
            sda_drive_val = 0;
            scl = 0; 
            #20;
            scl = 1; 
            #20;
            sda_drive_val = 1; 
            #20;
            sda_drive_en = 0;
        end
    endtask

    task send_byte;
        input [7:0] byte;
        integer i;
        begin
            for (i = 7; i >= 0; i = i - 1) begin
                scl = 0; 
                #10;
                sda_drive_en = 1;
                sda_drive_val = byte[i]; 
                #10;
                scl = 1; 
                #20;
            end
            scl = 0;
            #10;
        end
    endtask

    task ack_by_slave;
        begin
            sda_drive_en = 0;
            #10;
            scl = 1; 
            #20;
            scl = 0; 
            #10;
        end
    endtask

    // Monitor
    initial begin
        $monitor("Time=%0t | rst_n=%b | scl=%b | sda=%b | sda_en=%b", 
        $time, rst_n, scl, sda, sda_drive_en);
    end

endmodule
