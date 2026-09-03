//============================================================
// File        : ram_reg_adapter.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : Adapter between UVM RAL and RAM sequence item
//============================================================

class ram_reg_adapter extends uvm_reg_adapter;

    //========================================================
    // Factory registration
    //========================================================

    `uvm_object_utils(ram_reg_adapter)


    //========================================================
    // Configuration
    //========================================================

    // RAL bus is 32 bits wide.
    localparam int BUS_BYTES = DATA_WIDTH / 8;


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ram_reg_adapter"
    );

        super.new(name);

        // RAL operations do not have a separate bus response
        // object in our simple RAM protocol.
        provides_responses = 0;

    endfunction


    //========================================================
    // RAL -> RAM transaction
    //========================================================

    virtual function uvm_sequence_item reg2bus(
        const ref uvm_reg_bus_op rw
    );

        ram_seq_item tr;

        tr = ram_seq_item::type_id::create("tr");

        //----------------------------------------------------
        // Convert RAL byte address to RAM word address.
        //
        // Example for 32-bit RAM:
        //
        // RAL address 0x00 -> RAM address 0
        // RAL address 0x04 -> RAM address 1
        // RAL address 0x08 -> RAM address 2
        //----------------------------------------------------

        tr.addr = rw.addr / BUS_BYTES;

        //----------------------------------------------------
        // Operation
        //----------------------------------------------------

        if (rw.kind == UVM_WRITE) begin

            tr.write = 1'b1;
            tr.wdata = rw.data;

        end
        else begin

            tr.write = 1'b0;
            tr.wdata = '0;

        end

        return tr;

    endfunction


    //========================================================
    // RAM transaction -> RAL response
    //========================================================

    virtual function void bus2reg(
        uvm_sequence_item bus_item,
        ref uvm_reg_bus_op rw
    );

        ram_seq_item tr;

        //----------------------------------------------------
        // Cast generic sequence item back to RAM transaction
        //----------------------------------------------------

        if (!$cast(tr, bus_item)) begin

            `uvm_fatal(
                "RAM_ADAPTER",
                "bus_item is not a ram_seq_item"
            )

        end


        //----------------------------------------------------
        // Return address
        //
        // Convert RAM word address back to byte address.
        //----------------------------------------------------

        rw.addr = tr.addr * BUS_BYTES;


        //----------------------------------------------------
        // Return operation type
        //----------------------------------------------------

        if (tr.write)
            rw.kind = UVM_WRITE;
        else
            rw.kind = UVM_READ;


        //----------------------------------------------------
        // Return data
        //----------------------------------------------------

        if (tr.write) begin

            rw.data = tr.wdata;

        end
        else begin

            rw.data = tr.rdata;

        end


        //----------------------------------------------------
        // RAM response status
        //----------------------------------------------------

        if (tr.ready)
            rw.status = UVM_IS_OK;
        else
            rw.status = UVM_NOT_OK;

    endfunction

endclass
