# JaCaMo House Building MAS

A multi-agent system built with JaCaMo that simulates coordinated house construction. Multiple autonomous agents representing a house owner and construction companies work together through two phases: a contracting phase (auction-based hiring) and an execution phase (organised task completion).

This project was developed as part of a Multi-Agent Systems course to explore agent-centric coordination mechanisms including auctions, profile-based selection, and reputation-based trust.

---

## What It Does

**Phase 1 — Contracting:** The owner agent runs a reverse auction for each construction task (lowest bid wins). Company agents bid based on their own strategies. Three versions of this phase were implemented:

- **PW1:** Companies self-discover auctions and bid freely
- **PW2:** Companies present their skills to the owner, who then invites only relevant companies
- **PW3:** Owner additionally filters by reputation score — only trusted companies get invited

**Phase 2 — Execution:** Hired companies join a Moise organisation and receive obligations to complete tasks in the correct order:

```
Site Prep → Floors → Walls → (Roof | Windows | Doors) → (Plumbing | Electrical | Exterior Paint) → Interior Paint
```

---

## Project Structure

```
src/
  agt/
    owner.asl           # Owner agent (Giacomo) — runs auctions and manages org
    companyA.asl        # Bids on Plumbing, fixed price strategy
    companyB.asl        # Bids on Site Preparation, decreasing price strategy
    companyC.asl        # Bids on all tasks, max 2 wins, fixed price per task
    companyD.asl        # Bids on all tasks, random price strategy
    companyE.asl        # Bids on Floors/Walls/Roof, bundle strategy
    inc/
      common.asl        # Shared plans: presentation phase, artifact discovery
      org_code.asl      # Organisation join and role adoption plans
      skills.asl        # Maps org goals to house artifact operations
  env/
    tools/
      AuctionArt.java   # Auction artifact — manages bids and current winner
    simulator/
      House.java        # Simulated house GUI artifact
      *.java            # Individual house parts (Floor, Walls, Roof, etc.)
  org/
    house-os.xml        # Moise organisation spec (structural, functional, normative)
initial.jcm             # JaCaMo project entry point
```

---

## Requirements

- Java 17
- Gradle (wrapper included — no install needed)
- Internet connection on first run (downloads JaCaMo dependencies)

---

## How to Run

Clone the repo and run from the project root:

```bash
./gradlew run
```

On Windows:

```bash
gradlew.bat run
```

The system will:
1. Start all agents and the house GUI window
2. Run the auction phase (5 seconds for presentations + 5 seconds for bids)
3. Print auction winners
4. Automatically trigger the execution phase
5. Build the house step by step and print progress
6. Print `*** Finished ***` when done

---

## Configuration

**Changing reputation scores (PW3)** — edit `src/agt/owner.asl`:

```prolog
reputation("companyA", 9).   // score out of 10
reputation("companyD1", 2).  // low score = excluded
min_reputation(5).           // threshold to get invited
```

**Changing budgets per task** — edit `my_preference` beliefs in `owner.asl`:

```prolog
my_preference("Plumbing", 500).   // max price owner will pay
```

---

## Agents Overview

| Agent | Instances | Tasks | Strategy |
|---|---|---|---|
| giacomo (owner) | 1 | manages everything | runs auctions, creates org |
| companyA | 1 | Plumbing | fixed price 300 |
| companyB | 1 | Site Preparation | decreasing by 150 each round |
| companyC | 5 | all tasks, max 2 wins | fixed price per task |
| companyD | 13 | all tasks | random bid |
| companyE | 1 | Floors, Walls, Roof | bundle — bids all three together |

---

## Organisation Workflow

Defined in `src/org/house-os.xml` using the Moise framework:

```
house_built
  └── sequence:
        site_prepared
        floors_laid
        walls_built
        parallel:
          roof_built
          windows_fitted
          doors_fitted
        parallel:
          plumbing_installed
          electrical_system_installed
          exterior_painted
        interior_painted
```

Each hired company is assigned a role and automatically obligated to complete their tasks at the right time.

---

## Course Context

This project covers three coordination mechanisms studied in the lab:

| Version | Selection Criteria | Key Trade-off |
|---|---|---|
| PW1 | None — open auction | Most open, least quality control |
| PW2 | Skill profile match | Balanced control and openness |
| PW3 | Skill + reputation score | Best quality filter, least open to new entrants |
