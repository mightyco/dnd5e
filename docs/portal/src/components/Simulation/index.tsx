import React, { useState } from 'react';
import { DPRChart } from './DPRChart';
import { SurvivalChart } from './SurvivalChart';
import { RollInspector } from './RollInspector';
import { ScenarioConfigurator } from './ScenarioConfigurator';
import { SimulationLibrary } from './SimulationLibrary';
import { DeltaAnalysis } from './LabAnalysis';

export const SimulationDashboard = () => {
  const [history, setHistory] = useState([]);
  const [selectedIndices, setSelectedIndices] = useState([]);
  const [loading, setLoading] = useState(false);

  const handleResults = (results) => {
    const newHistory = [...history, { 
      timestamp: new Date().toLocaleTimeString(), 
      data: results,
      name: `Run ${history.length + 1}` 
    }];
    setHistory(newHistory);
    setSelectedIndices([newHistory.length - 1]); // Auto-select newest
    
    setTimeout(() => {
      const resultsEl = document.getElementById('simulation-results');
      if (resultsEl) resultsEl.scrollIntoView({ behavior: 'smooth' });
    }, 100);
  };

  const currentRun = history[selectedIndices[0]]?.data;
  const selectedDatasets = selectedIndices.map(i => history[i].data);

  return (
    <div className="simulation-dashboard">
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem', marginBottom: '2rem' }}>
        <div style={{ padding: '1.5rem', background: '#f5f5f5', borderRadius: '8px' }}>
          <h2>Lab History</h2>
          <div style={{ maxHeight: '200px', overflowY: 'auto', background: '#fff', padding: '0.5rem', border: '1px solid #ddd' }}>
            {history.length === 0 && <p style={{ color: '#999' }}>No runs yet.</p>}
            {history.map((run, idx) => (
              <div key={idx} style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.5rem' }}>
                <input 
                  type="checkbox" 
                  checked={selectedIndices.includes(idx)} 
                  onChange={() => {
                    if (selectedIndices.includes(idx)) {
                      setSelectedIndices(selectedIndices.filter(i => i !== idx));
                    } else {
                      setSelectedIndices([...selectedIndices, idx]);
                    }
                  }}
                />
                <span>{run.name} ({run.timestamp})</span>
              </div>
            ))}
          </div>
          <button onClick={() => setHistory([])} style={{ marginTop: '1rem', fontSize: '0.8rem' }}>Clear History</button>
        </div>
        
        <SimulationLibrary onRun={handleResults} />
      </div>

      <ScenarioConfigurator onRun={handleResults} />

      {loading && <p>Processing data...</p>}

      {selectedDatasets.length > 0 && (
        <div id="simulation-results" style={{ marginTop: '3rem', borderTop: '2px solid #eee', paddingTop: '2rem' }}>
          <h2>Analysis: {selectedIndices.length > 1 ? 'Comparative' : history[selectedIndices[0]].name}</h2>
          
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem' }}>
            {selectedIndices.length === 1 ? (
              <>
                <SurvivalChart data={currentRun} />
                <div>
                  <h3>Quick Stats</h3>
                  <div style={{ padding: '1rem', background: '#fff', border: '1px solid #ddd', borderRadius: '8px' }}>
                    <ul>
                      <li>Total Simulations: {currentRun.length}</li>
                      <li>Average Rounds: {(currentRun.reduce((acc, c) => acc + c.rounds.length, 0) / currentRun.length).toFixed(1)}</li>
                      <li>Total Crits: {currentRun.flatMap(c => c.rounds.flatMap(r => r.events)).filter(e => e.type === 'attack' && e.is_crit).length}</li>
                    </ul>
                  </div>
                </div>
              </>
            ) : (
              <div>
                <DeltaAnalysis datasets={selectedDatasets} />
                <p style={{ marginTop: '1rem', fontSize: '0.8rem', color: '#666' }}>
                  * Comparisons are based on Team A vs Team B. Mixed compositions may yield unpredictable deltas.
                </p>
              </div>
            )}
          </div>
          
          <DPRChart datasets={selectedDatasets} />
          
          {selectedIndices.length === 1 && <RollInspector data={currentRun} />}
        </div>
      )}
    </div>
  );
};
