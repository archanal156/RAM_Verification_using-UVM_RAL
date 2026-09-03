//============================================================
// File        : ram_if.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : Interface between DUT and UVM testbench
//============================================================

interface ram_if #(
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 32
)(
    input logic clk
);

    //========================================================
    // DUT signals
    //========================================================

    logic                  rst_n;

    logic                  req;
    logic                  write;
    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] wdata;

    logic [DATA_WIDTH-1:0] rdata;
    logic                  ready;


    //========================================================
    // Driver Clocking Block
    //
    // Used by the UVM driver to drive DUT inputs.
    //========================================================

    clocking drv_cb @(posedge clk);

        default input #1step output #1step;

        output rst_n;
        output req;
        output write;
        output addr;
        output wdata;

        input  rdata;
        input  ready;

    endclocking


    //========================================================
    // Monitor Clocking Block
    //
    // Used by the UVM monitor to sample DUT activity.
    //========================================================

    clocking mon_cb @(posedge clk);

        default input #1step output #1step;

        input rst_n;
        input req;
        input write;
        input addr;
        input wdata;

        input rdata;
        input ready;

    endclocking


    //========================================================
    // Modports
    //========================================================

    modport DRIVER (
        clocking drv_cb
    );

    modport MONITOR (
        clocking mon_cb
    );

endinterface
