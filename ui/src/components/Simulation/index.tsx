import React, { useState } from 'react';
import { DPRChart } from './DPRChart';
import { SurvivalChart } from './SurvivalChart';
import { RollInspector } from './RollInspector';
import { ScenarioConfigurator } from './ScenarioConfigurator';
import { SimulationLibrary } from './SimulationLibrary';
import { DeltaAnalysis } from './LabAnalysis';
import { TrendChart } from './TrendChart';
import { LuckAnalyzer } from './LuckAnalyzer';
import { CombatPlayback } from './CombatPlayback';

export const SimulationDashboard = () => {
  const [history, setHistory] = useState([]);
  const [selectedIndices, setSelectedIndices] = useState([]);
  const [loading, setLoading] = useState(false);

  const handleResults = (payload) => {
    const newRun = { 
      timestamp: new Date().toLocaleTimeString(), 
      payload: payload,
      isBatch: !!payload.is_batch,
      name: `Run ${history.length + 1}` 
    };
    const newHistory = [...history, newRun];
    setHistory(newHistory);
    setSelectedIndices([newHistory.length - 1]); 
    
    setTimeout(() => {
      const resultsEl = document.getElementById('simulation-results');
      if (resultsEl) resultsEl.scrollIntoView({ behavior: 'smooth' });
    }, 200);
  };

  const currentRun = history.length > 0 ? history[selectedIndices[0]] || history[history.length - 1] : null;
  const selectedDatasets = selectedIndices.map(i => history[i]?.payload.results[0].data).filter(Boolean);

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
                <span>{run.name} {run.isBatch ? '(Sweep)' : ''} ({run.timestamp})</span>
              </div>
            ))}
          </div>
          <button onClick={() => { setHistory([]); setSelectedIndices([]); }} style={{ marginTop: '1rem', fontSize: '0.8rem' }}>Clear History</button>
        </div>
        
        <SimulationLibrary onRun={handleResults} />
      </div>

      <ScenarioConfigurator onRun={handleResults} />

      {loading && <p>Processing data...</p>}

      <div id="simulation-results">
        {currentRun && (
          <div style={{ marginTop: '3rem', borderTop: '2px solid #eee', paddingTop: '2rem' }}>
            <h2>Analysis: {selectedIndices.length > 1 ? 'Comparative' : currentRun.name}</h2>
            
            {/* Replayer is now TOP LEVEL results - available for single and sweep runs (sample) */}
            {selectedIndices.length <= 1 && (
              <div id="combat-playback-section" style={{ marginBottom: '2rem', padding: '1.5rem', background: '#fff', border: '1px solid #ddd', borderRadius: '8px' }}>
                <h3>Combat Replay</h3>
                <p style={{ fontSize: '0.8rem', color: '#666', marginBottom: '1rem' }}>Viewing sample combat from the simulation set.</p>
                <CombatPlayback combatData={currentRun.payload.results[0].data} />
              </div>
            )}

            {currentRun.isBatch && selectedIndices.length === 1 ? (
              <TrendChart batchResults={currentRun.payload} />
            ) : (
              <>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem' }}>
                  {selectedIndices.length === 1 ? (
                    <>
                      <SurvivalChart data={currentRun.payload.results[0].data} />
                      <div style={{ padding: '1rem', background: '#fff', border: '1px solid #ddd', borderRadius: '8px' }}>
                        <h3>Quick Stats</h3>
                        <ul>
                          <li>Total Simulations: {currentRun.payload.results[0].data.length}</li>
                          <li>Average Rounds: {(currentRun.payload.results[0].data.reduce((acc, c) => acc + c.rounds.length, 0) / currentRun.payload.results[0].data.length).toFixed(1)}</li>
                        </ul>
                      </div>
                    </>
                  ) : (
                    <DeltaAnalysis datasets={selectedDatasets} />
                  )}
                </div>
                
                {selectedIndices.length === 1 && <LuckAnalyzer data={currentRun.payload.results[0].data} />}
              </>
            )}
            
            {!currentRun.isBatch && <DPRChart datasets={selectedDatasets} />}
            {!currentRun.isBatch && selectedIndices.length === 1 && <RollInspector data={currentRun.payload.results[0].data} />}
          </div>
        )}
      </div>
    </div>
  );
};
