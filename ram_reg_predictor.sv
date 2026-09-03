//============================================================
// File        : ram_reg_predictor.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : RAL predictor for RAM bus transactions
//============================================================

class ram_reg_predictor extends uvm_reg_predictor #(ram_seq_item);

    //========================================================
    // Factory registration
    //========================================================

    `uvm_component_utils(ram_reg_predictor)


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ram_reg_predictor",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction

endclass
