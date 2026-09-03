//============================================================
// File        : ram_ral_test.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : RAL-based RAM frontdoor access test
//============================================================

class ram_ral_test extends ram_base_test;

    //========================================================
    // Factory registration
    //========================================================

    `uvm_component_utils(ram_ral_test)


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ram_ral_test",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction


    //========================================================
    // Run phase
    //========================================================

    task run_phase(uvm_phase phase);

        ral_access_seq seq;


        //----------------------------------------------------
        // Create RAL sequence
        //----------------------------------------------------

        seq = ral_access_seq::type_id::create(
            "seq"
        );


        //----------------------------------------------------
        // Pass RAL model to sequence
        //----------------------------------------------------

        seq.ral_model = env.ral_model;


        //----------------------------------------------------
        // Raise objection
        //----------------------------------------------------

        phase.raise_objection(this);


        `uvm_info(
            "RAM_RAL_TEST",
            "Starting RAL frontdoor test",
            UVM_MEDIUM
        );


        //----------------------------------------------------
        // Start RAL sequence
        //----------------------------------------------------

        seq.start(
            env.agent.sequencer
        );


        `uvm_info(
            "RAM_RAL_TEST",
            "RAL frontdoor test completed",
            UVM_MEDIUM
        );


        //----------------------------------------------------
        // Drop objection
        //----------------------------------------------------

        phase.drop_objection(this);

    endtask

endclass
