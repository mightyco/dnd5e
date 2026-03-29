import React, { useState } from 'react';

export const LabRunnerForm = ({ onResults }) => {
  const [level, setLevel] = useState(1);
  const [sims, setSims] = useState(100);
  const [running, setRunning] = useState(false);

  const runSimulation = async () => {
    setRunning(true);
    try {
      const response = await fetch('/api/run', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          num_simulations: sims,
          level: level,
          teams: [
            { name: 'Heroes', members: [{ name: 'Hero', type: 'fighter' }] },
            { name: 'Monsters', members: [{ name: 'Goblin 1', type: 'goblin' }, { name: 'Goblin 2', type: 'goblin' }] }
          ]
        })
      });
      
      const results = await response.json();
      if (results.error) {
        alert('Error: ' + results.error);
      } else {
        onResults(results);
      }
    } catch (err) {
      alert('Failed to connect to Simulation API. Ensure scripts/sim_server.rb is running.');
    }
    setRunning(false);
  };

  return (
    <div style={{ padding: '1.5rem', border: '1px solid #ddd', borderRadius: '8px', background: '#fff' }}>
      <h3>Configure Simulation</h3>
      <div style={{ display: 'flex', gap: '1rem', marginBottom: '1rem' }}>
        <div>
          <label>Level: </label>
          <input type="number" value={level} onChange={(e) => setLevel(parseInt(e.target.value))} min="1" max="20" style={{ width: '50px' }} />
        </div>
        <div>
          <label>Simulations: </label>
          <input type="number" value={sims} onChange={(e) => setSims(parseInt(e.target.value))} min="1" max="1000" style={{ width: '70px' }} />
        </div>
      </div>
      <button 
        onClick={runSimulation} 
        disabled={running}
        style={{ 
          padding: '0.5rem 1rem', 
          background: running ? '#ccc' : '#2e7d32', 
          color: '#fff', 
          border: 'none', 
          borderRadius: '4px',
          cursor: running ? 'default' : 'pointer'
        }}
      >
        {running ? 'Running...' : 'Run Simulation'}
      </button>
    </div>
  );
};
