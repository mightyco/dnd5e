import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { CombatPlayback } from '../CombatPlayback';
import React from 'react';

describe('CombatPlayback', () => {
  const mockCombatData = [{
    teams: ['Hero', 'Goblin'],
    winner: 'Hero',
    initial_positions: {
      'Hero': { x: 0, y: 0, hp: 10, max_hp: 10 },
      'Goblin': { x: 10, y: 10, hp: 5, max_hp: 5 }
    },
    rounds: [
      {
        number: 1,
        events: [
          { type: 'turn_start', combatant: 'Hero' },
          { type: 'move', combatant: 'Hero', to: { x: 5, y: 5 } },
          { 
            type: 'attack', 
            attacker: 'Hero', 
            defender: 'Goblin', 
            attack_name: 'Sword', 
            success: true, 
            damage: 5,
            is_dead: true,
            metadata: { current_hp: 0, max_hp: 5 }
          }
        ]
      }
    ]
  }];

  it('renders without crashing', () => {
    render(<CombatPlayback combatData={mockCombatData} />);
    expect(screen.getByTestId('combat-playback')).toBeInTheDocument();
  });

  it('displays the event log', () => {
    render(<CombatPlayback combatData={mockCombatData} />);
    expect(screen.getByText(/Event Log/i)).toBeInTheDocument();
  });

  it('handles empty combatData gracefully', () => {
    render(<CombatPlayback combatData={[]} />);
    expect(screen.getByTestId('combat-playback')).toBeInTheDocument();
  });

  it('handles missing initial_positions gracefully', () => {
    const brokenData = [{ ...mockCombatData[0], initial_positions: null }];
    render(<CombatPlayback combatData={brokenData} />);
    expect(screen.getByTestId('combat-playback')).toBeInTheDocument();
  });
});
