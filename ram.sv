//============================================================
// File        : ram.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : Parameterized synchronous single-port RAM
//============================================================

module ram #(
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst_n,

    // Request interface
    input  logic                  req,
    input  logic                  write,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [DATA_WIDTH-1:0] wdata,

    // Response interface
    output logic [DATA_WIDTH-1:0] rdata,
    output logic                  ready
);

    // Number of memory locations
    localparam int DEPTH = 1 << ADDR_WIDTH;

    // Memory array
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    //--------------------------------------------------------
    // Synchronous RAM operation
    //--------------------------------------------------------
    always_ff @(posedge clk) begin

        // Default response
        ready <= 1'b0;

        // Active-low synchronous reset
        if (!rst_n) begin
            rdata <= '0;
        end

        // Valid request
        else if (req) begin

            // Request accepted
            ready <= 1'b1;

            // Write operation
            if (write) begin
                mem[addr] <= wdata;
            end

            // Read operation
            else begin
                rdata <= mem[addr];
            end
        end
    end

endmodule
