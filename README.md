# RAM UVM/RAL Verification Environment

A self-checking, constrained-random **UVM testbench** for a synchronous RAM DUT, built with the **Register Abstraction Layer (RAL)** for register-level access and front-door/back-door coherency checking.

![SystemVerilog](https://img.shields.io/badge/-SystemVerilog-black?style=flat-square)
![UVM](https://img.shields.io/badge/-UVM_1.2-blue?style=flat-square)
![RAL](https://img.shields.io/badge/-RAL-orange?style=flat-square)
![VCS](https://img.shields.io/badge/-Synopsys_VCS-red?style=flat-square)
![CI](https://img.shields.io/badge/-GitHub_Actions-2088FF?style=flat-square&logo=githubactions&logoColor=white)
![License](https://img.shields.io/badge/-MIT-green?style=flat-square)

---

## 📖 Overview

This project verifies a simple synchronous **RAM DUT** using a layered UVM environment integrated with a **RAL register model**. It supports both data-path verification (via a dedicated RAM sequencer/driver/monitor) and register-map verification (via RAL front-door/back-door access), with a scoreboard cross-checking DUT behavior against a reference model.

---

## 🗂️ Repository Structure

```
ram_uvm_ral_verification/
├── design.sv                  # RAM RTL design under test (DUT)
├── testbench.sv                # Top-level testbench module
├── ram_if.sv                   # Clocking-block based DUT interface
│
├── ram_seq_item.sv             # Transaction / sequence item
├── ram_sequencer.sv            # UVM sequencer
├── ram_driver.sv                # UVM driver
├── ram_monitor.sv               # UVM monitor
├── ram_agent.sv                  # Active/passive agent wrapper
│
├── ram_reg_model.sv            # RAL register model (uvm_reg_block)
├── ram_reg_predictor.sv        # RAL predictor (uvm_reg_predictor)
├── ram_reg_adapter.sv          # RAL bus adapter (reg2bus / bus2reg)
│
├── ram_scoreboard.sv           # Reference model + result checking
├── ram_coverage.sv             # Functional coverage groups
├── ram_assertions.sv           # SVA protocol/RAL assertions
├── ram_env.sv                   # Environment: agent + RAL + scoreboard + coverage
│
├── ram_base_seq.sv              # Base sequence class
├── ram_write_read_seq.sv       # Directed write/read sequence
├── ram_random_seq.sv            # Constrained-random data sequence
├── ral_access_seq.sv            # RAL front-door/back-door access sequence
│
├── ram_base_test.sv             # Base test (build/config)
├── ram_smoke_test.sv           # Sanity/smoke test
├── ram_random_test.sv          # Regression: randomized traffic
├── ram_ral_test.sv              # RAL-focused register test
│
├── sim/                          # Simulation scripts & run area (VCS)
│   ├── Makefile
│   └── run.sh
├── .github/workflows/ci.yml     # CI regression on push/PR
└── README.md
```

---

## 🏗️ Architecture

```
                ┌──────────────────────────── ram_env ────────────────────────────┐
                │                                                                    │
  ram_sequencer │──► ram_driver ──► ram_if (clocking block) ──► design.sv (DUT)     │
                │                                                     │              │
                │        ram_monitor ◄───────────────────────────────┘              │
                │             │                                                      │
                │             ├──► ram_scoreboard ◄── reference model                │
                │             ├──► ram_coverage                                      │
                │             └──► ram_reg_predictor ──► ram_reg_model (RAL)         │
                │                        ▲                                           │
                │                  ram_reg_adapter                                   │
                └────────────────────────────────────────────────────────────────────┘
```

- **Data path:** `ram_sequencer → ram_driver → ram_if → DUT`, observed by `ram_monitor`
- **Register path (RAL):** `ral_access_seq → ram_reg_model → ram_reg_adapter → ram_driver/DUT`, mirrored back via `ram_reg_predictor`
- **Checking:** `ram_scoreboard` compares DUT output against a golden reference model; `ram_assertions` catch protocol-level violations; `ram_coverage` tracks functional coverage (address range, data patterns, R/W sequences, RAL access types)

---

## ✅ Verification Plan (summary)

| Feature | Method |
|---|---|
| Basic write/read | `ram_write_read_seq` (directed) |
| Randomized address/data traffic | `ram_random_seq` (constrained-random) |
| Register read/write via RAL front-door | `ral_access_seq` |
| Register read/write via RAL back-door | `ral_access_seq` (back-door mode) |
| Mirror/predictor consistency | `ram_reg_predictor` + scoreboard checks |
| Protocol correctness | `ram_assertions` (SVA) |
| Functional coverage closure | `ram_coverage` |

---

## ⚙️ Prerequisites

- **Synopsys VCS** (with UVM 1.2 library, typically bundled or via `-ntb_opts uvm-1.2`)
- A valid `synopsys` / `vcs` license and environment setup (`VCS_HOME`, `PATH`)
- `make` (if using the provided Makefile)

---

## ▶️ How to Run

### 1. Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/ram_uvm_ral_verification.git
cd ram_uvm_ral_verification
```

### 2. Compile and run with VCS
```bash
cd sim
vcs -full64 -sverilog -ntb_opts uvm-1.2 \
    -timescale=1ns/1ps \
    ../design.sv ../ram_if.sv ../testbench.sv \
    ../ram_seq_item.sv ../ram_sequencer.sv ../ram_driver.sv ../ram_monitor.sv ../ram_agent.sv \
    ../ram_reg_model.sv ../ram_reg_predictor.sv ../ram_reg_adapter.sv \
    ../ram_scoreboard.sv ../ram_coverage.sv ../ram_assertions.sv ../ram_env.sv \
    ../ram_base_seq.sv ../ram_write_read_seq.sv ../ram_random_seq.sv ../ral_access_seq.sv \
    ../ram_base_test.sv ../ram_smoke_test.sv ../ram_random_test.sv ../ram_ral_test.sv \
    -o simv

./simv +UVM_TESTNAME=ram_smoke_test +UVM_VERBOSITY=UVM_MEDIUM
```

### 3. Or use the Makefile
```bash
cd sim
make TEST=ram_random_test SEED=1
make TEST=ram_ral_test
```

### 4. View coverage (VCS/Verdi)
```bash
urg -dir simv.vdb -report cov_report
```

---

## 🧪 Available Tests

| Test | Description |
|---|---|
| `ram_smoke_test` | Basic sanity — single write/read |
| `ram_random_test` | Constrained-random regression traffic |
| `ram_ral_test` | RAL front-door/back-door register access |

Run any test with:
```bash
./simv +UVM_TESTNAME=<test_name> +UVM_VERBOSITY=UVM_LOW
```

---

## 🔁 Continuous Integration

`.github/workflows/ci.yml` runs lint/compile checks and (where a VCS license runner is available) executes the smoke test regression on every push and pull request to `main`.

> Note: VCS requires a licensed simulator, so full simulation CI typically needs a self-hosted runner with VCS installed. The provided workflow is structured to support that; adjust the runner/license setup as needed.

---

## 📈 Roadmap

- [ ] Add UVM RAL back-door access via DPI/HDL path
- [ ] Add error-injection sequence (illegal address, protocol violations)
- [ ] Expand functional coverage cross bins
- [ ] Add regression summary dashboard (via `urg`/custom parser)

---

## 📄 License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

---

## 🙌 Contributing

Issues and pull requests are welcome. Please open an issue first to discuss significant changes.
