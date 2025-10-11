module lock_tb();
    logic clk;
    logic reset_i;
    logic b0_in, b1_in;
    logic out;
    logic [3:0] hex_display;

    // Instantiate DUT
    lock dut (
        .clk_i      (clk),
        .reset_i    (reset_i),
        .b0_in      (b0_in),
        .b1_in      (b1_in),
        .out        (out),
        .hex_display(hex_display)
    );
    
    // Clock generator: 10ns period = 100 MHz
    initial clk = 0;
    always #5 clk = ~clk;

    // Task: generate button pulse
    task automatic press_button(string name, ref logic btn);
        begin
            // assert for one clock cycle
            btn = 1'b1;
            @(posedge clk);
            btn = 1'b0;
            @(posedge clk);
            $display("[%0t] Button %s pressed", $time, name);
        end
    endtask

    initial begin
        b0_in = 1'b0;
        b1_in = 1'b0;
        reset_i = 1;

        // Hold reset a few cycles
        repeat (3) @(posedge clk);
        reset_i = 0;
        $display("[%0t] Reset released", $time);
        // Sequence = 0-1-0-1-1 (01011)
        press_button("b0", b0_in); // 0
        press_button("b1", b1_in); // 1
        press_button("b0", b0_in); // 0
        press_button("b1", b1_in); // 1
        press_button("b1", b1_in); // 1
        // Wait a bit
        repeat (5) @(posedge clk);

        $display("[%0t] Simulation finished", $time);
        $stop;
    end

    always @(posedge clk) begin
        $display("[%0t] state=%0d hex=%b b0=%b b1=%b out=%b",
                 $time, dut.state, hex_display, b0_in, b1_in, out);
    end
endmodule