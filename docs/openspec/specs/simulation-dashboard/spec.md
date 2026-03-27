# SPEC-0001: Simulation Dashboard & Experiment Runner

## Overview

This specification defines the requirements for a web-based dashboard designed to visualize D&D 2024 combat simulation results and provide an interactive interface for configuring and running batch experiments. This is the first step towards fulfilling the "Future Vision" of an interactive experiment runner.

## Requirements

### Requirement: Documentation Rendering

The dashboard SHALL render all project ADRs and OpenSpecs using the Docusaurus-based portal.

#### Scenario: View ADR
- **WHEN** a user navigates to `/docs/adrs`
- **THEN** they SHALL see a list of all ADR files correctly formatted with status badges.

### Requirement: Statistical Visualization

The dashboard SHALL provide interactive charts for Damage Per Round (DPR) and Survival Rate distributions.

#### Scenario: Visualize Experiment Results
- **WHEN** a simulation run completes and generates a `results.json`
- **THEN** the dashboard SHALL display a line chart of DPR over 10 rounds.

### Requirement: Interactive Lab Runner

The dashboard SHALL allow users to configure simple simulation parameters (e.g., Number of Simulations, level, attacker/defender templates) and trigger a run.

#### Scenario: Run Custom Simulation
- **WHEN** a user selects "Fighter (Level 5)" vs "Goblin Pack" and clicks "Run"
- **THEN** the backend SHALL execute the simulation and update the UI with real-time results.

### Requirement: Math Transparency

All visualizations SHALL allow the user to drill down into the underlying dice rolls and modifiers for any specific data point.

#### Scenario: Inspect Crit Impact
- **WHEN** a user clicks on a "Crit" peak in the DPR chart
- **THEN** the dashboard SHALL show the specific roll metadata (e.g., `19 + 5 = 24`).
