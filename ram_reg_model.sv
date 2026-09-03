//============================================================
// File        : ram_reg_model.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : UVM RAL model for parameterized RAM
//============================================================

class ram_reg_block extends uvm_reg_block;

    //========================================================
    // RAM memory model
    //========================================================

    uvm_mem RAM;


    //========================================================
    // Factory registration
    //========================================================

    `uvm_object_utils(ram_reg_block)


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ram_reg_block"
    );

        super.new(name, UVM_NO_COVERAGE);

    endfunction


    //========================================================
    // Build RAL model
    //========================================================

    virtual function void build();

        //====================================================
        // Create RAM memory
        //
        // Depth     = 256
        // Width     = 32 bits
        // Access    = RW
        // Coverage  = disabled here
        //====================================================

        RAM = new(
    "RAM",
    DEPTH,
    DATA_WIDTH,
    "RW",
    UVM_NO_COVERAGE
);

RAM.configure(this);

default_map = create_map(

            "default_map",
            'h0,
            4,
            UVM_LITTLE_ENDIAN,
            1
        );

        //====================================================
        // Add RAM to the address map
        //
        // Offset = 0x0000
        // Access = RW
        //====================================================

        default_map.add_mem(
            RAM,
            'h0,
            "RW"
        );

        //====================================================
        // Make default map
        //====================================================

        default_map.set_auto_predict(0);

        lock_model();

    endfunction

endclass
