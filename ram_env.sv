//============================================================
// File        : ram_env.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : Top-level UVM environment for RAM
//============================================================

class ram_env extends uvm_env;

    //========================================================
    // UVM components
    //========================================================

    ram_agent       agent;
    ram_scoreboard  scoreboard;
    ram_coverage    coverage;

    // RAL components
    ram_reg_block      ral_model;
    ram_reg_adapter    ral_adapter;
    ram_reg_predictor  ral_predictor;


    //========================================================
    // Factory registration
    //========================================================

    `uvm_component_utils(ram_env)


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ram_env",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction


    //========================================================
    // Build phase
    //========================================================

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);


        //----------------------------------------------------
        // Create RAM agent
        //----------------------------------------------------

        agent = ram_agent::type_id::create(
            "agent",
            this
        );


        //----------------------------------------------------
        // Create scoreboard
        //----------------------------------------------------

        scoreboard = ram_scoreboard::type_id::create(
            "scoreboard",
            this
        );


        //----------------------------------------------------
        // Create coverage
        //----------------------------------------------------

        coverage = ram_coverage::type_id::create(
            "coverage",
            this
        );


        //----------------------------------------------------
        // Create RAL model
        //----------------------------------------------------

        ral_model = ram_reg_block::type_id::create(
            "ral_model"
        );

        ral_model.build();


        //----------------------------------------------------
        // Create RAL adapter
        //----------------------------------------------------

        ral_adapter = ram_reg_adapter::type_id::create(
            "ral_adapter"
        );


        //----------------------------------------------------
        // Create RAL predictor
        //----------------------------------------------------

        ral_predictor = ram_reg_predictor::type_id::create(
            "ral_predictor",
            this
        );


        //----------------------------------------------------
        // Configure active agent
        //----------------------------------------------------

        agent.is_active = UVM_ACTIVE;

    endfunction


    //========================================================
    // Connect phase
    //========================================================

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);


        //----------------------------------------------------
        // Monitor -> Scoreboard
        //----------------------------------------------------

        agent.monitor.analysis_port.connect(
            scoreboard.analysis_imp
        );


        //----------------------------------------------------
        // Monitor -> Coverage
        //----------------------------------------------------

        agent.monitor.analysis_port.connect(
            coverage.analysis_export
        );


        //----------------------------------------------------
        // Monitor -> RAL Predictor
        //----------------------------------------------------

        agent.monitor.analysis_port.connect(
            ral_predictor.bus_in
        );


        //----------------------------------------------------
        // Configure RAL predictor
        //----------------------------------------------------

        ral_predictor.map     = ral_model.default_map;
        ral_predictor.adapter = ral_adapter;


        //----------------------------------------------------
        // Connect RAL frontdoor path
        //
        // RAL sequencer -> RAM sequencer
        //----------------------------------------------------

        ral_model.default_map.set_sequencer(
            agent.sequencer,
            ral_adapter
        );

    endfunction


    //========================================================
    // End-of-elaboration phase
    //========================================================

    function void end_of_elaboration_phase(
        uvm_phase phase
    );

        super.end_of_elaboration_phase(phase);

        `uvm_info(
            "RAM_ENV",
            "RAM UVM environment constructed successfully",
            UVM_NONE
        );

        `uvm_info(
            "RAM_ENV",
            "RAL model constructed and connected",
            UVM_NONE
        );

    endfunction

endclass

