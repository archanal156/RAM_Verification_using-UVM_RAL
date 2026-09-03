//============================================================
// File        : ram_random_test.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : Constrained-random RAM test
//============================================================

class ram_random_test extends ram_base_test;

    //========================================================
    // Factory registration
    //========================================================

    `uvm_component_utils(ram_random_test)


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ram_random_test",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction


    //========================================================
    // Run phase
    //========================================================

    task run_phase(uvm_phase phase);

        ram_random_seq seq;


        //----------------------------------------------------
        // Create sequence
        //----------------------------------------------------

        seq = ram_random_seq::type_id::create(
            "seq"
        );


        //----------------------------------------------------
        // Raise objection
        //----------------------------------------------------

        phase.raise_objection(this);


        `uvm_info(
            "RAM_TEST",
            "Starting RAM random test",
            UVM_MEDIUM
        );


        //----------------------------------------------------
        // Start random sequence
        //----------------------------------------------------

        seq.start(
            env.agent.sequencer
        );


        `uvm_info(
            "RAM_TEST",
            "RAM random sequence completed",
            UVM_MEDIUM
        );


        //----------------------------------------------------
        // Drop objection
        //----------------------------------------------------

        phase.drop_objection(this);

    endtask

endclass
