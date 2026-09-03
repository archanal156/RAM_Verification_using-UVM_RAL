//============================================================
// File        : ram_coverage.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : Functional coverage for RAM transactions
//============================================================

class ram_coverage extends uvm_subscriber #(ram_seq_item);

    //========================================================
    // Transaction sampled by the coverage component
    //========================================================

    ram_seq_item tr;


    //========================================================
    // Covergroup
    //========================================================

    covergroup ram_cg;

        option.per_instance = 1;


        //----------------------------------------------------
        // Read / Write operation
        //----------------------------------------------------

        cp_operation: coverpoint tr.write {

            bins READ  = {0};
            bins WRITE = {1};

        }


        //----------------------------------------------------
        // Address coverage
        //----------------------------------------------------

        cp_address: coverpoint tr.addr {

            bins FIRST = {0};

            bins LOW = {
                [1 : (DEPTH/4)-1]
            };

            bins MID_LOW = {
                [DEPTH/4 : (DEPTH/2)-1]
            };

            bins MID_HIGH = {
                [DEPTH/2 : (3*DEPTH/4)-1]
            };

            bins HIGH = {
                [(3*DEPTH/4) : DEPTH-2]
            };

            bins LAST = {DEPTH-1};

        }


        //----------------------------------------------------
        // Data pattern coverage
        //----------------------------------------------------

        cp_wdata: coverpoint tr.wdata {

            bins ZERO = {
                '0
            };

            bins ALL_ONES = {
                {DATA_WIDTH{1'b1}}
            };

            bins ALTERNATING_01 = {
                {DATA_WIDTH/2{2'b01}}
            };

            bins ALTERNATING_10 = {
                {DATA_WIDTH/2{2'b10}}
            };

            bins OTHER = default;

        }


        //----------------------------------------------------
        // Ready response
        //----------------------------------------------------

        cp_ready: coverpoint tr.ready {

            bins READY = {1};

        }


        //----------------------------------------------------
        // Read/Write × Address region
        //----------------------------------------------------

        operation_address_cross:
            cross cp_operation, cp_address;


        //----------------------------------------------------
        // Write × Data pattern
        //----------------------------------------------------

        write_data_cross:
            cross cp_operation, cp_wdata;

    endgroup


    //========================================================
    // Factory registration
    //========================================================

    `uvm_component_utils(ram_coverage)


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ram_coverage",
        uvm_component parent = null
    );

        super.new(name, parent);

        ram_cg = new();

    endfunction


    //========================================================
    // Write method
    //
    // Called automatically through uvm_subscriber.
    //========================================================

    function void write(ram_seq_item t);

        tr = t;

        ram_cg.sample();

    endfunction


    //========================================================
    // Report phase
    //========================================================

    function void report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info(
            "RAM_COV",
            $sformatf(
                "RAM functional coverage = %0.2f%%",
                ram_cg.get_coverage()
            ),
            UVM_NONE
        );

    endfunction

endclass
