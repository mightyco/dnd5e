import React, { useState } from 'react';
import { CharacterBuilder } from './CharacterBuilder';

export const ScenarioConfigurator = ({ onRun }) => {
  const [characterPool, setCharacterPool] = useState([]);
  const [variables, setVariables] = useState({});
  const [teams, setTeams] = useState([
    { name: 'Heroes', members: [], count: "1" },
    { name: 'Monsters', members: [], count: "1" }
  ]);
  const [simConfig, setSimConfig] = useState({
    name: 'Custom Sweep',
    level: 1,
    num_simulations: 100
  });

  const [newVar, setNewVar] = useState({ name: '', values: '' });

  const addVariable = () => {
    if (!newVar.name || !newVar.values) return;
    try {
      const vals = JSON.parse(newVar.values);
      setVariables({ ...variables, [newVar.name]: vals });
      setNewVar({ name: '', values: '' });
    } catch (e) {
      alert('Values must be a valid JSON array, e.g. [1, 2, 4]');
    }
  };

  const addToPool = (char) => {
    setCharacterPool([...characterPool, { ...char, id: Date.now() }]);
  };

  const addToTeam = (char, teamIndex) => {
    const newTeams = [...teams];
    newTeams[teamIndex].members.push({ ...char, id: Date.now() });
    setTeams(newTeams);
  };

  const updateTeamCount = (idx, val) => {
    const newTeams = [...teams];
    newTeams[idx].count = val;
    setTeams(newTeams);
  };

  const updateMemberSubclass = (teamIdx, memberIdx, val) => {
    const newTeams = [...teams];
    newTeams[teamIdx].members[memberIdx].subclass = val;
    setTeams(newTeams);
  };

  const handleRun = async () => {
    const payload = {
      ...simConfig,
      variables: Object.keys(variables).length > 0 ? variables : undefined,
      teams: teams.map(t => ({
        name: t.name,
        count: t.count,
        template: t.members.length === 1 ? t.members[0] : undefined,
        members: t.members.length > 1 ? t.members : (t.members.length === 1 ? undefined : [])
      }))
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

  return (
    <div style={{ marginTop: '2rem', padding: '2rem', background: '#f9f9f9', borderRadius: '8px' }}>
      <h2>Scientific Lab Runner</h2>
      
      {/* Variable Editor */}
      <div style={{ padding: '1.5rem', border: '1px solid #ddd', borderRadius: '8px', background: '#fff', marginBottom: '2rem' }}>
        <h3>1. Define Variables (Parameter Sweep)</h3>
        <div style={{ display: 'flex', gap: '1rem', marginBottom: '1rem' }}>
          <input placeholder="Var Name (e.g. count)" value={newVar.name} onChange={e => setNewVar({...newVar, name: e.target.value})} />
          <input placeholder="Values (e.g. [1,2,4])" value={newVar.values} onChange={e => setNewVar({...newVar, values: e.target.value})} style={{ flexGrow: 1 }} />
          <button onClick={addVariable}>Add Variable</button>
        </div>
        <div style={{ display: 'flex', gap: '0.5rem' }}>
          {Object.entries(variables).map(([name, vals]) => (
            <span key={name} style={{ background: '#e3f2fd', padding: '4px 8px', borderRadius: '4px', fontSize: '0.8rem' }}>
              <strong>{name}</strong>: {JSON.stringify(vals)} 
              <button onClick={() => { const v = {...variables}; delete v[name]; setVariables(v); }} style={{ marginLeft: '5px', border: 'none', background: 'none', cursor: 'pointer' }}>×</button>
            </span>
          ))}
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem' }}>
        <CharacterBuilder onSave={addToPool} />
        
        <div style={{ padding: '1.5rem', border: '1px solid #ddd', borderRadius: '8px', background: '#fff' }}>
          <h3>2. Character Pool</h3>
          <div style={{ maxHeight: '200px', overflowY: 'auto' }}>
            {characterPool.length === 0 && <p style={{ color: '#999' }}>Pool is empty. Create a character or monster.</p>}
            {characterPool.map(c => (
              <div key={c.id} style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.5rem', padding: '0.5rem', borderBottom: '1px solid #eee' }}>
                <span>{c.name} ({c.type})</span>
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
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <h3>{team.name}</h3>
              <label>Count: <input value={team.count} onChange={e => updateTeamCount(idx, e.target.value)} style={{ width: '60px' }} /></label>
            </div>
            <ul style={{ listStyle: 'none', padding: 0 }}>
              {team.members.map((m, mIdx) => (
                <li key={mIdx} style={{ padding: '0.5rem', borderBottom: '1px solid #f5f5f5', fontSize: '0.9rem' }}>
                  {m.name} ({m.type})
                  {m.type === 'fighter' && (
                    <div style={{ marginTop: '0.2rem' }}>
                      <label>Subclass: <input value={m.subclass} onChange={e => updateMemberSubclass(idx, mIdx, e.target.value)} style={{ fontSize: '0.8rem' }} /></label>
                    </div>
                  )}
                </li>
              ))}
            </ul>
          </div>
        ))}
      </div>

      <div style={{ marginTop: '2rem', display: 'flex', gap: '1rem', alignItems: 'center' }}>
        <input 
          type="text" 
          placeholder="Experiment Name" 
          value={simConfig.name} 
          onChange={(e) => setSimConfig({ ...simConfig, name: e.target.value })} 
        />
        <button onClick={handleRun} style={{ padding: '10px 25px', background: '#2e7d32', color: '#fff', border: 'none', borderRadius: '4px', fontWeight: 'bold' }}>
          Run Scientific Sweep
        </button>
      </div>
    </div>
  );
};
