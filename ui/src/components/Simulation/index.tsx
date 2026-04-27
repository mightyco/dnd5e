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
import { HeroEfficiency } from './HeroEfficiency';

export const SimulationDashboard = () => {
  const [history, setHistory] = useState([]);
  const [selectedIndices, setSelectedIndices] = useState([]);
  const [loading, setLoading] = useState(false);
  const [activeTab, setActiveTab] = useState('presets');
  const [editingConfig, setEditingConfig] = useState(null);
  const [compareMode, setCompareMode] = useState(false);

  const handleResults = (payload) => {
    const newRun = { 
      timestamp: new Date().toLocaleTimeString(), 
      payload: payload,
      isBatch: !!payload.is_batch,
      name: payload.name || `Run ${history.length + 1}` 
    };
    const newHistory = [...history, newRun];
    setHistory(newHistory);
    setSelectedIndices([newHistory.length - 1]); 
    setCompareMode(false);
    
    setTimeout(() => {
      const resultsEl = document.getElementById('simulation-results');
      if (resultsEl) resultsEl.scrollIntoView({ behavior: 'smooth' });
    }, 200);
  };

  const handleToggleSelect = (idx) => {
    if (selectedIndices.includes(idx)) {
      setSelectedIndices(selectedIndices.filter(i => i !== idx));
    } else {
      setSelectedIndices([...selectedIndices, idx]);
    }
  };

  const currentRun = history.length > 0 ? history[selectedIndices[0]] || history[history.length - 1] : null;
  const selectedDatasets = selectedIndices.map(i => history[i]?.payload.results[0].data).filter(Boolean);

  const handleEdit = (config) => {
    setEditingConfig(config);
    setActiveTab('custom');
  };

  const gTabStyle = (tab) => ({
    padding: '0.75rem 1.5rem',
    cursor: 'pointer',
    borderBottom: activeTab === tab ? '3px solid #1976d2' : '3px solid transparent',
    fontWeight: activeTab === tab ? 'bold' : 'normal',
    color: activeTab === tab ? '#1976d2' : '#666',
    transition: 'all 0.2s'
  });

  return (
    <div className="simulation-dashboard">
      <div style={{ display: 'grid', gridTemplateColumns: '320px 1fr', gap: '2rem', marginBottom: '2rem' }}>
        <div style={{ padding: '1.5rem', background: '#f8f9fa', borderRadius: '12px', border: '1px solid #e0e0e0', height: 'fit-content' }}>
          <h2 style={{ fontSize: '1.2rem', marginTop: 0, display: 'flex', alignItems: 'center', gap: '0.5rem' }}>🧪 Run History</h2>
          <div style={{ maxHeight: '400px', overflowY: 'auto', background: '#fff', padding: '0.5rem', border: '1px solid #ddd', borderRadius: '8px' }}>
            {history.length === 0 && <p style={{ color: '#999', padding: '1rem' }}>No simulations run yet.</p>}
            {history.map((run, idx) => (
              <div key={idx} style={{ 
                display: 'flex', 
                alignItems: 'center', 
                gap: '0.5rem', 
                padding: '0.75rem', 
                borderBottom: '1px solid #f0f0f0',
                background: selectedIndices.includes(idx) ? '#e3f2fd' : 'transparent',
                cursor: 'pointer'
              }} onClick={() => handleToggleSelect(idx)}>
                <input 
                  type="checkbox" 
                  checked={selectedIndices.includes(idx)} 
                  onChange={() => {}} 
                />
                <div style={{ flexGrow: 1, fontSize: '0.85rem' }}>
                  <div style={{ fontWeight: 'bold' }}>{run.name}</div>
                  <div style={{ fontSize: '0.7rem', color: '#888' }}>{run.timestamp}</div>
                </div>
              </div>
            ))}
          </div>
          {selectedIndices.length >= 2 && (
            <button 
              onClick={() => setCompareMode(true)}
              style={{ 
                marginTop: '1rem', 
                width: '100%', 
                padding: '12px', 
                background: '#1976d2', 
                color: '#fff', 
                border: 'none', 
                borderRadius: '6px', 
                fontWeight: 'bold', 
                cursor: 'pointer',
                boxShadow: '0 4px 10px rgba(25, 118, 210, 0.3)'
              }}
            >
              📊 Compare {selectedIndices.length} Selected
            </button>
          )}
          <button onClick={() => { setHistory([]); setSelectedIndices([]); setCompareMode(false); }} style={{ marginTop: '1rem', width: '100%', padding: '8px', fontSize: '0.8rem', background: '#fff', border: '1px solid #ccc', borderRadius: '4px', cursor: 'pointer', color: '#666' }}>🗑 Clear History</button>
        </div>
        
        <div>
          <div style={{ display: 'flex', gap: '1rem', borderBottom: '1px solid #e0e0e0', marginBottom: '1.5rem' }}>
            <div style={gTabStyle('presets')} onClick={() => setActiveTab('presets')}>Library Presets</div>
            <div style={gTabStyle('custom')} onClick={() => setActiveTab('custom')}>Custom Lab</div>
          </div>
          
          {activeTab === 'presets' ? (
            <SimulationLibrary onRun={handleResults} onEdit={handleEdit} />
          ) : (
            <ScenarioConfigurator 
              onRun={handleResults} 
              initialConfig={editingConfig} 
              onConfigHandled={() => setEditingConfig(null)} 
            />
          )}
        </div>
      </div>

      {loading && <p>Processing data...</p>}

      <div id="simulation-results">
        {currentRun && (
          <div style={{ marginTop: '3rem', borderTop: '2px solid #eee', paddingTop: '2rem' }}>
            <h2>Analysis: {compareMode ? `Comparative (${selectedIndices.length} runs)` : currentRun.name}</h2>
            
            {/* Replayer is now TOP LEVEL results - available for single and sweep runs (sample) */}
            {!compareMode && (
              <div id="combat-playback-section" style={{ marginBottom: '2rem', padding: '1.5rem', background: '#fff', border: '1px solid #ddd', borderRadius: '8px' }}>
                <h3>Combat Replay</h3>
                <p style={{ fontSize: '0.8rem', color: '#666', marginBottom: '1rem' }}>Viewing sample combat from the simulation set.</p>
                <CombatPlayback combatData={currentRun.payload.results[0].data} />
              </div>
            )}

            {currentRun.isBatch && !compareMode ? (
              <TrendChart batchResults={currentRun.payload} />
            ) : (
              <>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem' }}>
                  {!compareMode ? (
                    <>
                      {currentRun.payload.id?.includes('swarm') ? (
                        <HeroEfficiency data={currentRun.payload.results[0].data} />
                      ) : (
                        <SurvivalChart data={currentRun.payload.results[0].data} />
                      )}
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
                
                {!compareMode && <LuckAnalyzer data={currentRun.payload.results[0].data} />}
              </>
            )}
            
            <DPRChart datasets={selectedDatasets} />
            {!currentRun.isBatch && !compareMode && <RollInspector data={currentRun.payload.results[0].data} />}
          </div>
        )}
      </div>
    </div>
  );
};
