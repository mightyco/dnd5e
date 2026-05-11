import React, { useState, useEffect } from 'react';
import { CharacterBuilder } from './CharacterBuilder';
import { FluidDetails } from './FluidDetails';

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
    shields: [],
    ui_schema: { character_fields: [] }
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
  const [showConfirm, setShowConfirm] = useState(false);

  useEffect(() => {
    fetch('/api/metadata')
      .then(res => res.json())
      .then(data => {
        if (!data.ui_schema) {
          data.ui_schema = { character_fields: [] };
        }
        setMetadata(data);
      })
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
            ac: 16,
            hp: 33,
            max_hp: 33,
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

  const buildPayload = () => {
    return {
      ...simConfig,
      variables: Object.keys(variables).length > 0 ? variables : undefined,
      teams: teams.map(t => ({
        name: t.name,
        count: t.count,
        template: t.members.length === 1 ? t.members[0] : undefined,
        members: t.members.length > 1 ? t.members : (t.members.length === 1 ? undefined : [])
      }))
    };
  };

  const handleRun = async () => {
    if (!showConfirm) {
      setShowConfirm(true);
      return;
    }
    
    setShowConfirm(false);
    const payload = buildPayload();
    
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

      {showConfirm && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.85)', zIndex: 'var(--z-modal-bg)', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '2rem', backdropFilter: 'blur(4px)' }}>
          <div style={{ background: '#fff', padding: '2rem', borderRadius: '12px', maxWidth: '800px', width: '90%', maxHeight: '90vh', overflow: 'hidden', display: 'flex', flexDirection: 'column', boxShadow: '0 20px 50px rgba(0,0,0,0.4)', color: '#333', zIndex: 'var(--z-modal-content)' }}>
            <h3 style={{ marginTop: 0, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              Verify Simulation Intent
              <span style={{ fontSize: '0.7rem', background: '#e3f2fd', color: '#1565c0', padding: '4px 10px', borderRadius: '20px' }}>AI Manifest v3.0</span>
            </h3>
            
            <div style={{ flexGrow: 1, overflowY: 'auto', marginBottom: '1.5rem', background: '#f5f5f5', borderRadius: '8px', padding: '1rem', border: '1px solid #ddd' }}>
              <pre style={{ fontSize: '0.75rem', margin: 0, color: '#2e7d32' }}>
                {JSON.stringify(buildPayload(), null, 2)}
              </pre>
            </div>

            <div style={{ display: 'flex', gap: '1rem' }}>
              <button onClick={() => setShowConfirm(false)} style={{ flex: 1, padding: '12px', background: '#eee', border: 'none', borderRadius: '6px', cursor: 'pointer', fontWeight: 'bold' }}>Abort & Edit</button>
              <button onClick={handleRun} data-testid="confirm-launch" style={{ flex: 2, padding: '12px', background: 'var(--accent)', color: '#fff', border: 'none', borderRadius: '6px', cursor: 'pointer', fontWeight: 'bold', fontSize: '1rem' }}>Confirm & Launch Analysis</button>
            </div>
          </div>
        </div>
      )}
      
      {/* Variable Editor */}
      <div style={{ padding: '1.5rem', border: '1px solid var(--border)', borderRadius: '8px', background: '#f8fafd', marginBottom: '2rem' }}>
        <h3 style={{ marginTop: 0, color: 'var(--accent)' }}>1. Parameter Sweep Variables</h3>
        <div style={{ display: 'flex', gap: '1rem', marginBottom: '1rem' }}>
          <input placeholder="Var Name" value={newVar.name} onChange={e => setNewVar({...newVar, name: e.target.value})} style={{ padding: '0.5rem', borderRadius: '4px', border: '1px solid #ccc' }} />
          <input placeholder="Values [1,2,4]" value={newVar.values} onChange={e => setNewVar({...newVar, values: e.target.value})} style={{ flexGrow: 1, padding: '0.5rem', borderRadius: '4px', border: '1px solid #ccc' }} />
          <button onClick={addVariable} style={{ padding: '0.5rem 1rem' }}>Add Variable</button>
        </div>
      </div>

      <div className="grid-2">
        <div style={{ padding: '1.5rem', border: '1px solid var(--border)', borderRadius: '8px', background: '#fafafa' }}>
          <CharacterBuilder onSave={addToPool} />
        </div>
        
        <div style={{ padding: '1.5rem', border: '1px solid var(--border)', borderRadius: 'var(--radius)', background: '#fafafa', display: 'flex', flexDirection: 'column' }}>
          <h3 style={{ marginTop: 0 }}>2. Character Pool</h3>
          <div style={{ flexGrow: 1, maxHeight: '500px', overflowY: 'auto', paddingRight: '0.5rem' }} data-testid="character-pool">
            {characterPool.length === 0 && <p style={{ color: '#999', fontStyle: 'italic', textAlign: 'center', marginTop: '2rem' }}>Pool is empty.</p>}
            {characterPool.map(c => (
              <div key={c.id} data-testid="pool-member" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem', padding: '0.75rem', background: '#fff', border: '1px solid var(--border)', borderRadius: 'var(--radius)', boxShadow: 'var(--shadow-sm)' }}>
                <span style={{ fontWeight: '500' }}>{c.name} <span style={{ color: 'var(--text-muted)', fontSize: '0.8rem' }}>({c.type || 'unknown'})</span></span>
                <div style={{ display: 'flex', gap: '0.25rem' }}>
                  <button onClick={() => addToTeam(c, 0)} data-testid={`add-to-team-0-${c.name}`} style={{ fontSize: '0.75rem', padding: '4px 8px', background: '#e8f5e9', border: '1px solid #c8e6c9', color: '#2e7d32', borderRadius: '4px' }}>+ Team A</button>
                  <button onClick={() => addToTeam(c, 1)} data-testid={`add-to-team-1-${c.name}`} style={{ fontSize: '0.75rem', padding: '4px 8px', background: '#ffebee', border: '1px solid #ffcdd2', color: '#c62828', borderRadius: '4px' }}>+ Team B</button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="grid-2" style={{ marginTop: '2rem' }}>
        {teams.map((team, idx) => (
          <div key={idx} data-testid={`team-panel-${idx}`} style={{ padding: '1.5rem', border: '1px solid var(--border)', borderRadius: 'var(--radius)', background: idx === 0 ? 'var(--team-a-bg)' : 'var(--team-b-bg)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
              <h3 style={{ margin: 0, color: idx === 0 ? 'var(--team-a-primary)' : 'var(--team-b-primary)' }}>{team.name}</h3>
              <label style={{ fontSize: '0.9rem', fontWeight: 'bold' }}>
                Count: <input value={team.count} onChange={e => updateTeamCount(idx, e.target.value)} style={{ width: '60px', padding: '0.25rem' }} />
              </label>
            </div>
            
            <ul style={{ listStyle: 'none', padding: 0, margin: 0 }}>
              {team.members.map((m, mIdx) => {
                const isClass = m && metadata.classes && metadata.classes.includes(m.type);
                
                return (
                  <li key={m.id || mIdx} data-testid="team-member" style={{ padding: '1rem', background: '#fff', border: '1px solid var(--border)', borderRadius: 'var(--radius)', marginBottom: '1rem', boxShadow: 'var(--shadow-sm)' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.75rem' }}>
                      <input value={m.name} onChange={e => updateMemberField(idx, mIdx, 'name', e.target.value)} style={{ fontWeight: 'bold', border: 'none', borderBottom: '1px solid #eee', width: '70%' }} />
                      <button onClick={() => {
                        const newTeams = [...teams];
                        newTeams[idx].members.splice(mIdx, 1);
                        setTeams(newTeams);
                      }} style={{ background: 'none', border: 'none', color: '#d32f2f' }}>×</button>
                    </div>
                    
                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.5rem' }}>
                      <FluidDetails 
                        schema={metadata.ui_schema}
                        metadata={metadata}
                        data={m}
                        onChange={e => updateMemberField(idx, mIdx, e.target.name, e.target.value)}
                        zone="basic"
                        testIdPrefix={`member-${idx}-${mIdx}`}
                        labelStyle={labelStyle}
                      />
                    </div>

                    {isClass && (
                      <div style={{ marginTop: '0.75rem', paddingTop: '0.75rem', borderTop: '1px solid #f5f5f5' }}>
                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gap: '4px' }}>
                          <FluidDetails 
                            schema={metadata.ui_schema}
                            metadata={metadata}
                            data={m}
                            onChange={e => updateMemberField(idx, mIdx, e.target.name, e.target.value)}
                            zone="stats"
                            testIdPrefix={`member-${idx}-${mIdx}`}
                            labelStyle={{ ...labelStyle, textAlign: 'center', fontSize: '0.55rem' }}
                          />
                        </div>
                        
                        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '0.5rem', marginTop: '0.75rem' }}>
                          <FluidDetails 
                            schema={metadata.ui_schema}
                            metadata={metadata}
                            data={m}
                            onChange={e => updateMemberField(idx, mIdx, e.target.name, e.target.value)}
                            zone="equipment"
                            testIdPrefix={`member-${idx}-${mIdx}`}
                            labelStyle={labelStyle}
                          />
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
            <input type="text" value={simConfig.name} onChange={(e) => setSimConfig({ ...simConfig, name: e.target.value })} data-testid="experiment-name-input" style={{ width: '100%', padding: '0.5rem' }} />
          </div>
          <div>
            <label style={{ ...labelStyle, fontSize: '0.8rem', color: '#333' }}>Distance (ft)</label>
            <input type="number" value={simConfig.distance} onChange={(e) => setSimConfig({ ...simConfig, distance: parseInt(e.target.value) })} style={{ width: '100%', padding: '0.5rem' }} />
          </div>
          <div>
            <label style={{ ...labelStyle, fontSize: '0.8rem', color: '#333' }}>Max Rounds</label>
            <input type="number" value={simConfig.max_rounds} onChange={(e) => setSimConfig({ ...simConfig, max_rounds: parseInt(e.target.value) })} style={{ width: '100%', padding: '0.5rem' }} />
          </div>
        </div>
        <button onClick={handleRun} data-testid="launch-experiment" style={{ padding: '12px 30px', fontSize: '1rem' }}>🚀 Launch Experiment</button>
      </div>
    </div>
  );
};
