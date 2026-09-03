//============================================================
// File        : ram_agent.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : UVM agent for RAM interface
//============================================================

class ram_agent extends uvm_agent;

    //========================================================
    // UVM components
    //========================================================

    ram_sequencer sequencer;
    ram_driver    driver;
    ram_monitor   monitor;


    //========================================================
    // Factory registration
    //========================================================

    `uvm_component_utils(ram_agent)


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ram_agent",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction


    //========================================================
    // Build phase
    //========================================================

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        // Create monitor
        monitor = ram_monitor::type_id::create(
            "monitor",
            this
        );

        // Create active components only when agent is active
        if (is_active == UVM_ACTIVE) begin

            sequencer = ram_sequencer::type_id::create(
                "sequencer",
                this
            );

            driver = ram_driver::type_id::create(
                "driver",
                this
            );

        end

    endfunction


    //========================================================
    // Connect phase
    //========================================================

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        if (is_active == UVM_ACTIVE) begin

            // Connect sequencer to driver
            driver.seq_item_port.connect(
                sequencer.seq_item_export
            );

        end

    endfunction

endclass
