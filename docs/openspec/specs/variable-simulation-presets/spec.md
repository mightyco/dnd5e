# SPEC-0006: Variable Simulation Presets

## Overview

Simulation presets are currently static. To perform scientific analysis (e.g., "How many Goblins can a Level 5 Fighter handle?"), users must manually configure multiple custom simulations. This capability introduces "Variable Presets" that allow defining a range for a variable (like enemy count or level) and running a "Parameter Sweep" to visualize the trend.

## Requirements

### Requirement: Parameter Sweep Definition

The JSON preset schema SHALL support variable ranges using a `variables` key.

#### Scenario: Enemy Count Scaling
- **WHEN** A preset defines `variables: { "goblin_count": [1, 2, 4, 8, 12] }`.
- **THEN** The API SHALL generate and run a batch of 5 simulations, one for each value in the range.

### Requirement: Variable Substitution

The system SHALL support placeholders in the `teams` configuration that reference defined variables.

#### Scenario: Placeholder Replacement
- **WHEN** a team member uses `{ "count": "{{goblin_count}}" }`.
- **THEN** The system SHALL duplicate that member template the specified number of times.

### Requirement: Sweep Visualization

The UI SHALL provide a "Sweep Chart" (Line or Area) showing the change in DPR or Win Rate across the variable range.

#### Scenario: Trend Analysis
- **WHEN** multiple simulations from a sweep are selected.
- **THEN** The UI SHALL display a chart where the X-axis is the variable (e.g., Goblin Count) and the Y-axis is the Win Rate.

### Requirement: Script/UI Parity

The system SHALL ensure that any experiment run via a Ruby script can be represented as a Variable Preset in the UI.

#### Scenario: Subclass Comparison Sweep
- **WHEN** A variable `subclass` is defined as `["champion", "battlemaster"]`.
- **THEN** The UI SHALL display a side-by-side comparison of the trends for both subclasses.
