module reg_file #(
    parameter   DATA_WIDTH = 8, // number of bits
    parameter   ADDR_WIDTH = 2  // number of address bits
) (
    input  logic                    clk_i,
    input  logic                    wr_en_i,
    input  logic [ADDR_WIDTH-1:0]   wr_addr_i,
    input  logic [ADDR_WIDTH-1:0]   rd_addr_i,
    input  logic [DATA_WIDTH-1:0]   wr_data_i,
    output logic [DATA_WIDTH-1:0]   rd_data_o
);
    logic [DATA_WIDTH-1:0] register_file [0:2**ADDR_WIDTH-1];

    // Write operation
    always_ff @(posedge clk_i) begin
        if (wr_en_i) begin
            register_file[wr_addr_i] <= wr_data_i;
        end
    end

    // Read operation
    // assign rd_data_o = register_file[rd_addr_i];
    assign rd_data_o = (wr_en_i && (wr_addr_i == rd_addr_i)) 
                   ? wr_data_i                      // Forwarding 
                   : register_file[rd_addr_i];      // 
endmodule