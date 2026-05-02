/*
FINAL_VALUE = 1 / (2^R * (T_sys * F_pwm))
*/

module pwm #(
    parameter   R          = 8, 
                TIMER_BITS = 15
) (
    input  wire                     clk,
    input  wire                     reset_n,
    input  wire [R:0]               duty,
    input  wire [TIMER_BITS-1:0]    FINAL_VALUE,
    output wire                     pwm_out
);  
    wire tick;
    // Up Counter
    reg [R-1:0] Q_reg, Q_next;
    reg         d_reg, d_next;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            Q_reg <= 'b0;
            d_reg <= 1'b0;
        end else if (tick) begin
            Q_reg <= Q_next;
            d_reg <= d_next;
        end else begin
            Q_reg <= Q_reg;
            d_reg <= d_reg;
        end
    end

    // Next-state logic
    always @(*) begin
        Q_next = Q_reg + 1;
        d_next = Q_reg < duty;
    end

    // Output logic
    assign pwm_out = d_reg;

    timer_input #() timer0 (
        .clk(clk),
        .reset_n(reset_n),
        .enable(1'b1),
        .FINAL_VALUE(FINAL_VALUE),
        .done(tick)
    );
endmodule