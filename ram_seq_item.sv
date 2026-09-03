//============================================================
// File        : ram_seq_item.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : RAM transaction item
//============================================================

class ram_seq_item extends uvm_sequence_item;

    //========================================================
    // Transaction fields
    //========================================================

    rand bit                    write;
    rand bit [ADDR_WIDTH-1:0]  addr;
    rand bit [DATA_WIDTH-1:0]  wdata;

    // Response fields
    bit [DATA_WIDTH-1:0]        rdata;
    bit                         ready;


    //========================================================
    // Constraints
    //========================================================

    constraint valid_write_data_c {
        if (!write)
            wdata == '0;
    }


    //========================================================
    // Factory registration and field automation
    //========================================================

    `uvm_object_utils_begin(ram_seq_item)

        `uvm_field_int(
            write,
            UVM_ALL_ON
        )

        `uvm_field_int(
            addr,
            UVM_ALL_ON
        )

        `uvm_field_int(
            wdata,
            UVM_ALL_ON
        )

        `uvm_field_int(
            rdata,
            UVM_ALL_ON
        )

        `uvm_field_int(
            ready,
            UVM_ALL_ON
        )

    `uvm_object_utils_end


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ram_seq_item"
    );

        super.new(name);

    endfunction


    //========================================================
    // Convert transaction to string
    //========================================================

    function string convert2string();

        return $sformatf(
            "write=%0b addr=0x%0h wdata=0x%0h rdata=0x%0h ready=%0b",
            write,
            addr,
            wdata,
            rdata,
            ready
        );

    endfunction


    //========================================================
    // Do print
    //========================================================

    function void do_print(
        uvm_printer printer
    );

        super.do_print(printer);

        printer.print_field_int(
            "write",
            write,
            1,
            UVM_BIN
        );

        printer.print_field_int(
            "addr",
            addr,
            ADDR_WIDTH,
            UVM_HEX
        );

        printer.print_field_int(
            "wdata",
            wdata,
            DATA_WIDTH,
            UVM_HEX
        );

        printer.print_field_int(
            "rdata",
            rdata,
            DATA_WIDTH,
            UVM_HEX
        );

        printer.print_field_int(
            "ready",
            ready,
            1,
            UVM_BIN
        );

    endfunction

endclass
