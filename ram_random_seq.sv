//============================================================
// File        : ram_random_seq.sv
// Project     : UVM-RAL Based RAM Verification Environment
// Description : Constrained-random RAM sequence
//============================================================

class ram_random_seq extends ram_base_seq;

    //========================================================
    // Number of transactions
    //========================================================

    rand int unsigned num_transactions;


    //========================================================
    // Constraints
    //========================================================

    constraint num_transactions_c {
        num_transactions inside {[20:100]};
    }


    //========================================================
    // Factory registration
    //========================================================

    `uvm_object_utils(ram_random_seq)


    //========================================================
    // Constructor
    //========================================================

    function new(
        string name = "ram_random_seq"
    );

        super.new(name);

    endfunction


    //========================================================
    // Body
    //========================================================

    virtual task body();

        ram_seq_item tr;

        if (!randomize()) begin

            `uvm_fatal(
                "RAND_SEQ",
                "Failed to randomize number of transactions"
            )

        end


        `uvm_info(
            "RAM_SEQ",
            $sformatf(
                "Starting random sequence with %0d transactions",
                num_transactions
            ),
            UVM_MEDIUM
        );


        //----------------------------------------------------
        // Generate transactions
        //----------------------------------------------------

        repeat (num_transactions) begin

            tr = ram_seq_item::type_id::create(
                "tr"
            );

            start_item(tr);

            if (!tr.randomize()) begin

                `uvm_fatal(
                    "RAND_SEQ",
                    "Failed to randomize RAM transaction"
                )

            end

            finish_item(tr);

        end


        `uvm_info(
            "RAM_SEQ",
            "Random sequence completed",
            UVM_MEDIUM
        );

    endtask

endclass
