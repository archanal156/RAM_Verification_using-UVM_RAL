//============================================================
// File        : ram_base_seq.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : Base sequence for RAM verification
//============================================================

class ram_base_seq extends uvm_sequence #(ram_seq_item);

    //========================================================
    // Factory registration
    //========================================================

    `uvm_object_utils(ram_base_seq)


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ram_base_seq"
    );

        super.new(name);

    endfunction


    //========================================================
    // Body
    //========================================================

    virtual task body();

        `uvm_info(
            "RAM_SEQ",
            "Starting RAM base sequence",
            UVM_MEDIUM
        );

    endtask


    //========================================================
    // Write helper
    //========================================================

    task write_mem(
        bit [ADDR_WIDTH-1:0] addr,
        bit [DATA_WIDTH-1:0] data
    );

        ram_seq_item tr;

        tr = ram_seq_item::type_id::create(
            "tr"
        );

        start_item(tr);

        tr.write = 1'b1;
        tr.addr  = addr;
        tr.wdata = data;

        finish_item(tr);

    endtask


    //========================================================
    // Read helper
    //========================================================

    task read_mem(
        bit [ADDR_WIDTH-1:0] addr,
        output bit [DATA_WIDTH-1:0] data
    );

        ram_seq_item tr;

        tr = ram_seq_item::type_id::create(
            "tr"
        );

        start_item(tr);

        tr.write = 1'b0;
        tr.addr  = addr;
        tr.wdata = '0;

        finish_item(tr);

        data = tr.rdata;

    endtask

endclass
