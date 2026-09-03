//============================================================
// File        : testbench.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : Top-level simulation module
//============================================================

package ram_pkg;

    //========================================================
    // UVM
    //========================================================

    import uvm_pkg::*;

    `include "uvm_macros.svh"


    //========================================================
    // Common RAM parameters
    //========================================================

    parameter int ADDR_WIDTH = 8;
    parameter int DATA_WIDTH = 32;

    parameter int DEPTH = (1 << ADDR_WIDTH);


    //========================================================
    // Transaction
    //========================================================

    `include "ram_seq_item.sv"


    //========================================================
    // Sequencer
    //========================================================

    `include "ram_sequencer.sv"


    //========================================================
    // Driver
    //========================================================

    `include "ram_driver.sv"


    //========================================================
    // Monitor
    //========================================================

    `include "ram_monitor.sv"


    //========================================================
    // Agent
    //========================================================

    `include "ram_agent.sv"


    //========================================================
    // RAL
    //========================================================

    `include "ram_reg_model.sv"
    `include "ram_reg_adapter.sv"
    `include "ram_reg_predictor.sv"


    //========================================================
    // Scoreboard
    //========================================================

    `include "ram_scoreboard.sv"


    //========================================================
    // Coverage
    //========================================================

    `include "ram_coverage.sv"


    //========================================================
    // Environment
    //========================================================

    `include "ram_env.sv"


    //========================================================
    // Sequences
    //========================================================

    `include "ram_base_seq.sv"
    `include "ram_write_read_seq.sv"
    `include "ram_random_seq.sv"
    `include "ral_access_seq.sv"


    //========================================================
    // Tests
    //========================================================

    `include "ram_base_test.sv"
    `include "ram_smoke_test.sv"
    `include "ram_random_test.sv"
    `include "ram_ral_test.sv"


endpackage


 //========================================================
 // RAM Interface
 //========================================================

	`include "ram_if.sv"

 import ram_pkg::*;
`timescale 1ns/1ps


module tb_top;

    //import uvm_pkg::*;

    //========================================================
    // Common parameters
    //========================================================

    parameter int ADDR_WIDTH = 8;
    parameter int DATA_WIDTH = 32;


    //========================================================
    // Clock
    //========================================================

    logic clk;


    //========================================================
    // RAM interface
    //========================================================

    ram_if #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) ram_vif (
        .clk (clk)
    );


    //========================================================
    // DUT
    //========================================================

    ram #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) dut (

        .clk   (clk),
        .rst_n (ram_vif.rst_n),

        .req   (ram_vif.req),
        .write (ram_vif.write),
        .addr  (ram_vif.addr),
        .wdata (ram_vif.wdata),

        .rdata (ram_vif.rdata),
        .ready (ram_vif.ready)

    );


    //========================================================
    // Clock generation
    //========================================================

    initial begin

        clk = 1'b0;

        forever begin
            #5 clk = ~clk;
        end

    end


    //========================================================
    // Reset generation
    //========================================================

    initial begin

        ram_vif.rst_n = 1'b0;

        // Hold reset for two clock cycles
        repeat (2) @(posedge clk);

        ram_vif.rst_n = 1'b1;

    end


    //========================================================
    // UVM configuration
    //========================================================

    initial begin

        //----------------------------------------------------
        // Pass virtual interface to UVM environment
        //----------------------------------------------------

        uvm_config_db#(virtual ram_if)::set(
            null,
            "*",
            "vif",
            ram_vif
        );


        //----------------------------------------------------
        // Start UVM test
        //----------------------------------------------------

      run_test("ram_random_test");

    end

endmodule
