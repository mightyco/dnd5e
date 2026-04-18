import React, { useState, useEffect } from 'react';

export const SimulationLibrary = ({ onRun }) => {
  const [simulations, setSimulations] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchSims = async () => {
    try {
      const response = await fetch('/api/simulations');
      const data = await response.json();
      setSimulations(data);
    } catch (err) {
      console.error('Failed to fetch simulations', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSims();
  }, []);

  const runSimulation = async (id) => {
    try {
      const response = await fetch(`/api/simulations/run/${id}`, { method: 'POST' });
      const results = await response.json();
      onRun(results);
    } catch (err) {
      alert('Failed to run simulation');
    }
  };

  if (loading) return <p>Loading library...</p>;

  return (
    <div style={{ marginTop: 0 }}>
      <h2 style={{ marginBottom: '1.5rem' }}>Simulation Library</h2>
      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', 
        gap: '1.25rem' 
      }}>
        {simulations.map(sim => (
          <div key={sim.id} style={{ 
            padding: '1.25rem', 
            border: '1px solid #e0e0e0', 
            borderRadius: '12px', 
            background: '#fff',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'space-between',
            transition: 'transform 0.2s, box-shadow 0.2s',
            cursor: 'default',
            boxShadow: '0 2px 8px rgba(0,0,0,0.05)'
          }}>
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start', marginBottom: '0.75rem' }}>
                <strong style={{ fontSize: '1.05rem', color: '#333' }}>{sim.name}</strong>
                <div style={{ display: 'flex', gap: '0.25rem' }}>
                  {sim.is_variable && (
                    <span style={{ fontSize: '0.65rem', padding: '2px 6px', background: '#e8f5e9', color: '#2e7d32', borderRadius: '4px', fontWeight: 'bold' }}>SWEEP</span>
                  )}
                  <span style={{ fontSize: '0.65rem', padding: '2px 6px', background: sim.type === 'preset' ? '#e3f2fd' : '#f3e5f5', borderRadius: '4px', color: sim.type === 'preset' ? '#1976d2' : '#7b1fa2', fontWeight: 'bold' }}>
                    {sim.type.toUpperCase()}
                  </span>
                </div>
              </div>
              <p style={{ fontSize: '0.85rem', margin: '0 0 1rem 0', color: '#666', lineHeight: '1.4' }}>{sim.description}</p>
            </div>
            
            <div style={{ borderTop: '1px solid #f0f0f0', paddingTop: '1rem' }}>
              <div style={{ fontSize: '0.75rem', color: '#888', marginBottom: '1rem', display: 'flex', justifyContent: 'space-between' }}>
                <span>Level {sim.level}</span>
                <span>{sim.num_simulations} Runs</span>
              </div>
              <button 
                onClick={() => runSimulation(sim.id)} 
                data-testid={`run-preset-${sim.id}`}
                style={{ 
                  width: '100%',
                  padding: '8px', 
                  background: '#1976d2', 
                  color: '#fff', 
                  border: 'none', 
                  borderRadius: '6px', 
                  cursor: 'pointer',
                  fontSize: '0.9rem',
                  fontWeight: 'bold'
                }}
              >
                Run Scenario
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
