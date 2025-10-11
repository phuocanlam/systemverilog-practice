module top(
    input  logic       CLK100MHZ,
    input  logic       CPU_RESETN,
    input  logic       BTNL,
    input  logic       BTNR,
    output logic       LED,
    output logic [7:0] an,
    output logic [6:0] seg
);
    lock unit (
        .clk_i      (CLK100MHZ),
        .reset_i    (~CPU_RESETN),
        .b0_in      (BTNL),
        .b1_in      (BTNR),
        .out        (LED),
        .led0       (seg)
    );

    assign an = 8'b1111_1110;
    //assign an = 1'b0;

endmodule

module lock(
    input  logic       clk_i,
    input  logic       reset_i,
    input  logic       b0_in,
    input  logic       b1_in,
    output logic       out,
    output logic [6:0] led0
    //output logic [3:0] hex_display
);
    parameter S_RESET = 0;
    parameter S_0     = 1;
    parameter S_01    = 2;
    parameter S_010   = 3;
    parameter S_0101  = 4;
    parameter S_01011 = 5;
    logic [6:0] hex_display;
    logic reset, b0, b1; // Synchronize push buttons, convert to pulses
    button b_reset (clk_i, reset_i, reset);
    button b_0     (clk_i, b0_in, b0);
    button b_1     (clk_i, b1_in, b1);

    logic [2:0] state, next_state;

    always_ff @(posedge clk_i) begin
        state <= next_state;
    end

    always_comb begin
        if (reset) next_state = S_RESET;
        else case (state)
            S_RESET: next_state = b0 ? S_0   : b1 ? S_RESET : state;
            S_0:     next_state = b0 ? S_0   : b1 ? S_01    : state;
            S_01:    next_state = b0 ? S_010 : b1 ? S_RESET : state;
            S_010:   next_state = b0 ? S_0   : b1 ? S_0101  : state;
            S_0101:  next_state = b0 ? S_010 : b1 ? S_01011 : state;
            S_01011: next_state = b0 ? S_0   : b1 ? S_RESET : state;
            default: next_state = S_RESET;
        endcase
    end

    assign out = (state == S_01011);
    assign hex_display = {1'b0, state};

    hex_to_sseg (
        .hex(hex_display),
        //.dp(1'b1),
        .sseg(led0)
    );

endmodule

module button(
    input  logic clk_i,
    input  logic in,
    output logic out
);
    logic r1, r2, r3;
    always_ff @(posedge clk_i) begin
        r1 <= in;
        r2 <= r1;
        r3 <= r2;
    end
    assign out = ~r3 & r2;
endmodule

module hex_to_sseg (
    input  logic [3:0] hex,
    //output logic       dp,
    output logic [6:0] sseg
);
    always_comb begin
        case (hex)
            4'h0: sseg = 7'b100_0000; // 0
            4'h1: sseg = 7'b111_1001; // 1
            4'h2: sseg = 7'b010_0100; // 2
            4'h3: sseg = 7'b011_0000; // 3
            4'h4: sseg = 7'b001_1001; // 4
            4'h5: sseg = 7'b001_0010; // 5
            4'h6: sseg = 7'b000_0010; // 6
            4'h7: sseg = 7'b111_1000; // 7
            4'h8: sseg = 7'b000_0000; // 8
            4'h9: sseg = 7'b001_0000; // 9
            4'hA: sseg = 7'b000_1000; // A
            4'hB: sseg = 7'b000_0011; // b
            4'hC: sseg = 7'b100_0110; // C
            4'hD: sseg = 7'b010_0001; // d
            4'hE: sseg = 7'b000_0110; // E
            4'hF: sseg = 7'b000_1110; // F
            default: sseg = 7'b111_1111; // blank (all segments off)
        endcase
    end
    //assign sseg[7] = dp;
endmodule