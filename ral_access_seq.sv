//============================================================
// File        : ral_access_seq.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : RAL frontdoor access sequence for RAM
//============================================================

class ral_access_seq extends uvm_sequence #(ram_seq_item);

    //========================================================
    // RAL model
    //========================================================

    ram_reg_block ral_model;


    //========================================================
    // Factory registration
    //========================================================

    `uvm_object_utils(ral_access_seq)


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ral_access_seq"
    );

        super.new(name);

    endfunction


    //========================================================
    // Body
    //========================================================

    virtual task body();

        uvm_status_e status;

        bit [DATA_WIDTH-1:0] read_data;


        //----------------------------------------------------
        // Make sure the RAL model has been provided
        //----------------------------------------------------

        if (ral_model == null) begin

            `uvm_fatal(
                "RAL_SEQ",
                "RAL model handle is null"
            )

        end


        `uvm_info(
            "RAL_SEQ",
            "Starting RAL frontdoor access sequence",
            UVM_MEDIUM
        );


        //----------------------------------------------------
        // RAL WRITE - Address 0
        //----------------------------------------------------

        ral_model.RAM.write(
            status,
            0,
            32'hAAAAAAAA,
            UVM_FRONTDOOR
        );

        check_status(
            status,
            "RAL WRITE address 0"
        );


        //----------------------------------------------------
        // RAL READ - Address 0
        //----------------------------------------------------

        ral_model.RAM.read(
            status,
            0,
            read_data,
            UVM_FRONTDOOR
        );

        check_status(
            status,
            "RAL READ address 0"
        );

        `uvm_info(
            "RAL_SEQ",
            $sformatf(
                "RAL READ addr=0 data=0x%0h",
                read_data
            ),
            UVM_MEDIUM
        );


        //----------------------------------------------------
        // RAL WRITE - Address 1
        //----------------------------------------------------

        ral_model.RAM.write(
            status,
            1,
            32'h55555555,
            UVM_FRONTDOOR
        );

        check_status(
            status,
            "RAL WRITE address 1"
        );


        //----------------------------------------------------
        // RAL READ - Address 1
        //----------------------------------------------------

        ral_model.RAM.read(
            status,
            1,
            read_data,
            UVM_FRONTDOOR
        );

        check_status(
            status,
            "RAL READ address 1"
        );

        `uvm_info(
            "RAL_SEQ",
            $sformatf(
                "RAL READ addr=1 data=0x%0h",
                read_data
            ),
            UVM_MEDIUM
        );


        //----------------------------------------------------
        // RAL WRITE - Middle location
        //----------------------------------------------------

        ral_model.RAM.write(
            status,
            DEPTH/2,
            32'hDEADBEEF,
            UVM_FRONTDOOR
        );

        check_status(
            status,
            "RAL WRITE middle address"
        );


        //----------------------------------------------------
        // RAL READ - Middle location
        //----------------------------------------------------

        ral_model.RAM.read(
            status,
            DEPTH/2,
            read_data,
            UVM_FRONTDOOR
        );

        check_status(
            status,
            "RAL READ middle address"
        );

        `uvm_info(
            "RAL_SEQ",
            $sformatf(
                "RAL READ middle addr=%0d data=0x%0h",
                DEPTH/2,
                read_data
            ),
            UVM_MEDIUM
        );


        //----------------------------------------------------
        // RAL WRITE - Last location
        //----------------------------------------------------

        ral_model.RAM.write(
            status,
            DEPTH-1,
            32'h12345678,
            UVM_FRONTDOOR
        );

        check_status(
            status,
            "RAL WRITE last address"
        );


        //----------------------------------------------------
        // RAL READ - Last location
        //----------------------------------------------------

        ral_model.RAM.read(
            status,
            DEPTH-1,
            read_data,
            UVM_FRONTDOOR
        );

        check_status(
            status,
            "RAL READ last address"
        );

        `uvm_info(
            "RAL_SEQ",
            $sformatf(
                "RAL READ last addr=%0d data=0x%0h",
                DEPTH-1,
                read_data
            ),
            UVM_MEDIUM
        );


        `uvm_info(
            "RAL_SEQ",
            "RAL frontdoor access sequence completed",
            UVM_MEDIUM
        );

    endtask


    //========================================================
    // Check RAL operation status
    //========================================================

    task check_status(
        uvm_status_e status,
        string operation
    );

        if (status != UVM_IS_OK) begin

            `uvm_error(
                "RAL_SEQ",
                $sformatf(
                    "%s failed with status %s",
                    operation,
                    status.name()
                )
            );

        end
        else begin

            `uvm_info(
                "RAL_SEQ",
                $sformatf(
                    "%s completed successfully",
                    operation
                ),
                UVM_MEDIUM
            );

        end

    endtask

endclass
