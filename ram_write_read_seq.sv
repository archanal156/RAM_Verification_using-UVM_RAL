//============================================================
// File        : ram_write_read_seq.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : Basic write/read sequence for RAM
//============================================================

class ram_write_read_seq extends ram_base_seq;

    //========================================================
    // Factory registration
    //========================================================

    `uvm_object_utils(ram_write_read_seq)


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ram_write_read_seq"
    );

        super.new(name);

    endfunction


    //========================================================
    // Body
    //========================================================

    virtual task body();

        bit [DATA_WIDTH-1:0] rdata;


        `uvm_info(
            "RAM_SEQ",
            "Starting RAM write/read sequence",
            UVM_MEDIUM
        );


        //----------------------------------------------------
        // Address 0
        //----------------------------------------------------

        write_mem(
            'h0,
            'hAAAAAAAA
        );

        read_mem(
            'h0,
            rdata
        );

        `uvm_info(
            "RAM_SEQ",
            $sformatf(
                "Address 0: read data = 0x%0h",
                rdata
            ),
            UVM_MEDIUM
        );


        //----------------------------------------------------
        // Address 1
        //----------------------------------------------------

        write_mem(
            'h1,
            'h55555555
        );

        read_mem(
            'h1,
            rdata
        );

        `uvm_info(
            "RAM_SEQ",
            $sformatf(
                "Address 1: read data = 0x%0h",
                rdata
            ),
            UVM_MEDIUM
        );


        //----------------------------------------------------
        // Middle address
        //----------------------------------------------------

        write_mem(
            DEPTH/2,
            'hDEADBEEF
        );

        read_mem(
            DEPTH/2,
            rdata
        );

        `uvm_info(
            "RAM_SEQ",
            $sformatf(
                "Middle address: read data = 0x%0h",
                rdata
            ),
            UVM_MEDIUM
        );


        //----------------------------------------------------
        // Last address
        //----------------------------------------------------

        write_mem(
            DEPTH-1,
            'h12345678
        );

        read_mem(
            DEPTH-1,
            rdata
        );

        `uvm_info(
            "RAM_SEQ",
            $sformatf(
                "Last address: read data = 0x%0h",
                rdata
            ),
            UVM_MEDIUM
        );


        `uvm_info(
            "RAM_SEQ",
            "RAM write/read sequence completed",
            UVM_MEDIUM
        );

    endtask

endclass
