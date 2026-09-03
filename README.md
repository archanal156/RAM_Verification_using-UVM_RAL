# RAM UVM/RAL Verification Environment

A self-checking, constrained-random **UVM testbench** for a parameterized synchronous single-port RAM, verified both through a direct RAM agent and through a **UVM RAL (Register Abstraction Layer)** model with front-door access.

![SystemVerilog](https://img.shields.io/badge/-SystemVerilog-black?style=flat-square)
![UVM](https://img.shields.io/badge/-UVM_1.2-blue?style=flat-square)
![RAL](https://img.shields.io/badge/-RAL-orange?style=flat-square)
![VCS](https://img.shields.io/badge/-Synopsys_VCS-red?style=flat-square)
![License](https://img.shields.io/badge/-MIT-green?style=flat-square)

---

## 📖 Overview

The DUT is a parameterized, synchronous, single-port RAM (`ram.sv`) with a simple request/response protocol (`req`/`write`/`addr`/`wdata` in, `rdata`/`ready` out, active-low sync reset). It is verified by a UVM environment that drives transactions two ways:

1. **Direct data-path traffic** — `ram_seq_item` transactions driven through the RAM agent's sequencer/driver.
2. **Register-level traffic** — the same RAM, modeled as a single `uvm_mem` (`RAM`) inside a `uvm_reg_block` (`ram_reg_block`), accessed via RAL front-door `read()`/`write()` calls that get translated to bus transactions by `ram_reg_adapter` and driven through the *same* agent/sequencer.

A `ram_reg_predictor` keeps the RAL mirror in sync by observing monitored bus transactions, so both access paths stay consistent.

---

## 🧩 DUT: `ram.sv`

```systemverilog
module ram #(
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  req,
    input  logic                  write,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [DATA_WIDTH-1:0] wdata,
    output logic [DATA_WIDTH-1:0] rdata,
    output logic                  ready
);
```

- **Depth:** `DEPTH = 1 << ADDR_WIDTH` → 256 words (default `ADDR_WIDTH = 8`)
- **Width:** 32-bit data (default `DATA_WIDTH = 32`)
- **Protocol:** single-cycle synchronous — assert `req` (+`write`/`addr`/`wdata`), `ready` pulses high the following clock, `rdata` valid on read
- **Reset:** active-low, synchronous (`rst_n`)

---

## 🗂️ Repository Structure

```
ram_uvm_ral_verification/
├── ram.sv                       # DUT — parameterized synchronous single-port RAM
├── testbench.sv                 # Top-level testbench module
├── ram_if.sv                    # Clocking-block based DUT interface
│
├── ram_seq_item.sv              # Transaction: write, addr, wdata, rdata, ready
├── ram_sequencer.sv             # UVM sequencer
├── ram_driver.sv                # UVM driver
├── ram_monitor.sv               # UVM monitor
├── ram_agent.sv                 # Agent wrapper (active, UVM_ACTIVE)
│
├── ram_reg_model.sv             # RAL model: ram_reg_block, single uvm_mem "RAM"
├── ram_reg_adapter.sv           # RAL <-> ram_seq_item adapter (reg2bus / bus2reg)
├── ram_reg_predictor.sv         # uvm_reg_predictor #(ram_seq_item)
│
├── ram_scoreboard.sv            # Reference-model checking
├── ram_coverage.sv              # Functional coverage
├── ram_assertions.sv            # SVA protocol checks
├── ram_env.sv                   # Top environment: agent + RAL + scoreboard + coverage
│
├── ram_base_seq.sv              # Base sequence — write_mem() / read_mem() helpers
├── ram_write_read_seq.sv        # Directed write/read sequence (addr 0, 1, mid, last)
├── ram_random_seq.sv            # Constrained-random sequence (20–100 transactions)
├── ral_access_seq.sv            # RAL front-door write/read sequence
│
├── ram_base_test.sv             # Base test: builds env, prints topology, reports pass/fail
├── ram_smoke_test.sv            # Runs ram_write_read_seq
├── ram_random_test.sv           # Runs ram_random_seq
├── ram_ral_test.sv              # Runs ral_access_seq via env.ral_model
│
└── README.md
```

---

## 🏗️ Architecture

```
                                    ram_env
   ┌──────────────────────────────────────────────────────────────────┐
   │                                                                    │
   │   ral_access_seq ──► ram_reg_block (RAL "RAM" uvm_mem)             │
   │                              │  front-door read()/write()          │
   │                              ▼                                     │
   │                       ram_reg_adapter (reg2bus / bus2reg)           │
   │                              │                                     │
   │   ram_write_read_seq ─┐      ▼                                     │
   │   ram_random_seq ─────┼──► ram_sequencer ──► ram_driver ──► ram_if │──► ram.sv (DUT)
   │                       │                                             │
   │                       └────────────────────────────► ram_monitor ◄──┘
   │                                                            │
   │                              ┌─────────────────────────────┼──────────────┐
   │                              ▼                              ▼              ▼
   │                     ram_scoreboard                  ram_coverage   ram_reg_predictor
   │                    (checks vs. golden model)        (functional     (updates RAL
   │                                                       coverage)      mirror value)
   └──────────────────────────────────────────────────────────────────┘
```

**Connections (from `ram_env::connect_phase`):**
- `agent.monitor.analysis_port` → `scoreboard.analysis_imp`
- `agent.monitor.analysis_port` → `coverage.analysis_export`
- `agent.monitor.analysis_port` → `ral_predictor.bus_in`
- `ral_predictor.map = ral_model.default_map`, `ral_predictor.adapter = ral_adapter`
- `ral_model.default_map.set_sequencer(agent.sequencer, ral_adapter)` — RAL and direct sequences **share the same sequencer**

---

## 🔑 RAL Model Details

`ram_reg_block` models the RAM as a **single `uvm_mem` named `RAM`** (not individual registers) — one entry per RAM word:

```systemverilog
RAM = new("RAM", DEPTH, DATA_WIDTH, "RW", UVM_NO_COVERAGE);
RAM.configure(this);
default_map = create_map("default_map", 'h0, 4, UVM_LITTLE_ENDIAN, 1);
default_map.add_mem(RAM, 'h0, "RW");
default_map.set_auto_predict(0);   // predictor updates the mirror explicitly
lock_model();
```

**Address translation (`ram_reg_adapter`):** RAL uses **byte addresses**; the RAM protocol uses **word addresses**. The adapter converts between them using `BUS_BYTES = DATA_WIDTH / 8` (= 4):

```
RAL byte address 0x00 → RAM word address 0
RAL byte address 0x04 → RAM word address 1
RAL byte address 0x08 → RAM word address 2
```

`reg2bus()` builds a `ram_seq_item` from the RAL access; `bus2reg()` reports `UVM_IS_OK` / `UVM_NOT_OK` based on the DUT's `ready` signal.

---

## 🧪 Sequences

| Sequence | Extends | Behavior |
|---|---|---|
| `ram_base_seq` | `uvm_sequence #(ram_seq_item)` | Provides `write_mem(addr, data)` / `read_mem(addr, data)` helper tasks |
| `ram_write_read_seq` | `ram_base_seq` | Directed: write+read at address `0`, `1`, `DEPTH/2`, `DEPTH-1` with fixed patterns (`0xAAAAAAAA`, `0x55555555`, `0xDEADBEEF`, `0x12345678`) |
| `ram_random_seq` | `ram_base_seq` | Randomizes `num_transactions` (20–100), then randomizes each `ram_seq_item` (`write`, `addr`, `wdata`) |
| `ral_access_seq` | `uvm_sequence #(ram_seq_item)` | Front-door RAL `RAM.write()` / `RAM.read()` at address `0`, `1`, `DEPTH/2`, `DEPTH-1`, checking `uvm_status_e` after each access |

`ram_seq_item` constraint: when `write == 0`, `wdata` is forced to `'0` (read transactions don't drive write data).

---

## 🧪 Tests

| Test | Extends | Sequence started | On `env.agent.sequencer` |
|---|---|---|---|
| `ram_base_test` | `uvm_test` | none — builds `env`, prints topology at end of elaboration, reports PASS/FAIL from `uvm_report_server` error/fatal counts | — |
| `ram_smoke_test` | `ram_base_test` | `ram_write_read_seq` | ✅ |
| `ram_random_test` | `ram_base_test` | `ram_random_seq` | ✅ |
| `ram_ral_test` | `ram_base_test` | `ral_access_seq` (with `seq.ral_model = env.ral_model`) | ✅ |

Every test raises/drops an objection around `seq.start(...)`, and `ram_base_test::report_phase` prints a PASS/FAIL banner based on error/fatal counts.

---

## ⚙️ Prerequisites

- **Synopsys VCS** with UVM 1.2 (`-ntb_opts uvm-1.2`)
- Valid VCS license/environment (`VCS_HOME`, `PATH`)

---

## ▶️ How to Run

```bash
git clone https://github.com/YOUR_USERNAME/ram_uvm_ral_verification.git
cd ram_uvm_ral_verification

vcs -full64 -sverilog -ntb_opts uvm-1.2 -timescale=1ns/1ps \
    ram.sv ram_if.sv testbench.sv \
    ram_seq_item.sv ram_sequencer.sv ram_driver.sv ram_monitor.sv ram_agent.sv \
    ram_reg_model.sv ram_reg_adapter.sv ram_reg_predictor.sv \
    ram_scoreboard.sv ram_coverage.sv ram_assertions.sv ram_env.sv \
    ram_base_seq.sv ram_write_read_seq.sv ram_random_seq.sv ral_access_seq.sv \
    ram_base_test.sv ram_smoke_test.sv ram_random_test.sv ram_ral_test.sv \
    -o simv

./simv +UVM_TESTNAME=ram_smoke_test +UVM_VERBOSITY=UVM_MEDIUM
./simv +UVM_TESTNAME=ram_random_test +UVM_VERBOSITY=UVM_MEDIUM
./simv +UVM_TESTNAME=ram_ral_test    +UVM_VERBOSITY=UVM_MEDIUM
```

> ⚠️ Compile RAL/adapter/predictor files **after** `ram_seq_item.sv` and **before** `ram_env.sv`, since `ram_env` instantiates all three RAL components.

---

## 📄 License

MIT — see `LICENSE`.
