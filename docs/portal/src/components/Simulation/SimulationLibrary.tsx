import React, { useEffect, useState } from 'react';

export const SimulationLibrary = ({ onRun }) => {
  const [sims, setSims] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchSims = async () => {
    try {
      const response = await fetch('http://localhost:4567/simulations');
      const data = await response.json();
      setSims(data);
    } catch (err) {
      console.error('Failed to fetch simulations', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSims();
  }, []);

  const runSim = async (id) => {
    try {
      const response = await fetch(`http://localhost:4567/simulations/run/${id}`, { method: 'POST' });
      const results = await response.json();
      onRun(results);
    } catch (err) {
      alert('Failed to run simulation');
    }
  };

  if (loading) return <p>Loading library...</p>;

  return (
    <div style={{ marginTop: '2rem' }}>
      <h3>Simulation Library</h3>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '1rem' }}>
        {sims.map(sim => (
          <div key={sim.id} style={{ padding: '1rem', border: '1px solid #ddd', borderRadius: '8px', background: '#fff' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start' }}>
              <strong>{sim.name}</strong>
              <span style={{ 
                fontSize: '0.7rem', 
                padding: '2px 6px', 
                background: sim.type === 'preset' ? '#e3f2fd' : '#f3e5f5',
                borderRadius: '4px'
              }}>
                {sim.type.toUpperCase()}
              </span>
            </div>
            <p style={{ fontSize: '0.9rem', margin: '0.5rem 0', color: '#666' }}>{sim.description}</p>
            <div style={{ fontSize: '0.8rem', color: '#888', marginBottom: '1rem' }}>
              Level: {sim.level} | Simulations: {sim.num_simulations}
            </div>
            <button 
              onClick={() => runSim(sim.id)}
              style={{ 
                padding: '4px 12px', 
                background: '#1976d2', 
                color: '#fff', 
                border: 'none', 
                borderRadius: '4px',
                cursor: 'pointer'
              }}
            >
              Run Preset
            </button>
          </div>
        ))}
      </div>
    </div>
  );
};
