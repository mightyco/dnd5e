# UI Interaction Audit Report - 2026-05-10

## Bug 1: Simulation Result Charts Overlap
- **Description**: Charts in the simulation results section (SurvivalChart, DPRChart, LuckAnalyzer) overlap vertically and horizontally, making data difficult to read.
- **Root Cause**: Fixed heights in parent `div` containers combined with `ResponsiveContainer` not respecting natural document flow in certain flex/grid configurations.
- **Evidence**: Audit detected 10 overlaps. `recharts-responsive-container` at `t:847` overlaps a parent `div` at `t:733`.

## Bug 2: Quick Stats Widget Misalignment
- **Description**: The "Quick Stats" box in the results view is improperly positioned within the grid, often overlapping with the primary chart.
- **Root Cause**: `display: grid` in `SimulationDashboard/index.tsx` lacks sufficient row gap and specific height constraints for the stats panel.

## Bug 3: Modal Background Transparency Issue
- **Description**: The "Simulation Intent" modal background is overly transparent or lacks sufficient contrast, making the underlying UI visible and potentially interactable.
- **Root Cause**: `background: rgba(0,0,0,0.7)` was used but the z-index or stacking context of the charts may interfere.

## Bug 4: Character Builder Input Overflow
- **Description**: In the Advanced Character Builder, long subclass or feat lists cause the container to expand beyond the viewport or overlap with the team selection panels.
- **Root Cause**: Lack of `overflow: hidden` or `max-height` on specific "Zone" containers in `FluidDetails.tsx`.

## Bug 5: Navigation Tab State Desync
- **Description**: Rapidly switching between "Library Presets" and "Custom Lab" while a simulation is running causes the result section to flash or render stale data.
- **Root Cause**: `activeTab` state and `handleResults` effect are not properly cleaned up or debounced.
