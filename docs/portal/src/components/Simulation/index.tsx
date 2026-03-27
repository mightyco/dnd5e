import React, { useState } from 'react';
import { DPRChart } from './DPRChart';
import { SurvivalChart } from './SurvivalChart';
import { RollInspector } from './RollInspector';
import { LabRunnerForm } from './LabRunnerForm';

export const SimulationDashboard = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);

  const handleFileUpload = (event) => {
    const file = event.target.files[0];
    if (!file) return;

    setLoading(true);
    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const json = JSON.parse(e.target.result);
        setData(json);
      } catch (err) {
        alert('Failed to parse JSON file');
      }
      setLoading(false);
    };
    reader.readAsText(file);
  };

  return (
    <div className="simulation-dashboard">
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem', marginBottom: '2rem' }}>
        <div style={{ padding: '1.5rem', background: '#f5f5f5', borderRadius: '8px' }}>
          <h2>Data Source</h2>
          <p>Upload a <code>results.json</code> file or use the Live Runner.</p>
          <input type="file" accept=".json" onChange={handleFileUpload} />
        </div>
        
        <LabRunnerForm onResults={(results) => setData(results)} />
      </div>

      {loading && <p>Processing data...</p>}

      {data && (
        <>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem' }}>
            <SurvivalChart data={data} />
            <div>
              <h3>Quick Stats</h3>
              <div style={{ padding: '1rem', background: '#fff', border: '1px solid #ddd', borderRadius: '8px' }}>
                <ul>
                  <li>Total Simulations: {data.length}</li>
                  <li>Average Rounds: {(data.reduce((acc, c) => acc + c.rounds.length, 0) / data.length).toFixed(1)}</li>
                  <li>Total Crits: {data.flatMap(c => c.rounds.flatMap(r => r.events)).filter(e => e.is_crit).length}</li>
                </ul>
              </div>
            </div>
          </div>
          
          <DPRChart data={data} />
          
          <RollInspector data={data} />
        </>
      )}
    </div>
  );
};
