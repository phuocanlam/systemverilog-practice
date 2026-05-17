// `timescale 1ns/1ps

module uart_tx_tb;

    // parameters
    localparam DATA_BIT = 8;
    localparam SB_TICK  = 16;

    // signals
    logic clk;
    logic rstn;
    logic tx_start;
    logic s_tick;
    logic [7:0] data;
    logic tx_done;
    logic tx;

    // instantiate DUT
    uart_tx #(
        .DATA_BIT(DATA_BIT),
        .SB_TICK(SB_TICK)
    ) dut (
        .clk_i(clk),
        .rstn_i(rstn),
        .tx_start_i(tx_start),
        .s_tick_i(s_tick),
        .data_i(data),
        .tx_done_tick_o(tx_done),
        .tx_o(tx)
    );

    // 🔸 Clock 100MHz → 10ns period
    always #5 clk = ~clk;

    // 🔸 Generate s_tick (16x oversampling)
    // giả sử mỗi 54 clock tạo 1 tick
    int tick_cnt;
    always_ff @(posedge clk) begin
        if (!rstn) begin
            tick_cnt <= 0;
            s_tick   <= 0;
        end else begin
            if (tick_cnt == 53) begin
                s_tick   <= 1;
                tick_cnt <= 0;
            end else begin
                s_tick   <= 0;
                tick_cnt <= tick_cnt + 1;
            end
        end
    end

    // 🔸 Stimulus
    initial begin
        clk      = 0;
        rstn     = 0;
        tx_start = 0;
        data     = 8'h00;

        // reset
        #100;
        rstn = 1;

        // gửi 1 byte
        $display("New Data 0xa5");
        @(posedge clk);
        data     = 8'hA5;   // 1010_0101
        tx_start = 1;

        @(posedge clk);
        tx_start = 0;

        // chờ truyền xong
        wait (tx_done);

        // delay thêm để quan sát
        #1000;

        // gửi thêm 1 byte
        $display("New Data 0x3C");
        @(posedge clk);
        data     = 8'h3C;
        tx_start = 1;

        @(posedge clk);
        tx_start = 0;

        wait (tx_done);

        #1000;       
        #1000;

        $stop;
    end

    // 🔸 Monitor
    initial begin
        $display("Time\t tx");
        $monitor("%0t\t %b", $time, tx);
    end

endmodule