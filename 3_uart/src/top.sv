module top (
    input  logic                    clk_i,          // clk
    input  logic                    rstn_i,         // reset_n

    input  logic                    rx,             // rx
    output logic                    tx,             // tx
    output logic                    empty_o,        // LED0
    output logic                    tx_full_o       // LED1

);
    //==============================================================//
    // Parameters                                                   //
    //==============================================================//
    localparam DATA_BIT     = 8;
    localparam SB_TICK      = 16;
    localparam FIFO_W       = 4;
    localparam BAUDRATE_CFG = 115200;
    localparam SYS_CLK_CFG  = 100_000_000;


    logic [DATA_BIT-1:0]    data_buf, uart_data_loopback_w;
    logic                   rd_uart_reg, wr_uart_reg, valid_reg;

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
    // Handshake RX and TX                                          //
    //==============================================================//
    //==============================================================//
    // Handshake RX and TX (S?a ??i)                                //
    //==============================================================//
    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        READ  = 2'b01,
        WAIT  = 2'b10,
        WRITE = 2'b11
    } state_t;

    state_t state;

    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            rd_uart_reg <= 1'b0;
            wr_uart_reg <= 1'b0;
            valid_reg   <= 1'b0;
            data_buf    <= '0;
            state       <= IDLE;
        end else begin
            rd_uart_reg <= 1'b0;
            wr_uart_reg <= 1'b0;

            case (state)
                IDLE: begin
                    if (!empty_o) begin
                        rd_uart_reg <= 1'b1; // Reading RX FIFO
                        state       <= READ;
                    end
                end

                READ: begin
                    // Data ready
                    data_buf  <= uart_data_loopback_w;
                    valid_reg <= 1'b1;
                    state     <= WRITE;
                end

                WRITE: begin
                    if (!tx_full_o) begin
                        wr_uart_reg <= 1'b1; // Writing TX FIFO
                        valid_reg   <= 1'b0;
                        state       <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

    uart_top #(
        .DATA_BIT(DATA_BIT),    
        .SB_TICK(SB_TICK),
        .FIFO_W(FIFO_W),      
        .BAUDRATE_CFG(BAUDRATE_CFG),
        .SYS_CLK_CFG(SYS_CLK_CFG)
    ) uart_top_unit (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        // TX
        .wr_uart_i(wr_uart_reg),
        .wr_data_i(data_buf),
        .tx_full_o(tx_full_o),
        .uart_tx_o(tx),
        // RX
        .rd_uart_i(rd_uart_reg),
        .uart_rx_i(rx_sync_2),
        .rd_data_o(uart_data_loopback_w),
        .rx_empty_o(empty_o)
    );

endmodule