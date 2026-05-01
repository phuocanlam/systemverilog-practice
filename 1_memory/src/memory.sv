// memory.sv

module memory #(
    parameter WORDS = 64
) (
    input  logic 			clk_i,
	input  logic 			rstn_i,
    input  logic [31:0]		address_i,
    input  logic [31:0]		write_data_i,
    input  logic 			write_enable_i,

    output logic [31:0] 	read_data_o
);

/*
* This memory is byte addressed
* But have no support for mis-aligned write nor reads.
*/

reg [31:0] memory [0:WORDS-1];  // Memory array of words (32-bits)

always @(posedge clk_i) begin
    // reset logic
    if (rstn_i == 1'b0) begin
        for (int i = 0; i < WORDS; i++) begin
            memory[i] <= 32'b0;  
        end
    end
    else if (write_enable_i) begin
        // Ensure the address_i is aligned to a word boundary
        // If not, we ignore the write
        if (address_i[1:0] == 2'b00) begin 
            //here, address_i[31:2] is the word index
            memory[address_i[31:2]] <= write_data_i;
        end
    end
end

// Read logic
always_comb begin
    //here, address_i[31:2] is the word index
    read_data_o = memory[address_i[31:2]]; 
end

endmodule