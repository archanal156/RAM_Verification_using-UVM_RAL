//============================================================
// File        : ram_monitor.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : Passive UVM monitor for RAM transactions
//============================================================

class ram_monitor extends uvm_monitor;

    //========================================================
    // Virtual interface
    //========================================================

    virtual ram_if #(ADDR_WIDTH, DATA_WIDTH) vif;


    //========================================================
    // Analysis port
    //
    // Sends observed transactions to:
    //   - Scoreboard
    //   - Coverage
    //   - RAL predictor
    //========================================================

    uvm_analysis_port #(ram_seq_item) analysis_port;


    //========================================================
    // Factory registration
    //========================================================

    `uvm_component_utils(ram_monitor)


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ram_monitor",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction


    //========================================================
    // Build phase
    //========================================================

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        // Create analysis port
        analysis_port = new("analysis_port", this);

        // Get virtual interface
        if (!uvm_config_db#(
                virtual ram_if #(ADDR_WIDTH, DATA_WIDTH)
            )::get(this, "", "vif", vif)) begin

            `uvm_fatal(
                "NO_VIF",
                "Virtual interface was not found in ram_monitor"
            )

        end

    endfunction


    //========================================================
    // Run phase
    //========================================================

    task run_phase(uvm_phase phase);

        forever begin

            // Wait for a clock
            @(vif.mon_cb);

            // Ignore reset
            if (!vif.mon_cb.rst_n)
                continue;

            // A transaction is considered complete when
            // req and ready are both asserted.
            if (vif.mon_cb.req && vif.mon_cb.ready) begin

                collect_transaction();

            end

        end

    endtask


    //========================================================
    // Collect transaction
    //========================================================

    task collect_transaction();

        ram_seq_item tr;

        // Create transaction
        tr = ram_seq_item::type_id::create("tr");

        // Capture common transaction information
        tr.write = vif.mon_cb.write;
        tr.addr  = vif.mon_cb.addr;
        tr.wdata = vif.mon_cb.wdata;
        tr.ready = vif.mon_cb.ready;

        // Capture read data only for read transactions
        if (!vif.mon_cb.write) begin
            tr.rdata = vif.mon_cb.rdata;
        end
        else begin
            tr.rdata = '0;
        end

        `uvm_info(
            "RAM_MON",
            $sformatf(
                "Observed transaction: %s",
                tr.convert2string()
            ),
            UVM_MEDIUM
        );

        // Broadcast transaction
        analysis_port.write(tr);

    endtask

endclass

