module uart_core #(
    parameter FIFO_DEPTH_BIT = 8    // # addr bits of FIFO
) (
    // System Control
    input  logic        clk_i,
    input  logic        rstn_i,
    // Core IF
    input  logic        cs_i,
    input  logic        read_i,
    input  logic        write_i,
    input  logic [4:0]  addr_i,
    input  logic [31:0] wr_data_i,
    output logic [31:0] rd_data_o

    input  logic        rx,
    output logic        tx
);
    //==============================================================//
    // Parameters                                                   //
    //==============================================================//
    localparam DATA_BIT     = 8;
    localparam SB_TICK      = 16;
    // localparam FIFO_W       = 4;
    localparam BAUDRATE_CFG = 115200;
    localparam SYS_CLK_CFG  = 100_000_000;

    //==============================================================//
    // Logic Declaration                                            //
    //==============================================================//
    logic [DATA_BIT-1:0]    uart_rd_data;
    logic [10:0]            dvsr_reg;
    logic                   wr_dvsr_w;
    logic                   wr_uart_w, rd_uart_w;
    logic                   tx_full, rx_empty;

    //==============================================================//
    // CDC Synchronizer (RX)                                        //
    //==============================================================//
    logic rx_sync_1, rx_sync_2;
    logic tx_ready, rx_valid;

    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            rx_sync_1 <= 1'b1;
            rx_sync_2 <= 1'b1;
        end else begin
            rx_sync_1 <= rx;
            rx_sync_2 <= rx_sync_1;
        end
    end

    //==============================================================//
    // UART TOP Instantiate                                         //
    //==============================================================//
    uart_top #(
        .DATA_BIT(DATA_BIT),    
        .SB_TICK(SB_TICK),
        .FIFO_W(FIFO_DEPTH_BIT),    
        .BAUDRATE_CFG(BAUDRATE_CFG),
        .SYS_CLK_CFG(SYS_CLK_CFG)
    ) uart_top_unit (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .dvsr_i(dvsr_reg),
        // MCS => TX
        .wr_uart_i(wr_uart_w),
        .wr_data_i(wr_data_i[7:0]),
        .tx_full_o(tx_full),
        .uart_tx_o(tx),
        // RX => MCS
        .rd_uart_i(rd_uart_w),
        .uart_rx_i(rx_sync_2),
        .rd_data_o(uart_rd_data),
        .rx_empty_o(rx_empty)
    );

    //==============================================================//
    // Offset 1: dvsr_reg (write)                                   //
    //==============================================================//
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            dvsr_reg <= 0;
        end else begin
            if (wr_dvsr_w) begin
                dvsr_reg <= wr_data_i[10:0];
            end
        end
    end
    
    // decoding logic
    assign wr_dvsr_w = (cs_i && write_i && (addr_i[1:0] == 2'b01));
    assign wr_uart_w = (cs_i && write_i && (addr_i[1:0] == 2'b10));
    assign rd_uart_w = (cs_i && write_i && (addr_i[1:0] == 2'b11));
    // Core Read Data
    assign rd_data_o = {22'h000000, tx_full, rx_empty, uart_rd_data};

endmodule