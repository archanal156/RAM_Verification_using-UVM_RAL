//============================================================
// File        : ram_base_test.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : Base test for RAM verification
//============================================================

class ram_base_test extends uvm_test;

    //========================================================
    // Environment
    //========================================================

    ram_env env;


    //========================================================
    // Factory registration
    //========================================================

    `uvm_component_utils(ram_base_test)


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ram_base_test",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction


    //========================================================
    // Build phase
    //========================================================

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        // Create environment
        env = ram_env::type_id::create(
            "env",
            this
        );

    endfunction


    //========================================================
    // End of elaboration
    //========================================================

    function void end_of_elaboration_phase(
        uvm_phase phase
    );

        super.end_of_elaboration_phase(phase);

        // Print UVM hierarchy
        uvm_top.print_topology();

    endfunction


    //========================================================
    // Run phase
    //========================================================

    task run_phase(uvm_phase phase);

        // Base test does not start a sequence.
        // Child tests will override run_phase.

    endtask


    //========================================================
    // Report phase
    //========================================================

    function void report_phase(uvm_phase phase);

        uvm_report_server server;

        int errors;
        int fatals;

        super.report_phase(phase);

        server = uvm_report_server::get_server();

        errors = server.get_severity_count(UVM_ERROR);
        fatals = server.get_severity_count(UVM_FATAL);

        if ((errors == 0) && (fatals == 0)) begin

            `uvm_info(
                "RAM_TEST",
                "==========================================",
                UVM_NONE
            );

            `uvm_info(
                "RAM_TEST",
                "       RAM TEST PASSED",
                UVM_NONE
            );

            `uvm_info(
                "RAM_TEST",
                "==========================================",
                UVM_NONE
            );

        end
        else begin

            `uvm_error(
                "RAM_TEST",
                $sformatf(
                    "RAM TEST FAILED: errors=%0d fatals=%0d",
                    errors,
                    fatals
                )
            );

        end

    endfunction

endclass
