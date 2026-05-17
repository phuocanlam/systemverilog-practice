`timescale 1ns/1ps

module reg_file_tb;

    // Parameters
    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 2;
    localparam CLK_PERIOD = 10;

    // Interface Signals
    logic                    clk_i;
    logic                    wr_en_i;
    logic [ADDR_WIDTH-1:0]   wr_addr_i;
    logic [ADDR_WIDTH-1:0]   rd_addr_i;
    logic [DATA_WIDTH-1:0]   wr_data_i;
    logic [DATA_WIDTH-1:0]   rd_data_o;

    // Instantiate Design Under Test (DUT)
    moduleName #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk_i     (clk_i),
        .wr_en_i   (wr_en_i),
        .wr_addr_i (wr_addr_i),
        .rd_addr_i (rd_addr_i),
        .wr_data_i (wr_data_i),
        .rd_data_o (rd_data_o)
    );

    // Clock Generation
    initial begin
        clk_i = 0;
        forever #(CLK_PERIOD/2) clk_i = ~clk_i;
    end

    // Stimulus Task: Write Data
    task write_reg(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        begin
            @(negedge clk_i); // Apply data on negedge to meet setup time for posedge
            wr_en_i   = 1;
            wr_addr_i = addr;
            wr_data_i = data;
            @(posedge clk_i); // Wait for the write to occur
            #(1);             // Small delay after edge
            wr_en_i   = 0;
        end
    endtask

    // Main Test Sequence
    initial begin
        // Initialize signals
        wr_en_i   = 0;
        wr_addr_i = 0;
        rd_addr_i = 0;
        wr_data_i = 0;

        $display("--- Starting Register File Test ---");
        
        // 1. Write to all registers
        write_reg(2'b00, 8'hAA);
        write_reg(2'b01, 8'hBB);
        write_reg(2'b10, 8'hCC);
        write_reg(2'b11, 8'hDD);

        // 2. Read and Verify (Combinational Read)
        $display("Checking Read operations...");
        
        rd_addr_i = 2'b00; #5;
        if (rd_data_o === 8'hAA) $display("[PASS] Addr 0: %h", rd_data_o);
        else                     $display("[FAIL] Addr 0: Expected AA, Got %h", rd_data_o);

        rd_addr_i = 2'b10; #5;
        if (rd_data_o === 8'hCC) $display("[PASS] Addr 2: %h", rd_data_o);
        else                     $display("[FAIL] Addr 2: Expected CC, Got %h", rd_data_o);

        // 3. Test Write-Enable (Try to overwrite without wr_en)
        @(negedge clk_i);
        wr_en_i   = 0;
        wr_addr_i = 2'b01;
        wr_data_i = 8'hFF;
        @(posedge clk_i);
        
        rd_addr_i = 2'b01; #5;
        if (rd_data_o === 8'hBB) $display("[PASS] Write-Enable Protected: %h", rd_data_o);
        else                     $display("[FAIL] Write-Enable failed to protect data!");

        $display("--- Test Completed ---");
        $finish;
    end

    // Waveform Dump (Optional)
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, reg_file_tb);
    end

endmodule