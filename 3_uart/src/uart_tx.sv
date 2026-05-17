module uart_tx #(
    parameter   DATA_BIT = 8,
                SB_TICK  = 16
) (
    input  logic        clk_i,
    input  logic        rstn_i,
    input  logic        tx_start_i,
    input  logic        s_tick_i,
    input  logic [7:0]  data_i,
    output logic        tx_done_tick_o,
    output logic        tx_o
);
    // fsm state type 
    typedef enum {s_IDLE, s_START, s_DATA, s_STOP} state_type;

    // signal declaration
    state_type current_state, next_state;
    logic [3:0] s_reg, s_next;
    logic [2:0] n_reg, n_next;
    logic [7:0] b_reg, b_next;
    logic       tx_reg, tx_next;

    // body
    // FSMD state & data registers
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            current_state <= s_IDLE;
            s_reg         <= 0;
            n_reg         <= 0;
            b_reg         <= 0;
            tx_reg        <= 1'b1;
        end else begin
            current_state <= next_state;
            s_reg         <= s_next;
            n_reg         <= n_next;
            b_reg         <= b_next;
            tx_reg        <= tx_next;
        end
    end

    // FSMD next-state logic & functional units
    always_comb begin
        next_state     = current_state;
        s_next         = s_reg;
        n_next         = n_reg;
        b_next         = b_reg;
        tx_next        = tx_reg;
        tx_done_tick_o = 1'b0;
        case (current_state)
            s_IDLE: begin
                tx_next = 1'b1;
                if (tx_start_i) begin
                    next_state = s_START;
                    s_next     = 0;
                    b_next     = data_i;
                end
            end 
            //
            s_START: begin
                tx_next = 1'b0;
                if (s_tick_i) begin
                    if (s_reg == 15) begin
                        next_state = s_DATA;
                        s_next = 0;
                        n_next = 0;
                    end else begin
                        s_next = s_reg + 1; 
                    end
                end
            end
            //
            s_DATA: begin
                tx_next = b_reg[0];
                if (s_tick_i) begin
                    if (s_reg == 15) begin
                        s_next = 0;
                        b_next = b_reg >> 1;
                        if (n_reg == (DATA_BIT-1)) begin
                            next_state = s_STOP;
                        end else begin
                            n_next = n_reg + 1;
                        end
                    end else begin
                        s_next = s_reg + 1; 
                    end
                end
            end
            //
            s_STOP: begin
                tx_next = 1'b1;
                if (s_tick_i) begin
                    if (s_reg == (SB_TICK-1)) begin
                        next_state = s_IDLE;
                        tx_done_tick_o = 1'b1;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
            default: ;
        endcase
    end

    // output
    assign tx_o = tx_reg;
endmodule