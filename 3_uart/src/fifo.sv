module fifo #(
    parameter   DATA_WIDTH = 8, // number of bits
    parameter   ADDR_WIDTH = 4  // number of address bits   
) (
    input  logic                    clk_i,
    input  logic                    rstn_i,
    input  logic                    read_i,
    input  logic                    write_i,
    input  logic [DATA_WIDTH-1:0]   wr_data_i,
    output logic                    empty_o,
    output logic                    full_o,
    output logic [DATA_WIDTH-1:0]   rd_data_o
);
    //signal declaration
    logic [ADDR_WIDTH-1:0]   wr_addr_w, rd_addr_w;
    logic                    wr_en_w, full_tmp;

    // body
    // write enabled only when FIFO is not full
    assign wr_en_w = write_i & ~full_tmp;
    assign full_o  = full_tmp;

    // instantiate fifo control unit
    fifo_control #(.ADDR_WIDTH(ADDR_WIDTH)) fifo_control_unit (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .read_i(read_i),
        .write_i(write_i),
        .empty_o(empty_o),
        .full_o(full_tmp),
        .wr_addr_o(wr_addr_w),
        .rd_addr_o(rd_addr_w)
    );

    // instantiate register file
    reg_file #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) reg_file_unit (
        .clk_i(clk_i),
        .wr_en_i(wr_en_w),
        .wr_addr_i(wr_addr_w),
        .rd_addr_i(rd_addr_w),
        .wr_data_i(wr_data_i),
        .rd_data_o(rd_data_o)
    );

endmodule