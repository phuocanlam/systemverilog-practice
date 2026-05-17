module uart_top #(
    parameter   DATA_BIT     = 8,
                SB_TICK      = 16,
                FIFO_W       = 4,
                BAUDRATE_CFG = 115200,
                SYS_CLK_CFG  = 100_000_000
) (
    input  logic                clk_i,
    input  logic                rstn_i,
    input  logic [10:0]         dvsr_i,
    // UART TX
    input  logic                wr_uart_i,
    input  logic [DATA_BIT-1:0] wr_data_i,
    output logic                tx_full_o,
    output logic                uart_tx_o,
    // UART RX
    input  logic                rd_uart_i,
    input  logic                uart_rx_i,
    output logic [DATA_BIT-1:0] rd_data_o,
    output logic                rx_empty_o
);
    //==============================================================//
    // Setup baudrate                                               //
    //==============================================================//
    localparam integer DVSR = SYS_CLK_CFG/(SB_TICK*BAUDRATE_CFG)-1;

    //==============================================================//
    // Signal                                                       //
    //==============================================================//
    logic                   tick_w;
    logic                   tx_done_w;
    logic                   fifo_tx_empty_w;
    logic [DATA_BIT-1:0]    tx_data;
    logic                   rx_done_w;
    logic [DATA_BIT-1:0]    rx_data;

    //==============================================================//
    // dvsr will be configured by MSC                                                             //
    //==============================================================//
    baud_gen baud_gen_unit (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        // .dvsr_i(DVSR),      
        .dvsr_i(dvsr_i),      
        .tick_o(tick_w)
    );

    fifo #(.DATA_WIDTH(DATA_BIT), .ADDR_WIDTH(FIFO_W)) fifo_tx_u (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .read_i(tx_done_w),
        .write_i(wr_uart_i),
        .wr_data_i(wr_data_i),
        .empty_o(fifo_tx_empty_w),
        .full_o(tx_full_o),
        .rd_data_o(tx_data)
    );
    
    uart_tx #(.DATA_BIT(DATA_BIT),.SB_TICK(SB_TICK)) uart_tx_u (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .tx_start_i(~fifo_tx_empty_w),
        .s_tick_i(tick_w),
        .data_i(tx_data),
        .tx_done_tick_o(tx_done_w),
        .tx_o(uart_tx_o)
    );

    fifo #(.DATA_WIDTH(DATA_BIT), .ADDR_WIDTH(FIFO_W)) fifo_rx_u (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .read_i(rd_uart_i),
        .write_i(rx_done_w),
        .wr_data_i(rx_data),
        .empty_o(rx_empty_o),
        .full_o(),
        .rd_data_o(rd_data_o)
    );

    uart_rx #(.DATA_BIT(DATA_BIT),.SB_TICK(SB_TICK)) uart_rx_u (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .rx_i(uart_rx_i),
        .s_tick_i(tick_w),
        .rx_done_tick_o(rx_done_w),
        .data_o(rx_data)   
    );
endmodule