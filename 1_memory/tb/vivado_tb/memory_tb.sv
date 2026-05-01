`timescale 1ns/1ps

module memory_tb;

    localparam WORDS = 64;

    // DUT signals
    logic clk_i;
    logic rstn_i;
    logic [31:0] address_i;
    logic [31:0] write_data_i;
    logic write_enable_i;
    logic [31:0] read_data_o;

    // Temp variables (declare upfront for Vivado)
    integer i;
    integer idx;
    logic [31:0] rdata;
    logic [31:0] data_before, data_after;
    logic [31:0] addr;
    logic [31:0] data;

    // Expected memory
    logic [31:0] expected_mem [0:WORDS-1];

    // DUT
    memory #(.WORDS(WORDS)) dut (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .address_i(address_i),
        .write_data_i(write_data_i),
        .write_enable_i(write_enable_i),
        .read_data_o(read_data_o)
    );

    // Clock
    initial clk_i = 0;
    always #5 clk_i = ~clk_i;

    // Write task
    task automatic write(input [31:0] addr_t, input [31:0] data_t);
        begin
            @(posedge clk_i);
            address_i      <= addr_t;
            write_data_i   <= data_t;
            write_enable_i <= 1'b1;

            @(posedge clk_i);
            write_enable_i <= 1'b0;
        end
    endtask

    // Read task
    task automatic read(input [31:0] addr_t, output [31:0] data_t);
        begin
            @(posedge clk_i);
            address_i <= addr_t;

            #1;
            data_t = read_data_o;
        end
    endtask

    initial begin
        $display("==== START TEST ====");

        // Init
        rstn_i = 0;
        address_i = 0;
        write_data_i = 0;
        write_enable_i = 0;

        for (i = 0; i < WORDS; i = i + 1)
            expected_mem[i] = 0;

        repeat (2) @(posedge clk_i);
        rstn_i = 1;

        // ---------------- RESET TEST ----------------
        for (i = 0; i < 8; i = i + 1) begin
            read(i*4, rdata);
            if (rdata !== 0)
                $error("Reset fail at %0d", i);
        end

        // ---------------- WRITE TEST ----------------
        for (i = 0; i < 8; i = i + 1) begin
            addr = i * 4;
            data = 32'hA5A50000 + i;

            write(addr, data);
            expected_mem[i] = data;
        end

        for (i = 0; i < 8; i = i + 1) begin
            read(i*4, rdata);
            if (rdata !== expected_mem[i])
                $error("Write/read fail at %0d", i);
        end

        // ---------------- MISALIGNED TEST ----------------
        read(4, data_before);

        write(6, 32'hDEADBEEF); // misaligned

        read(4, data_after);

        if (data_after !== data_before)
            $error("Misaligned write modified memory!");
        else
            $display("Misaligned test passed");

        // ---------------- RANDOM TEST ----------------
        for (i = 0; i < 20; i = i + 1) begin
            idx = $urandom_range(0, WORDS-1);
            addr = idx * 4;
            data = $urandom;

            write(addr, data);
            expected_mem[idx] = data;
        end

        for (i = 0; i < 20; i = i + 1) begin
            idx = $urandom_range(0, WORDS-1);

            read(idx*4, rdata);

            if (rdata !== expected_mem[idx])
                $error("Random test fail at %0d", idx);
        end

        $display("==== TEST DONE ====");
        $finish;
    end

endmodule