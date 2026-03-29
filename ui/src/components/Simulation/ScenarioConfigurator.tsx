import React, { useState } from 'react';
import { CharacterBuilder } from './CharacterBuilder';

export const ScenarioConfigurator = ({ onRun }) => {
  const [characterPool, setCharacterPool] = useState([]);
  const [teams, setTeams] = useState([
    { name: 'Team A', members: [] },
    { name: 'Team B', members: [] }
  ]);
  const [simConfig, setSimConfig] = useState({
    name: 'Custom Trial',
    level: 1,
    num_simulations: 100
  });

  const addToPool = (char) => {
    setCharacterPool([...characterPool, { ...char, id: Date.now() }]);
  };

  const addToTeam = (char, teamIndex) => {
    const newTeams = [...teams];
    newTeams[teamIndex].members.push(char);
    setTeams(newTeams);
  };

  const handleRun = async () => {
    const payload = {
      ...simConfig,
      teams: teams
    };
    
    try {
      const response = await fetch('/api/run', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      const results = await response.json();
      onRun(results);
    } catch (err) {
      alert('Failed to run custom simulation');
    }
  };

  const handleSave = async () => {
    const id = simConfig.name.toLowerCase().replace(/\s+/g, '-');
    const payload = { ...simConfig, id, teams };
    
    try {
      await fetch('/api/simulations/save', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      alert('Simulation saved to Library!');
    } catch (err) {
      alert('Failed to save simulation');
    }
  };

  return (
    <div style={{ marginTop: '2rem', padding: '2rem', background: '#f9f9f9', borderRadius: '8px' }}>
      <h2>Custom Lab Runner</h2>
      
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem' }}>
        <CharacterBuilder onSave={addToPool} />
        
        <div style={{ padding: '1.5rem', border: '1px solid #ddd', borderRadius: '8px', background: '#fff' }}>
          <h3>Character Pool</h3>
          <div style={{ maxHeight: '200px', overflowY: 'auto' }}>
            {characterPool.length === 0 && <p style={{ color: '#999' }}>Pool is empty. Create a character.</p>}
            {characterPool.map(c => (
              <div key={c.id} style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.5rem', padding: '0.5rem', borderBottom: '1px solid #eee' }}>
                <span>{c.name} (Lvl {c.level} {c.type})</span>
                <div>
                  <button onClick={() => addToTeam(c, 0)} style={{ fontSize: '0.7rem' }}>+ Team A</button>
                  <button onClick={() => addToTeam(c, 1)} style={{ fontSize: '0.7rem', marginLeft: '0.2rem' }}>+ Team B</button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem', marginTop: '2rem' }}>
        {teams.map((team, idx) => (
          <div key={idx} style={{ padding: '1rem', border: '1px solid #ddd', borderRadius: '8px', background: '#fff' }}>
            <h3>{team.name}</h3>
            <ul>
              {team.members.map((m, mIdx) => (
                <li key={mIdx}>{m.name} ({m.type})</li>
              ))}
            </ul>
          </div>
        ))}
      </div>

      <div style={{ marginTop: '2rem', display: 'flex', gap: '1rem', alignItems: 'center' }}>
        <input 
          type="text" 
          placeholder="Simulation Name" 
          value={simConfig.name} 
          onChange={(e) => setSimConfig({ ...simConfig, name: e.target.value })} 
        />
        <button onClick={handleRun} style={{ padding: '8px 20px', background: '#2e7d32', color: '#fff', border: 'none', borderRadius: '4px' }}>
          Run Simulation
        </button>
        <button onClick={handleSave} style={{ padding: '8px 20px', background: '#1976d2', color: '#fff', border: 'none', borderRadius: '4px' }}>
          Save to Library
        </button>
      </div>
    </div>
  );
};
