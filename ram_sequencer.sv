//============================================================
// File        : ram_sequencer.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : UVM sequencer for RAM transactions
//============================================================

class ram_sequencer extends uvm_sequencer #(ram_seq_item);

    //========================================================
    // Factory registration
    //========================================================

    `uvm_component_utils(ram_sequencer)


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ram_sequencer",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

endclass
