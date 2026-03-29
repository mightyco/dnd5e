import React from 'react';
import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { DPRChart } from '../DPRChart';

describe('DPRChart', () => {
  it('renders "No data available" when data is empty', () => {
    render(<DPRChart datasets={[]} />);
    expect(screen.getByText(/No data available/i)).toBeInTheDocument();
  });

  it('renders "No data available" when data is null', () => {
    render(<DPRChart datasets={[null]} />);
    expect(screen.getByText(/No data available/i)).toBeInTheDocument();
  });

  it('renders the chart title when data is provided', () => {
    const mockData = [
      {
        teams: ['Hero', 'Goblin'],
        rounds: [
          {
            number: 1,
            events: [
              { attacker: 'Hero', defender: 'Goblin', damage: 10, type: 'attack', success: true, metadata: {} }
            ]
          }
        ]
      }
    ];
    render(<DPRChart datasets={[mockData]} />);
    expect(screen.getByText(/Average Damage Per Round/i)).toBeInTheDocument();
  });

  it('does not crash when encountering non-attack events like turn_start', () => {
    const mockDataWithExtraEvents = [
      {
        teams: ['Hero', 'Goblin'],
        rounds: [
          {
            number: 1,
            events: [
              { type: 'turn_start', combatant: 'Hero' },
              { attacker: 'Hero', defender: 'Goblin', damage: 10, type: 'attack', success: true, metadata: {} }
            ]
          }
        ]
      }
    ];
    render(<DPRChart datasets={[mockDataWithExtraEvents]} />);
    expect(screen.getByText(/Average Damage Per Round/i)).toBeInTheDocument();
  });
});
