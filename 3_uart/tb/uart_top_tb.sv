// `timescale 1ns/1ps

module uart_top_tb;

    //==============================================================//
    // Parameters
    //==============================================================//
    localparam DATA_BIT     = 8;
    localparam SB_TICK      = 16;
    localparam FIFO_W       = 4;
    localparam BAUDRATE_CFG = 115200;
    localparam SYS_CLK_CFG  = 100_000_000;

    //==============================================================//
    // Signals
    //==============================================================//
    logic clk;
    logic rstn;

    // TX
    logic wr_uart;
    logic [DATA_BIT-1:0] wr_data;
    logic tx_full;
    logic uart_tx;

    // RX
    logic rd_uart;
    logic [DATA_BIT-1:0] rd_data;
    logic rx_empty;

    // loopback wire
    logic uart_rx;

    assign uart_rx = uart_tx; // 🔥 LOOPBACK

    //==============================================================//
    // DUT
    //==============================================================//
    uart_top #(
        .DATA_BIT(DATA_BIT),
        .SB_TICK(SB_TICK),
        .FIFO_W(FIFO_W),
        .BAUDRATE_CFG(BAUDRATE_CFG),
        .SYS_CLK_CFG(SYS_CLK_CFG)
    ) dut (
        .clk_i(clk),
        .rstn_i(rstn),

        .wr_uart_i(wr_uart),
        .wr_data_i(wr_data),
        .tx_full_o(tx_full),
        .uart_tx_o(uart_tx),

        .rd_uart_i(rd_uart),
        .uart_rx_i(uart_rx),
        .rd_data_o(rd_data),
        .rx_empty_o(rx_empty)
    );

    //==============================================================//
    // Clock: 100MHz
    //==============================================================//
    always #5 clk = ~clk;

    //==============================================================//
    // Task: write 1 byte
    //==============================================================//
    task uart_write(input [7:0] data_in);
        begin
            @(posedge clk);
            while (tx_full) @(posedge clk); // wait FIFO space
            wr_data = data_in;
            wr_uart = 1;
            @(posedge clk);
            wr_uart = 0;
        end
    endtask

    //==============================================================//
    // Task: read 1 byte
    //==============================================================//
    task uart_read(output [7:0] data_out);
        begin
            while (rx_empty) @(posedge clk); // wait data available
            @(posedge clk);
            rd_uart = 1;
            @(posedge clk);
            data_out = rd_data;
            rd_uart = 0;
            // @(posedge clk);
            // data_out = rd_data;
        end
    endtask

    //==============================================================//
    // Stimulus
    //==============================================================//
    logic [7:0] rx_data_chk;

    initial begin
        clk      = 0;
        rstn     = 0;
        wr_uart  = 0;
        rd_uart  = 0;
        wr_data  = 0;

        // reset
        #100;
        rstn = 1;

        //==========================================================//
        // Test 1
        //==========================================================//
        uart_write(8'hA5);
        uart_read(rx_data_chk);

        if (rx_data_chk !== 8'hA5)
            $error("Mismatch! Expected A5, got %h", rx_data_chk);
        else
            $display("PASS: A5");

        //==========================================================//
        // Test 2
        //==========================================================//
        uart_write(8'h3C);
        uart_read(rx_data_chk);

        if (rx_data_chk !== 8'h3C)
            $error("Mismatch! Expected 3C, got %h", rx_data_chk);
        else
            $display("PASS: 3C");

        //==========================================================//
        // Test multiple bytes (FIFO behavior)
        //==========================================================//
        // uart_write(8'h11);
        // uart_write(8'h22);
        // uart_write(8'h33);
        // uart_write(8'h44);

        // uart_read(rx_data_chk);
        // if (rx_data_chk !== 8'h11) $error("Mismatch!");

        // uart_read(rx_data_chk);
        // if (rx_data_chk !== 8'h22) $error("Mismatch!");

        // uart_read(rx_data_chk);
        // if (rx_data_chk !== 8'h33) $error("Mismatch!");

        // uart_read(rx_data_chk);
        // if (rx_data_chk !== 8'h44) $error("Mismatch!");

        repeat (100) begin
            byte rand_data = $urandom;
            uart_write(rand_data);
            uart_read(rx_data_chk);
            assert(rx_data_chk == rand_data);
        end

        #2000;
        $display("Completed Testing!!!");
        $stop;
    end

    initial begin
        $monitor("T=%0t |  wr_uart = %b  |   wr_data = %h  | rx_empty=%b | rd_uart = %b |  wr_data = %h ", $time, wr_uart, wr_data, rx_empty, rd_uart, rd_data);
    end

endmodule