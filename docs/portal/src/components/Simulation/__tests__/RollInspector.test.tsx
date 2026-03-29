import React from 'react';
import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { RollInspector } from '../RollInspector';

describe('RollInspector', () => {
  const mockData = [
    {
      winner: 'Hero',
      rounds: [
        {
          number: 1,
          events: [
            { 
              type: 'attack', 
              attacker: 'Hero', 
              defender: 'Goblin', 
              attack_name: 'Sword', 
              success: true, 
              damage: 10,
              is_crit: true,
              metadata: { 
                attack_roll: 20, 
                raw_rolls: [20], 
                modifier: 5, 
                target_ac: 10,
                damage_rolls: [5, 5],
                damage_modifier: 0,
                current_hp: 5,
                max_hp: 15
              } 
            }
          ]
        }
      ]
    }
  ];

  it('renders "Math Transparency" title', () => {
    render(<RollInspector data={mockData} />);
    expect(screen.getByText(/Math Transparency: Roll Inspector/i)).toBeInTheDocument();
  });

  it('renders combatant names and attack names', () => {
    render(<RollInspector data={mockData} />);
    expect(screen.getByText(/Hero vs Goblin/i)).toBeInTheDocument();
    expect(screen.getByText(/\(Sword\)/i)).toBeInTheDocument();
  });

  it('renders critical hit indicator', () => {
    render(<RollInspector data={mockData} />);
    expect(screen.getByText(/CRIT!/i)).toBeInTheDocument();
  });

  it('renders HP information correctly', () => {
    render(<RollInspector data={mockData} />);
    expect(screen.getByText(/Target HP: 5\/15/i)).toBeInTheDocument();
  });

  it('does NOT render literal curly braces from metadata leaks', () => {
    render(<RollInspector data={mockData} />);
    const container = screen.getByText(/Math Transparency/i).parentElement;
    // Check that we don't see a literal '}' which was a previous bug
    expect(container.textContent).not.toMatch(/\}\}/);
  });

  it('renders raw rolls in brackets correctly', () => {
    render(<RollInspector data={mockData} />);
    expect(screen.getByText(/Raw: \[20\] \+ 5/i)).toBeInTheDocument();
  });

  it('handles missing raw rolls gracefully', () => {
    const dataWithMissingRaw = [{ ...mockData[0], rounds: [{ ...mockData[0].rounds[0], events: [{ ...mockData[0].rounds[0].events[0], metadata: { ...mockData[0].rounds[0].events[0].metadata, raw_rolls: null } }] }] }];
    render(<RollInspector data={dataWithMissingRaw} />);
    expect(screen.getByText(/Raw: \[\?\] \+ 5/i)).toBeInTheDocument();
  });
});
