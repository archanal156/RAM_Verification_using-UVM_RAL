//============================================================
// File        : ram_assertions.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : SystemVerilog Assertions for RAM protocol
//============================================================

module ram_assertions #(
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 32
)(
    input logic                  clk,
    input logic                  rst_n,

    input logic                  req,
    input logic                  write,
    input logic [ADDR_WIDTH-1:0] addr,
    input logic [DATA_WIDTH-1:0] wdata,

    input logic [DATA_WIDTH-1:0] rdata,
    input logic                  ready
);

    //========================================================
    // 1. READY must only be asserted for a valid request
    //========================================================

    property p_ready_requires_req;
        @(posedge clk)
        disable iff (!rst_n)
        ready |-> req;
    endproperty

    a_ready_requires_req:
        assert property (p_ready_requires_req)
        else
            $error(
                "RAM Assertion Failed: READY asserted without REQ"
            );


    //========================================================
    // 2. Every request must receive READY in the same cycle
    //
    // Based on the current RAM implementation:
    //
    // if req == 1
    // then ready == 1
    //========================================================

    property p_req_gets_ready;
        @(posedge clk)
        disable iff (!rst_n)
        req |-> ready;
    endproperty

    a_req_gets_ready:
        assert property (p_req_gets_ready)
        else
            $error(
                "RAM Assertion Failed: REQ did not receive READY"
            );


    //========================================================
    // 3. Write request must have WRITE asserted
    //
    // This is primarily a protocol sanity check.
    //========================================================

    property p_write_signal_known;
        @(posedge clk)
        disable iff (!rst_n)
        req |-> (write == 1'b0 || write == 1'b1);
    endproperty

    a_write_signal_known:
        assert property (p_write_signal_known)
        else
            $error(
                "RAM Assertion Failed: WRITE signal is unknown"
            );


    //========================================================
    // 4. RESET must clear RDATA
    //
    // Your RTL explicitly assigns rdata <= '0 when reset
    // is sampled on a clock edge.
    //========================================================

    property p_reset_clears_rdata;
        @(posedge clk)
        !rst_n |=> (rdata == '0);
    endproperty

    a_reset_clears_rdata:
        assert property (p_reset_clears_rdata)
        else
            $error(
                "RAM Assertion Failed: RDATA not cleared during reset"
            );


    //========================================================
    // 5. READY is a one-cycle response
    //
    // If REQ is removed, READY should be removed on the
    // following clock according to the current DUT.
    //========================================================

    property p_ready_deasserts_without_req;
        @(posedge clk)
        disable iff (!rst_n)
        (!req) |=> (!ready);
    endproperty

    a_ready_deasserts_without_req:
        assert property (p_ready_deasserts_without_req)
        else
            $error(
                "RAM Assertion Failed: READY remained asserted "
                "after request was removed"
            );


    //========================================================
    // 6. No X/Z on control signals during a valid transaction
    //========================================================

    property p_no_unknown_control;
        @(posedge clk)
        disable iff (!rst_n)
        req |-> !$isunknown({write, addr});
    endproperty

    a_no_unknown_control:
        assert property (p_no_unknown_control)
        else
            $error(
                "RAM Assertion Failed: Unknown control/address "
                "during valid request"
            );


    //========================================================
    // 7. No X/Z on write data during a write transaction
    //========================================================

    property p_no_unknown_wdata;
        @(posedge clk)
        disable iff (!rst_n)
        (req && write) |-> !$isunknown(wdata);
    endproperty

    a_no_unknown_wdata:
        assert property (p_no_unknown_wdata)
        else
            $error(
                "RAM Assertion Failed: Unknown WDATA during write"
            );


    //========================================================
    // 8. No X/Z on RDATA when a read completes
    //========================================================

    property p_no_unknown_rdata;
        @(posedge clk)
        disable iff (!rst_n)
        (req && !write && ready) |-> !$isunknown(rdata);
    endproperty

    a_no_unknown_rdata:
        assert property (p_no_unknown_rdata)
        else
            $error(
                "RAM Assertion Failed: Unknown RDATA on read"
            );

endmodule
