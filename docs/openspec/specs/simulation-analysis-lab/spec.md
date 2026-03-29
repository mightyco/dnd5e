# SPEC-0005: Simulation Analysis Laboratory

## Overview

The Simulation Analysis Laboratory is an advanced toolset for interpreting combat simulation data. It transitions the dashboard from simple logging to a scientific analysis platform capable of detecting balance regressions, statistical significance, and combat swinginess.

## Requirements

### Requirement: Statistical Significance Analysis

The system SHALL calculate the statistical significance of win rates using confidence intervals (e.g., 95% CI) to ensure results are not due to chance.

#### Scenario: High Confidence Result

- **WHEN** Team A wins 85 out of 100 simulations.
- **THEN** The UI SHALL display a high-confidence indicator (p < 0.05).

#### Scenario: Low Confidence Result

- **WHEN** Team A wins 52 out of 100 simulations.
- **THEN** The UI SHALL display a "Statistically Insignificant" warning.

### Requirement: Delta/Comparison Analysis

The system SHALL provide a comparison view between two simulation runs that highlights the absolute and relative differences in DPR (Damage Per Round) and survival rates.

#### Scenario: Subclass Comparison

- **WHEN** Comparing a Champion Fighter run vs a Battlemaster Fighter run.
- **THEN** The UI SHALL display a "Delta" table showing % difference in DPR and win rate.

### Requirement: Combat Categorization

The system SHOULD categorize combat results into qualitative buckets (Stomp, Close, Slog, etc.) based on the number of rounds and final HP of the survivors.

#### Scenario: Slog Detection

- **WHEN** A combat lasts more than 10 rounds.
- **THEN** The system SHALL label it as a "Slog".

### Requirement: Automated Balance Regression Testing

The system SHALL allow users to set "Expectations" for saved simulations that can be run in CI to detect balance regressions.

#### Scenario: DPR Regression

- **WHEN** A change to the engine causes a saved simulation's avg DPR to drop by > 10%.
- **THEN** The CI task SHALL fail and report the regression.
