import React, { useState, useEffect } from 'react';
import { CharacterBuilder } from './CharacterBuilder';

export const ScenarioConfigurator = ({ onRun, initialConfig, onConfigHandled }) => {
  const [characterPool, setCharacterPool] = useState([]);
  const [variables, setVariables] = useState({});
  const [metadata, setMetadata] = useState({ classes: [], subclasses: {}, monsters: [] });
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

  useEffect(() => {
    fetch('/api/metadata')
      .then(res => res.json())
      .then(data => setMetadata(data))
      .catch(err => console.error('Failed to load metadata', err));
  }, []);

  useEffect(() => {
    if (initialConfig) {
      setSimConfig({
        name: `Copy of ${initialConfig.name}`,
        level: initialConfig.level || 1,
        num_simulations: initialConfig.num_simulations || 100
      });
      setVariables(initialConfig.variables || {});
      
      const newPool = [];
      const newTeams = initialConfig.teams.map(t => {
        const teamMembers = [];
        const sourceMembers = t.members || (t.template ? [t.template] : []);
        
        sourceMembers.forEach(m => {
          const member = { ...m, id: Math.random() };
          teamMembers.push(member);
          // Only add to pool if not already there (based on name/type/subclass)
          if (!newPool.some(p => p.name === m.name && p.type === m.type && p.subclass === m.subclass)) {
            newPool.push(member);
          }
        });
        
        return {
          name: t.name,
          count: String(t.count || sourceMembers.length || 1),
          members: teamMembers
        };
      });
      
      setCharacterPool(newPool);
      setTeams(newTeams);
      if (onConfigHandled) onConfigHandled();
    }
  }, [initialConfig, onConfigHandled]);

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

  const updateMemberField = (teamIdx, memberIdx, field, val) => {
    const newTeams = [...teams];
    const member = newTeams[teamIdx].members[memberIdx];
    member[field] = val;
    
    if (field === 'type') {
      const isClass = metadata.classes.includes(val);
      if (isClass) {
        member.subclass = (metadata.subclasses[val] && metadata.subclasses[val][0]) || '';
      } else {
        delete member.subclass;
      }
    }
    
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
    <div className="scenario-configurator" style={{ marginTop: '3rem', padding: '2.5rem', background: '#ffffff', borderRadius: '12px', boxShadow: '0 4px 20px rgba(0,0,0,0.05)' }}>
      <h2 style={{ borderBottom: '2px solid #f0f0f0', paddingBottom: '0.5rem', marginBottom: '2rem' }}>Scientific Lab Runner</h2>
      
      {/* Variable Editor */}
      <div style={{ padding: '1.5rem', border: '1px solid #e0e0e0', borderRadius: '8px', background: '#f8fafd', marginBottom: '2rem' }}>
        <h3 style={{ marginTop: 0, color: '#1976d2' }}>1. Parameter Sweep Variables</h3>
        <div style={{ display: 'flex', gap: '1rem', marginBottom: '1rem' }}>
          <input 
            placeholder="Var Name (e.g. count)" 
            value={newVar.name} 
            onChange={e => setNewVar({...newVar, name: e.target.value})} 
            style={{ padding: '0.5rem', borderRadius: '4px', border: '1px solid #ccc' }}
          />
          <input 
            placeholder="Values (e.g. [1,2,4])" 
            value={newVar.values} 
            onChange={e => setNewVar({...newVar, values: e.target.value})} 
            style={{ flexGrow: 1, padding: '0.5rem', borderRadius: '4px', border: '1px solid #ccc' }} 
          />
          <button onClick={addVariable} style={{ padding: '0.5rem 1rem', background: '#1976d2', color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer' }}>
            Add Variable
          </button>
        </div>
        <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
          {Object.entries(variables).map(([name, vals]) => (
            <span key={name} style={{ background: '#fff', border: '1px solid #90caf9', padding: '6px 12px', borderRadius: '20px', fontSize: '0.85rem', display: 'inline-flex', alignItems: 'center' }}>
              <strong>{name}</strong>:<span style={{marginLeft:'4px'}}>{JSON.stringify(vals)}</span>
              <button onClick={() => { const v = {...variables}; delete v[name]; setVariables(v); }} style={{ marginLeft: '8px', border: 'none', background: '#ffcdd2', color: '#c62828', borderRadius: '50%', width: '20px', height: '20px', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>×</button>
            </span>
          ))}
          {Object.keys(variables).length === 0 && <span style={{ color: '#666', fontSize: '0.85rem', fontStyle: 'italic' }}>No variables defined. Single run mode.</span>}
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem' }}>
        <div style={{ padding: '1.5rem', border: '1px solid #e0e0e0', borderRadius: '8px', background: '#fafafa' }}>
          <CharacterBuilder onSave={addToPool} />
        </div>
        
        <div style={{ padding: '1.5rem', border: '1px solid #e0e0e0', borderRadius: '8px', background: '#fafafa' }}>
          <h3 style={{ marginTop: 0 }}>2. Character Pool</h3>
          <div style={{ maxHeight: '250px', overflowY: 'auto' }} data-testid="character-pool">
            {characterPool.length === 0 && <p style={{ color: '#999', fontStyle: 'italic', textAlign: 'center', marginTop: '2rem' }}>Pool is empty. Create a character to start.</p>}
            {characterPool.map(c => (
              <div key={c.id} data-testid="pool-member" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem', padding: '0.75rem', background: '#fff', border: '1px solid #eee', borderRadius: '6px' }}>
                <span style={{ fontWeight: '500' }}>{c.name} <span style={{ color: '#666', fontWeight: 'normal', fontSize: '0.8rem' }}>({c.type})</span></span>
                <div style={{ display: 'flex', gap: '0.25rem' }}>
                  <button onClick={() => addToTeam(c, 0)} style={{ fontSize: '0.75rem', padding: '4px 8px', background: '#e8f5e9', border: '1px solid #c8e6c9', color: '#2e7d32', borderRadius: '4px', cursor: 'pointer' }}>+ Team A</button>
                  <button onClick={() => addToTeam(c, 1)} style={{ fontSize: '0.75rem', padding: '4px 8px', background: '#ffebee', border: '1px solid #ffcdd2', color: '#c62828', borderRadius: '4px', cursor: 'pointer' }}>+ Team B</button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem', marginTop: '2rem' }}>
        {teams.map((team, idx) => (
          <div key={idx} data-testid={`team-panel-${idx}`} style={{ padding: '1.5rem', border: '1px solid #e0e0e0', borderRadius: '8px', background: idx === 0 ? '#f1f8e9' : '#fff3e0' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
              <h3 style={{ margin: 0, color: idx === 0 ? '#2e7d32' : '#ef6c00' }}>{team.name}</h3>
              <label style={{ fontSize: '0.9rem', fontWeight: 'bold' }}>
                Count:{' '}
                <input 
                  value={team.count} 
                  onChange={e => updateTeamCount(idx, e.target.value)} 
                  style={{ width: '60px', padding: '0.25rem', borderRadius: '4px', border: '1px solid #ccc' }} 
                />
              </label>
            </div>
            
            {team.members.length === 0 && <p style={{ color: '#999', fontStyle: 'italic', fontSize: '0.85rem' }}>No members added to this team yet.</p>}
            
            <ul style={{ listStyle: 'none', padding: 0, margin: 0 }}>
              {team.members.map((m, mIdx) => {
                const isClass = metadata.classes.includes(m.type);
                const options = isClass ? metadata.classes : metadata.monsters;
                const subclasses = metadata.subclasses[m.type] || [];
                
                return (
                  <li key={m.id || mIdx} data-testid="team-member" style={{ padding: '0.75rem', background: '#fff', border: '1px solid rgba(0,0,0,0.05)', borderRadius: '6px', marginBottom: '0.5rem' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <input 
                        value={m.name} 
                        onChange={e => updateMemberField(idx, mIdx, 'name', e.target.value)}
                        style={{ fontWeight: 'bold', border: 'none', borderBottom: '1px solid #eee', width: '60%' }}
                      />
                      <button 
                        onClick={() => {
                          const newTeams = [...teams];
                          newTeams[idx].members.splice(mIdx, 1);
                          setTeams(newTeams);
                        }}
                        style={{ background: 'none', border: 'none', color: '#d32f2f', fontSize: '0.7rem', cursor: 'pointer' }}
                      >
                        Remove
                      </button>
                    </div>
                    
                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.5rem', marginTop: '0.5rem' }}>
                      <select 
                        value={m.type} 
                        onChange={e => updateMemberField(idx, mIdx, 'type', e.target.value)}
                        style={{ fontSize: '0.8rem', padding: '4px', borderRadius: '4px', border: '1px solid #ddd' }}
                        data-testid="member-type-select"
                      >
                        {options.map(opt => (
                          <option key={opt} value={opt}>{opt.charAt(0).toUpperCase() + opt.slice(1)}</option>
                        ))}
                      </select>
                      
                      {isClass && subclasses.length > 0 && (
                        <select 
                          value={m.subclass || ''} 
                          onChange={e => updateMemberField(idx, mIdx, 'subclass', e.target.value)}
                          style={{ fontSize: '0.8rem', padding: '4px', borderRadius: '4px', border: '1px solid #ddd' }}
                          data-testid="member-subclass-select"
                        >
                          <option value="">Standard</option>
                          {subclasses.map(sc => (
                            <option key={sc} value={sc}>{sc.charAt(0).toUpperCase() + sc.slice(1)}</option>
                          ))}
                        </select>
                      )}
                    </div>
                  </li>
                );
              })}
            </ul>
          </div>
        ))}
      </div>

      <div style={{ marginTop: '3rem', padding: '1.5rem', background: '#f5f5f5', borderRadius: '8px', border: '1px solid #eee', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
          <label style={{ fontWeight: 'bold', color: '#333' }}>Experiment Name:</label>
          <input 
            type="text" 
            value={simConfig.name} 
            onChange={(e) => setSimConfig({ ...simConfig, name: e.target.value })} 
            style={{ padding: '0.5rem', borderRadius: '4px', border: '1px solid #ccc', minWidth: '250px' }}
          />
        </div>
        <button 
          onClick={handleRun} 
          data-testid="launch-experiment"
          style={{ padding: '12px 30px', background: '#1976d2', color: '#fff', border: 'none', borderRadius: '6px', fontSize: '1rem', fontWeight: 'bold', cursor: 'pointer', boxShadow: '0 2px 5px rgba(25, 118, 210, 0.4)' }}
        >
          🚀 Launch Experiment
        </button>
      </div>
    </div>
  );
};
