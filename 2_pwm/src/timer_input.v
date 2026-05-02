module timer_input #(
    parameter BITS = 4
) (
    input wire clk,
    input wire reset_n,
    input wire enable,
    input [BITS - 1:0] FINAL_VALUE,
    // output [BITS - 1:0] Q,
    output done
);
    reg [BITS - 1:0] Q_reg, Q_next;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            Q_reg <= 'b0;
        end else if (enable) begin
            Q_reg <= Q_next;
        end else begin
            Q_reg <= Q_reg;
        end
    end

    // Next state logic
    assign done = (Q_reg == FINAL_VALUE);

    always @(*) begin
        Q_next = done ? 'b0 : (Q_reg + 1);
    end
    
endmodule