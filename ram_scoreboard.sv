//============================================================
// File        : ram_scoreboard.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : Reference model and checker for RAM
//============================================================

class ram_scoreboard extends uvm_scoreboard;

    //========================================================
    // Analysis implementation
    //========================================================

    uvm_analysis_imp #(ram_seq_item, ram_scoreboard) analysis_imp;


    //========================================================
    // Shadow/reference memory
    //========================================================

    bit [DATA_WIDTH-1:0] expected_mem [0:DEPTH-1];


    //========================================================
    // Statistics
    //========================================================

    int unsigned write_count;
    int unsigned read_count;
    int unsigned error_count;


    //========================================================
    // Factory registration
    //========================================================

    `uvm_component_utils(ram_scoreboard)


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ram_scoreboard",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction


    //========================================================
    // Build phase
    //========================================================

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        analysis_imp = new(
            "analysis_imp",
            this
        );

        // Initialize reference memory
        foreach (expected_mem[i])
            expected_mem[i] = '0;

    endfunction


    //========================================================
    // Receive transaction from monitor
    //========================================================

    function void write(ram_seq_item tr);

        if (!tr.ready) begin

            `uvm_error(
                "SB_READY",
                "Received transaction without ready asserted"
            )

            error_count++;
            return;

        end


        //----------------------------------------------------
        // WRITE
        //----------------------------------------------------

        if (tr.write) begin

            expected_mem[tr.addr] = tr.wdata;

            write_count++;

            `uvm_info(
                "RAM_SB",
                $sformatf(
                    "WRITE: addr=0x%0h data=0x%0h",
                    tr.addr,
                    tr.wdata
                ),
                UVM_MEDIUM
            );

        end


        //----------------------------------------------------
        // READ
        //----------------------------------------------------

        else begin

            read_count++;

            if (tr.rdata !== expected_mem[tr.addr]) begin

                error_count++;

                `uvm_error(
                    "RAM_SB",
                    $sformatf(
                        "READ MISMATCH: addr=0x%0h "   +
                        "expected=0x%0h actual=0x%0h",
                        tr.addr,
                        expected_mem[tr.addr],
                        tr.rdata
                    )
                );

            end
            else begin

                `uvm_info(
                    "RAM_SB",
                    $sformatf(
                        "READ PASS: addr=0x%0h data=0x%0h",
                        tr.addr,
                        tr.rdata
                    ),
                    UVM_MEDIUM
                );

            end

        end

    endfunction


    //========================================================
    // End-of-test report
    //========================================================

    function void report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info(
            "RAM_SB",
            $sformatf(
                "Scoreboard Summary: writes=%0d reads=%0d errors=%0d",
                write_count,
                read_count,
                error_count
            ),
            UVM_NONE
        );

        if (error_count != 0) begin

            `uvm_error(
                "RAM_SB",
                "RAM scoreboard detected errors"
            );

        end
        else begin

            `uvm_info(
                "RAM_SB",
                "RAM scoreboard completed with no errors",
                UVM_NONE
            );

        end

    endfunction

endclass
