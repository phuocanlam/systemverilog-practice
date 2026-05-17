module baud_gen (
    input  logic        clk_i,
    input  logic        rstn_i,
    input  logic [10:0] dvsr_i,
    output logic        tick_o
);
    logic [10:0]   current_state_reg;
    logic [10:0]   next_state_reg;
    
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            current_state_reg <= 0;
        end else begin
            current_state_reg <= next_state_reg;
        end
    end

    // next_state logic
    always_comb begin
        if (current_state_reg == dvsr_i) begin
            next_state_reg = 0;
        end else begin
            next_state_reg = current_state_reg + 1;
        end
    end

    // output
    assign tick_o = (current_state_reg == dvsr_i);

endmodule