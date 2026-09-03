//============================================================
// File        : ram_driver.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : UVM driver for RAM transactions
//============================================================

class ram_driver extends uvm_driver #(ram_seq_item);

    //========================================================
    // Virtual interface
    //========================================================

    virtual ram_if #(ADDR_WIDTH, DATA_WIDTH) vif;


    //========================================================
    // Factory registration
    //========================================================

    `uvm_component_utils(ram_driver)


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ram_driver",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction


    //========================================================
    // Build phase
    //========================================================

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db#(
                virtual ram_if #(ADDR_WIDTH, DATA_WIDTH)
            )::get(this, "", "vif", vif)) begin

            `uvm_fatal(
                "NO_VIF",
                "Virtual interface was not found in ram_driver"
            )

        end

    endfunction


    //========================================================
    // Run phase
    //========================================================

    task run_phase(uvm_phase phase);

        // Initialize DUT interface
        drive_idle();

        forever begin

            // Get transaction from sequencer
            seq_item_port.get_next_item(req);

            `uvm_info(
                "RAM_DRV",
                $sformatf(
                    "Driving transaction: %s",
                    req.convert2string()
                ),
                UVM_MEDIUM
            );

            // Drive transaction
            drive_transaction(req);

            // Tell sequencer transaction is complete
            seq_item_port.item_done();

        end

    endtask


    //========================================================
    // Drive transaction
    //========================================================

    task drive_transaction(ram_seq_item tr);

        if (tr.write)
            drive_write(tr);
        else
            drive_read(tr);

    endtask


    //========================================================
    // Write operation
    //========================================================

    task drive_write(ram_seq_item tr);

        // Wait for the next active clock edge
        @(vif.drv_cb);

        // Drive write request
        vif.drv_cb.req   <= 1'b1;
        vif.drv_cb.write <= 1'b1;
        vif.drv_cb.addr  <= tr.addr;
        vif.drv_cb.wdata <= tr.wdata;

        // Wait for DUT response
        do begin
            @(vif.drv_cb);
        end
        while (!vif.drv_cb.ready);

        // Capture response
        tr.ready = vif.drv_cb.ready;

        // Return interface to idle
        drive_idle();

        `uvm_info(
            "RAM_DRV",
            $sformatf(
                "WRITE completed: addr=0x%0h data=0x%0h",
                tr.addr,
                tr.wdata
            ),
            UVM_MEDIUM
        );

    endtask


    //========================================================
    // Read operation
    //========================================================

    task drive_read(ram_seq_item tr);

        // Wait for the next active clock edge
        @(vif.drv_cb);

        // Drive read request
        vif.drv_cb.req   <= 1'b1;
        vif.drv_cb.write <= 1'b0;
        vif.drv_cb.addr  <= tr.addr;
        vif.drv_cb.wdata <= '0;

        // Wait for DUT response
        do begin
            @(vif.drv_cb);
        end
        while (!vif.drv_cb.ready);

        // Capture response data
        tr.rdata = vif.drv_cb.rdata;
        tr.ready = vif.drv_cb.ready;

        // Return interface to idle
        drive_idle();

        `uvm_info(
            "RAM_DRV",
            $sformatf(
                "READ completed: addr=0x%0h data=0x%0h",
                tr.addr,
                tr.rdata
            ),
            UVM_MEDIUM
        );

    endtask


    //========================================================
    // Drive interface to idle
    //========================================================

    task drive_idle();

        vif.drv_cb.req   <= 1'b0;
        vif.drv_cb.write <= 1'b0;
        vif.drv_cb.addr  <= '0;
        vif.drv_cb.wdata <= '0;

    endtask

endclass
