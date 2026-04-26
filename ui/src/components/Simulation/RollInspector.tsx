import React, { useState } from 'react';
import { OutcomeLabel } from './LabAnalysis';

export const RollInspector = ({ data }) => {
  if (!data || data.length === 0) return null;

  const [selectedCombat, setSelectedCombat] = useState(0);

  const combat = data[selectedCombat];

  return (
    <div style={{ marginTop: '2rem', padding: '1rem', border: '1px solid #ddd', borderRadius: '8px' }}>
      <h3>Math Transparency: Roll Inspector</h3>
      <div style={{ marginBottom: '1rem', display: 'flex', alignItems: 'center' }}>
        <label style={{ marginRight: '0.5rem' }}>Select Sample Combat: </label>
        <select onChange={(e) => setSelectedCombat(parseInt(e.target.value))} value={selectedCombat}>
          {data.map((_, index) => (
            <option key={index} value={index}>Combat #{index + 1} (Winner: {data[index].winner})</option>
          ))}
        </select>
        <OutcomeLabel combat={combat} />
      </div>

      <div style={{ maxHeight: '400px', overflowY: 'auto', background: '#f9f9f9', padding: '1rem', fontFamily: 'monospace' }}>
        {combat.rounds.map(round => (
          <div key={round.number} style={{ marginBottom: '1rem' }}>
            <div style={{ fontWeight: 'bold', borderBottom: '1px solid #ccc' }}>Round {round.number}</div>
            {round.events.map((event, idx) => {
              if (event.type === 'turn_start') {
                return (
                  <div key={idx} style={{ padding: '0.2rem 0', color: '#666', fontStyle: 'italic', fontSize: '0.85rem' }}>
                    --- {event.combatant}'s Turn ---
                  </div>
                );
              }

              if (event.type === 'resource_used') {
                return (
                  <div key={idx} style={{ padding: '0.2rem 0', color: '#1976d2', fontWeight: 'bold', fontSize: '0.85rem' }}>
                    [RESOURCE] {event.combatant} used {event.resource}
                  </div>
                );
              }

              const meta = event.metadata || {};
              return (
                <div key={idx} style={{ paddingLeft: '1rem', margin: '0.5rem 0', fontSize: '0.9rem' }}>
                  <span style={{ color: event.success ? '#2e7d32' : '#d32f2f' }}>
                    [{event.type?.toUpperCase()}]
                  </span> {event.attacker} vs {event.defender} ({event.attack_name}) 
                  {event.is_crit && <span style={{ fontWeight: 'bold', color: '#ff9800' }}> CRIT!</span>}
                  <br/>
                  <small style={{ color: '#666' }}>
                    Roll: {meta.attack_roll || '?'} (Raw: [{meta.raw_rolls?.join(', ') || '?'}] + {meta.modifier || 0}) vs AC {meta.target_ac || '?'}
                    {event.damage > 0 && ` | Damage: ${event.damage} (${meta.damage_rolls?.join('+') || '?'} + ${meta.damage_modifier || 0})`}
                    {meta.current_hp !== undefined && ` | Target HP: ${meta.current_hp}/${meta.max_hp}`}
                  </small>
                </div>
              );
            })}
          </div>
        ))}
      </div>
    </div>
  );
};
