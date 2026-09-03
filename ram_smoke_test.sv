//============================================================
// File        : ram_smoke_test.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : Basic directed smoke test for RAM
//============================================================

class ram_smoke_test extends ram_base_test;

    //========================================================
    // Factory registration
    //========================================================

    `uvm_component_utils(ram_smoke_test)


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ram_smoke_test",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction


    //========================================================
    // Run phase
    //========================================================

    task run_phase(uvm_phase phase);

        ram_write_read_seq seq;


        //----------------------------------------------------
        // Create sequence
        //----------------------------------------------------

        seq = ram_write_read_seq::type_id::create(
            "seq"
        );


        //----------------------------------------------------
        // Raise objection
        //----------------------------------------------------

        phase.raise_objection(this);


        `uvm_info(
            "RAM_TEST",
            "Starting RAM smoke test",
            UVM_MEDIUM
        );


        //----------------------------------------------------
        // Start sequence
        //----------------------------------------------------

        seq.start(
            env.agent.sequencer
        );


        `uvm_info(
            "RAM_TEST",
            "RAM smoke sequence completed",
            UVM_MEDIUM
        );


        //----------------------------------------------------
        // Drop objection
        //----------------------------------------------------

        phase.drop_objection(this);

    endtask

endclass
