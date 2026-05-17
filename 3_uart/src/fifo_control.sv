module fifo_control #(
    parameter ADDR_WIDTH = 4
) (
    input  logic                    clk_i,
    input  logic                    rstn_i,
    input  logic                    read_i,
    input  logic                    write_i,
    output logic                    empty_o,
    output logic                    full_o,
    output logic [ADDR_WIDTH-1:0]   wr_addr_o,
    output logic [ADDR_WIDTH-1:0]   rd_addr_o
);
    //signal declaration
    logic [ADDR_WIDTH-1:0]  w_ptr_logic, w_ptr_next, w_ptr_succ;
    logic [ADDR_WIDTH-1:0]  r_ptr_logic, r_ptr_next, r_ptr_succ;
    logic                   full_logic, empty_logic;
    logic                   full_next, empty_next;

    // body
    // fifo control logic
    // logicisters for status and read and write pointers
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            w_ptr_logic <= 0;
            r_ptr_logic <= 0;
            full_logic  <= 1'b0;
            empty_logic <= 1'b1;
        end else begin
            w_ptr_logic <= w_ptr_next;
            r_ptr_logic <= r_ptr_next;
            full_logic  <= full_next;
            empty_logic <= empty_next;
        end
    end

    always_comb begin
        // successive pointer values
        w_ptr_succ = w_ptr_logic + 1;
        r_ptr_succ = r_ptr_logic + 1;
        // default: keep old values
        w_ptr_next = w_ptr_logic;
        r_ptr_next = r_ptr_logic;
        full_next  = full_logic;
        empty_next = empty_logic;
        unique case ({write_i, read_i})
            // Read operation
            2'b01: begin
                if (~empty_logic) begin
                    r_ptr_next = r_ptr_succ;
                    full_next  = 1'b0;
                    if (r_ptr_succ == w_ptr_logic) begin
                        empty_next = 1'b1;
                    end
                end
            end

            // Write operation
            2'b10: begin
                if (~full_logic) begin // not full
                    w_ptr_next = w_ptr_succ;
                    empty_next = 1'b0;
                    if (w_ptr_succ == r_ptr_logic) begin
                        full_next = 1'b1;
                    end
                end
            end

            // Read & Write operation
            2'b11: begin
                w_ptr_next = w_ptr_succ;
                r_ptr_next = r_ptr_succ;
            end
            default: ;  // 2'b00; null statement; no op
        endcase
    end

    // output
    assign wr_addr_o = w_ptr_logic;
    assign rd_addr_o = r_ptr_logic;
    assign full_o    = full_logic;
    assign empty_o   = empty_logic;

endmodule