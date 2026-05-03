import React, { useState, useEffect } from 'react';
import { CharacterBuilder } from './CharacterBuilder';

export const ScenarioConfigurator = ({ onRun, initialConfig, onConfigHandled }) => {
  const [characterPool, setCharacterPool] = useState([]);
  const [variables, setVariables] = useState({});
  const [metadata, setMetadata] = useState({ 
    classes: [], 
    subclasses: {}, 
    monsters: [],
    feats: [],
    fighting_styles: [],
    weapons: [],
    armor: [],
    shields: []
  });
  const [teams, setTeams] = useState([
    { name: 'Heroes', members: [], count: "1" },
    { name: 'Monsters', members: [], count: "1" }
  ]);
  const [simConfig, setSimConfig] = useState({
    name: 'Custom Sweep',
    level: 1,
    num_simulations: 100,
    max_rounds: 100,
    distance: 30
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
        num_simulations: initialConfig.num_simulations || 100,
        max_rounds: initialConfig.max_rounds || 100,
        distance: initialConfig.distance || 30
      });
      setVariables(initialConfig.variables || {});
      
      const newPool = [];
      const newTeams = initialConfig.teams.map(t => {
        const teamMembers = [];
        const sourceMembers = t.members || (t.template ? [t.template] : []);
        
        sourceMembers.forEach(m => {
          const member = { 
            abilities: { strength: 10, dexterity: 10, constitution: 10, intelligence: 10, wisdom: 10, charisma: 10 },
            weapon: 'longsword',
            armor: 'breastplate',
            feats: [],
            fightingStyle: '',
            ...m, 
            id: Math.random() 
          };
          teamMembers.push(member);
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
    setTeams(prevTeams => {
      return prevTeams.map((team, tIdx) => {
        if (tIdx !== teamIdx) return team;
        
        const newMembers = team.members.map((member, mIdx) => {
          if (mIdx !== memberIdx) return member;
          
          let updatedMember;
          if (field.startsWith('ability.')) {
            const ability = field.split('.')[1];
            updatedMember = { 
              ...member, 
              abilities: { ...member.abilities, [ability]: parseInt(val) } 
            };
          } else {
            updatedMember = { ...member, [field]: val };
          }
          
          if (field === 'type') {
            const isClass = metadata.classes.includes(val);
            if (isClass) {
              updatedMember.subclass = (metadata.subclasses[val] && metadata.subclasses[val][0]) || '';
            } else {
              delete updatedMember.subclass;
            }
          }
          return updatedMember;
        });
        
        return { ...team, members: newMembers };
      });
    });
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

  const labelStyle: React.CSSProperties = {
    fontSize: '0.65rem',
    fontWeight: 'bold',
    color: '#888',
    textTransform: 'uppercase',
    marginBottom: '2px'
  };

  return (
    <div className="scenario-configurator lab-card" style={{ marginTop: '3rem' }}>
      <h2>Scientific Lab Runner</h2>
      
      {/* Variable Editor */}
      <div style={{ padding: '1.5rem', border: '1px solid var(--border)', borderRadius: '8px', background: '#f8fafd', marginBottom: '2rem' }}>
        <h3 style={{ marginTop: 0, color: 'var(--accent)' }}>1. Parameter Sweep Variables</h3>
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
          <button onClick={addVariable} style={{ padding: '0.5rem 1rem' }}>
            Add Variable
          </button>
        </div>
      </div>

      <div className="grid-2">
        <div style={{ padding: '1.5rem', border: '1px solid var(--border)', borderRadius: '8px', background: '#fafafa' }}>
          <CharacterBuilder onSave={addToPool} />
        </div>
        
        <div style={{ padding: '1.5rem', border: '1px solid var(--border)', borderRadius: '8px', background: '#fafafa' }}>
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

      <div className="grid-2" style={{ marginTop: '2rem' }}>
        {teams.map((team, idx) => (
          <div key={idx} data-testid={`team-panel-${idx}`} style={{ padding: '1.5rem', border: '1px solid var(--border)', borderRadius: '8px', background: idx === 0 ? '#f1f8e9' : '#fff3e0' }}>
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
            
            <ul style={{ listStyle: 'none', padding: 0, margin: 0 }}>
              {team.members.map((m, mIdx) => {
                const isClass = metadata.classes.includes(m.type);
                const subclasses = metadata.subclasses[m.type] || [];
                
                return (
                  <li key={m.id || mIdx} data-testid="team-member" style={{ padding: '1rem', background: '#fff', border: '1px solid rgba(0,0,0,0.05)', borderRadius: '8px', marginBottom: '1rem', boxShadow: '0 2px 4px rgba(0,0,0,0.02)' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.75rem' }}>
                      <input 
                        value={m.name} 
                        onChange={e => updateMemberField(idx, mIdx, 'name', e.target.value)}
                        style={{ fontWeight: 'bold', border: 'none', borderBottom: '1px solid #eee', width: '70%', fontSize: '1rem' }}
                      />
                      <button onClick={() => {
                        const newTeams = [...teams];
                        newTeams[idx].members.splice(mIdx, 1);
                        setTeams(newTeams);
                      }} style={{ background: 'none', border: 'none', color: '#d32f2f', cursor: 'pointer' }}>×</button>
                    </div>
                    
                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.5rem' }}>
                      <div>
                        <label style={labelStyle}>Type</label>
                        <select value={m.type} onChange={e => updateMemberField(idx, mIdx, 'type', e.target.value)} style={{ width: '100%', padding: '4px' }} data-testid="member-type-select">
                          <optgroup label="Classes">
                            {metadata.classes.map(cls => <option key={cls} value={cls}>{cls.toUpperCase()}</option>)}
                          </optgroup>
                          <optgroup label="Monsters">
                            {metadata.monsters.map(mon => <option key={mon} value={mon}>{mon.toUpperCase()}</option>)}
                          </optgroup>
                        </select>
                      </div>
                      
                      {isClass && (
                        <div>
                          <label style={labelStyle}>Subclass</label>
                          <select value={m.subclass || ''} onChange={e => updateMemberField(idx, mIdx, 'subclass', e.target.value)} style={{ width: '100%', padding: '4px' }} data-testid="member-subclass-select">
                            <option value="">Standard</option>
                            {subclasses.map(sc => <option key={sc} value={sc}>{sc.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}</option>)}
                          </select>
                        </div>
                      )}
                    </div>

                    {isClass && (
                      <div style={{ marginTop: '0.75rem', paddingTop: '0.75rem', borderTop: '1px solid #f5f5f5' }}>
                        <label style={labelStyle}>Abilities</label>
                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gap: '4px' }}>
                          {['strength', 'dexterity', 'constitution', 'intelligence', 'wisdom', 'charisma'].map(ab => (
                            <div key={ab}>
                              <div style={{ fontSize: '0.55rem', textAlign: 'center', color: '#aaa' }}>{ab.slice(0,3).toUpperCase()}</div>
                              <input 
                                type="number" 
                                name={`ability.${ab}`} 
                                value={m.abilities ? m.abilities[ab] : 10} 
                                onChange={e => updateMemberField(idx, mIdx, `ability.${ab}`, e.target.value)}
                                style={{ width: '100%', textAlign: 'center', fontSize: '0.75rem', padding: '2px' }}
                              />
                            </div>
                          ))}
                        </div>
                        
                        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '0.5rem', marginTop: '0.75rem' }}>
                          <div>
                            <label style={labelStyle}>Weapon</label>
                            <select value={m.weapon || 'longsword'} onChange={e => updateMemberField(idx, mIdx, 'weapon', e.target.value)} style={{ width: '100%', fontSize: '0.75rem' }}>
                              {metadata.weapons.map(w => <option key={w} value={w}>{w.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ')}</option>)}
                            </select>
                          </div>
                          <div>
                            <label style={labelStyle}>Armor</label>
                            <select value={m.armor || 'breastplate'} onChange={e => updateMemberField(idx, mIdx, 'armor', e.target.value)} style={{ width: '100%', fontSize: '0.75rem' }}>
                              <option value="">Unarmored</option>
                              {metadata.armor.map(a => <option key={a} value={a}>{a.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ')}</option>)}
                            </select>
                          </div>
                          {['fighter', 'paladin', 'ranger'].includes(m.type) && (
                            <div>
                              <label style={labelStyle}>Style</label>
                              <select value={m.fightingStyle || ''} onChange={e => updateMemberField(idx, mIdx, 'fightingStyle', e.target.value)} style={{ width: '100%', fontSize: '0.75rem' }}>
                                <option value="">None</option>
                                {metadata.fighting_styles.map(fs => <option key={fs} value={fs}>{fs.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}</option>)}
                              </select>
                            </div>
                          )}
                        </div>
                      </div>
                    )}
                  </li>
                );
              })}
            </ul>
          </div>
        ))}
      </div>

      <div style={{ marginTop: '3rem', padding: '1.5rem', background: '#f5f5f5', borderRadius: '8px', border: '1px solid #eee', display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: '1rem' }}>
        <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr 1fr', gap: '1rem', flexGrow: 1 }}>
          <div>
            <label style={{ ...labelStyle, fontSize: '0.8rem', color: '#333' }}>Experiment Name</label>
            <input 
              type="text" 
              value={simConfig.name} 
              onChange={(e) => setSimConfig({ ...simConfig, name: e.target.value })} 
              style={{ width: '100%', padding: '0.5rem', borderRadius: '4px', border: '1px solid #ccc' }}
            />
          </div>
          <div>
            <label style={{ ...labelStyle, fontSize: '0.8rem', color: '#333' }}>Distance (ft)</label>
            <input 
              type="number" 
              value={simConfig.distance} 
              onChange={(e) => setSimConfig({ ...simConfig, distance: parseInt(e.target.value) })} 
              style={{ width: '100%', padding: '0.5rem', borderRadius: '4px', border: '1px solid #ccc' }}
            />
          </div>
          <div>
            <label style={{ ...labelStyle, fontSize: '0.8rem', color: '#333' }}>Max Rounds</label>
            <input 
              type="number" 
              value={simConfig.max_rounds} 
              onChange={(e) => setSimConfig({ ...simConfig, max_rounds: parseInt(e.target.value) })} 
              style={{ width: '100%', padding: '0.5rem', borderRadius: '4px', border: '1px solid #ccc' }}
            />
          </div>
        </div>
        <button 
          onClick={handleRun} 
          data-testid="launch-experiment"
          style={{ padding: '12px 30px', fontSize: '1rem', height: 'fit-content', marginTop: 'auto' }}
        >
          🚀 Launch Experiment
        </button>
      </div>
    </div>
  );
};
