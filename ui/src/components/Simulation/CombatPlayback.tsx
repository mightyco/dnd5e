import React, { useState, useEffect, useRef, useMemo } from 'react';

interface Point {
  x: number;
  y: number;
}

interface CombatantState {
  hp: number;
  max_hp: number;
  ac: number;
  attack_bonus: number;
  damage: string;
  x: number;
  y: number;
  team?: string;
}

const CombatantToken = ({ name, state, isActive }: { name: string, state: CombatantState, isActive: boolean }) => {
  const [flashClass, setFlashClass] = useState('');
  const lastHp = useRef(state.hp);

  useEffect(() => {
    if (state.hp < lastHp.current) {
      setFlashClass('damage-flash');
      setTimeout(() => setFlashClass(''), 500);
    } else if (state.hp > lastHp.current) {
      setFlashClass('heal-flash');
      setTimeout(() => setFlashClass(''), 500);
    }
    lastHp.current = state.hp;
  }, [state.hp]);

  const hpColor = state.hp > 0 ? '#4caf50' : '#d32f2f';

  return (
    <div className={flashClass} style={{
      border: isActive ? '2px solid #ffeb3b' : '1px solid #444',
      background: isActive ? '#424242' : '#333',
      padding: '0.75rem',
      marginBottom: '0.5rem',
      borderRadius: '6px',
      transition: 'all 0.2s',
      transform: isActive ? 'scale(1.02)' : 'none',
      boxShadow: isActive ? '0 0 8px rgba(255, 235, 59, 0.4)' : 'none'
    }}>
      <div style={{ fontWeight: 'bold', fontSize: '0.95rem', marginBottom: '0.25rem', color: '#fff' }}>{name}</div>
      <div style={{ fontSize: '0.8rem', color: '#bbb', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.25rem' }}>
        <span>HP: <strong style={{ color: hpColor }}>{state.hp}/{state.max_hp}</strong></span>
        <span>AC: <strong>{state.ac || '?'}</strong></span>
        <span>ATK: <strong>{state.attack_bonus >= 0 ? `+${state.attack_bonus || 0}` : state.attack_bonus}</strong></span>
        <span>DMG: <strong>{state.damage || '?'}</strong></span>
      </div>
      <div style={{ marginTop: '0.25rem', height: '4px', background: '#222', borderRadius: '2px', overflow: 'hidden' }}>
        <div style={{ 
          width: `${Math.max(0, (state.hp / state.max_hp) * 100)}%`, 
          height: '100%', 
          background: hpColor,
          transition: 'width 0.3s'
        }} />
      </div>
    </div>
  );
};

class ErrorBoundary extends React.Component<{ children: React.ReactNode }, { hasError: boolean, error: any }> {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{ padding: '2rem', background: '#fff1f0', border: '1px solid #ffa39e', borderRadius: '8px' }}>
          <h3 style={{ color: '#cf1322' }}>Playback Error</h3>
          <p style={{ fontSize: '0.85rem' }}>An error occurred during combat replay. This is often caused by switching scenarios while playback is active.</p>
          <pre style={{ fontSize: '0.7rem', padding: '0.5rem', background: '#fff', border: '1px solid #ddd' }}>
            {this.state.error?.message}
          </pre>
          <button 
            onClick={() => this.setState({ hasError: false, error: null })}
            style={{ padding: '4px 12px', background: '#f5222d', color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer' }}
          >
            Retry Replay
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}

export const CombatPlayback = (props) => (
  <ErrorBoundary>
    <CombatPlaybackContent {...props} />
  </ErrorBoundary>
);

const CombatPlaybackContent = ({ combatData }) => {
  const [simulationIndex, setSimulationIndex] = useState(0);
  const [eventIndex, setEventIndex] = useState(0);
  const [isPlaying, setIsPlaying] = useState(false);
  const [speed, setSpeed] = useState(4); // events per second
  const timerRef = useRef<any>(null);

  const speedOptions = [0.5, 1, 2, 4, 8, 16, 32];
  
  const currentCombat = Array.isArray(combatData) ? combatData[simulationIndex] : combatData;
  const events = useMemo(() => currentCombat?.rounds.flatMap(r => r.events) || [], [currentCombat]);
  
  // Reset eventIndex when combatData or simulationIndex changes
  useEffect(() => {
    setEventIndex(0);
    setIsPlaying(false);
  }, [combatData, simulationIndex]);

  const tickRate = 1000 / speed;

  useEffect(() => {
    if (isPlaying) {
      timerRef.current = setInterval(() => {
        setEventIndex(prev => {
          if (prev < events.length - 1) return prev + 1;
          setIsPlaying(false);
          return prev;
        });
      }, tickRate);
    } else {
      if (timerRef.current) clearInterval(timerRef.current);
    }
    return () => { if (timerRef.current) clearInterval(timerRef.current); };
  }, [isPlaying, events.length, tickRate]);

  const handleReset = () => {
    setEventIndex(0);
    setIsPlaying(false);
  };

  const computeCurrentState = () => {
    if (!currentCombat || events.length === 0) return {};
    
    // Find latest snapshot at or before eventIndex
    let snapshotIndex = -1;
    let latestSnapshot = null;
    
    for (let i = eventIndex; i >= 0; i--) {
      if (events[i]?.snapshot) {
        latestSnapshot = JSON.parse(JSON.stringify(events[i].snapshot));
        snapshotIndex = i;
        break;
      }
    }
    
    const state = latestSnapshot || JSON.parse(JSON.stringify(currentCombat.initial_positions || {}));
    
    // Replay intermediate moves
    for (let i = snapshotIndex + 1; i <= eventIndex; i++) {
      const e = events[i];
      if (e.type === 'move' && state[e.combatant] && e.to) {
        state[e.combatant].x = e.to.x;
        state[e.combatant].y = e.to.y;
      }
    }
    
    return state;
  };

  const getActiveCombatant = () => {
    for (let i = eventIndex; i >= 0; i--) {
      if (events[i]?.type === 'turn_start') return events[i].combatant;
    }
    return null;
  };

  const currentState = computeCurrentState();
  const stateEntries = Object.entries(currentState);
  const activeCombatant = getActiveCombatant();

  // Map Bounds
  const minX = Math.min(...stateEntries.map(([_, s]: [any, any]) => s.x), 0);
  const maxX = Math.max(...stateEntries.map(([_, s]: [any, any]) => s.x), 30);
  const minY = Math.min(...stateEntries.map(([_, s]: [any, any]) => s.y), 0);
  const maxY = Math.max(...stateEntries.map(([_, s]: [any, any]) => s.y), 30);

  const scalePos = (val: number, isY = false) => {
    const min = isY ? minY : minX;
    const range = (isY ? maxY : maxX) - min || 1;
    return 10 + ((val - min) / range) * 80; // Percent with padding
  };

  const exportJSON = (data, filename) => {
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `${filename}.json`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  // Group combatants by team
  const teams = stateEntries.reduce((acc, [name, state]: [any, any]) => {
    const teamName = state.team && state.team !== 'None' ? state.team : (name.toLowerCase().includes('hero') ? 'Heroes' : 'Monsters');
    if (!acc[teamName]) acc[teamName] = [];
    acc[teamName].push({ name, state });
    return acc;
  }, {});

  const teamNames = Object.keys(teams);
  const teamA = teamNames[0] ? teams[teamNames[0]] : [];
  const teamB = teamNames[1] ? teams[teamNames[1]] : [];

  return (
    <div className="combat-playback-container" data-testid="combat-playback" style={{ background: '#222', color: '#fff', padding: '1.5rem', borderRadius: '12px', border: '1px solid #444' }}>
      <style>{`
        .damage-flash { animation: flash-red 0.5s; }
        .heal-flash { animation: flash-green 0.5s; }
        @keyframes flash-red { 0% { background: rgba(211, 47, 47, 0.4); } 100% { background: transparent; } }
        @keyframes flash-green { 0% { background: rgba(76, 175, 80, 0.4); } 100% { background: transparent; } }
      `}</style>
      
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
        <div>
          <h3 style={{ margin: 0, color: '#fff', display: 'flex', alignItems: 'center', gap: '0.75rem', fontSize: '1.2rem' }}>
            🎥 Tactical Replay
            <button onClick={() => exportJSON(currentCombat, `combat-log-${simulationIndex + 1}`)} style={{ padding: '4px 10px', background: '#455a64', color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer', fontSize: '0.7rem', fontWeight: 'bold' }}>📥 Export JSON</button>
          </h3>
          <div style={{ fontSize: '0.85rem', color: '#aaa', marginTop: '0.25rem' }}>
            Simulation {simulationIndex + 1} of {Array.isArray(combatData) ? combatData.length : 1}
          </div>
        </div>
        <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
          <div style={{ display: 'flex', background: '#333', borderRadius: '6px', padding: '2px' }}>
            {speedOptions.map(s => (
              <button 
                key={s} 
                onClick={() => setSpeed(s)}
                style={{ 
                  padding: '4px 8px', fontSize: '0.7rem', 
                  background: speed === s ? '#1976d2' : 'transparent', 
                  color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer',
                  fontWeight: speed === s ? 'bold' : 'normal'
                }}
              >{s}x</button>
            ))}
          </div>
          <button onClick={() => setIsPlaying(!isPlaying)} style={{ padding: '8px 20px', background: isPlaying ? '#d32f2f' : '#2e7d32', color: '#fff', border: 'none', borderRadius: '6px', cursor: 'pointer', fontWeight: 'bold' }}>
            {isPlaying ? '⏸ Pause' : '▶ Play'}
          </button>
          <button onClick={handleReset} style={{ padding: '8px 12px', background: '#555', color: '#fff', border: 'none', borderRadius: '6px', cursor: 'pointer' }}>🔄 Reset</button>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '200px 1fr 200px', gap: '1rem' }}>
        {/* Left Column - Team A */}
        <div style={{ background: '#1a1a1a', borderRadius: '8px', padding: '0.5rem', border: '1px solid #333', maxHeight: '500px', overflowY: 'auto' }}>
          <h4 style={{ margin: '0 0 0.75rem 0', color: '#2196f3', textAlign: 'center', borderBottom: '1px solid #333', paddingBottom: '0.5rem' }}>{teamNames[0] || 'Team A'}</h4>
          {teamA.map(c => <CombatantToken key={c.name} name={c.name} state={c.state} isActive={activeCombatant === c.name} />)}
        </div>

        {/* Center - Map */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          <div style={{ position: 'relative', width: '100%', paddingTop: '75%', background: '#111', borderRadius: '8px', border: '2px solid #333', overflow: 'hidden' }}>
            <div style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0 }}>
              <svg style={{ width: '100%', height: '100%' }}>
                {/* Grid Lines */}
                {Array.from({ length: 11 }).map((_, i) => (
                  <React.Fragment key={i}>
                    <line x1={`${i * 10}%`} y1="0" x2={`${i * 10}%`} y2="100%" stroke="#222" strokeWidth="1" />
                    <line x1="0" y1={`${i * 10}%`} x2="100%" y2={`${i * 10}%`} stroke="#222" strokeWidth="1" />
                  </React.Fragment>
                ))}

                {/* Tokens */}
                {stateEntries.map(([name, state]: [any, any]) => {
                  const isTeamB = teamB.find(t => t.name === name);
                  return (
                    <g key={name} style={{ transition: `all ${tickRate}ms linear` }}>
                      <circle 
                        cx={`${scalePos(state.x)}%`} 
                        cy={`${scalePos(state.y, true)}%`} 
                        r="3%" 
                        fill={isTeamB ? '#f44336' : '#2196f3'} 
                        stroke={activeCombatant === name ? '#ffeb3b' : '#fff'}
                        strokeWidth={activeCombatant === name ? '4' : '2'}
                      />
                      <text 
                        x={`${scalePos(state.x)}%`} 
                        y={`${scalePos(state.y, true) + 6}%`} 
                        fill="#fff" 
                        fontSize="0.8rem" 
                        textAnchor="middle"
                        style={{ fontWeight: 'bold', textShadow: '0 1px 2px #000' }}
                      >
                        {name}
                      </text>
                    </g>
                  );
                })}
              </svg>
            </div>
          </div>
          
          <div>
            <input 
              type="range" 
              min="0" max={Math.max(0, events.length - 1)} 
              value={eventIndex} 
              onChange={(e) => { setEventIndex(parseInt(e.target.value)); setIsPlaying(false); }}
              style={{ width: '100%', cursor: 'pointer' }}
            />
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.7rem', color: '#888' }}>
              <span>START</span>
              <span>Event {eventIndex + 1} / {events.length}</span>
              <span>END</span>
            </div>
          </div>
        </div>

        {/* Right Column - Team B */}
        <div style={{ background: '#1a1a1a', borderRadius: '8px', padding: '0.5rem', border: '1px solid #333', maxHeight: '500px', overflowY: 'auto' }}>
          <h4 style={{ margin: '0 0 0.75rem 0', color: '#f44336', textAlign: 'center', borderBottom: '1px solid #333', paddingBottom: '0.5rem' }}>{teamNames[1] || 'Team B'}</h4>
          {teamB.map(c => <CombatantToken key={c.name} name={c.name} state={c.state} isActive={activeCombatant === c.name} />)}
        </div>
      </div>

      {/* Event Log */}
      <div style={{ marginTop: '1.5rem', padding: '1rem', background: '#333', borderRadius: '8px', maxHeight: '200px', overflowY: 'auto' }}>
        <div style={{ fontWeight: 'bold', borderBottom: '1px solid #444', paddingBottom: '0.5rem', marginBottom: '0.5rem', color: '#888', fontSize: '0.8rem', textTransform: 'uppercase' }}>Event Log</div>
        {events.slice(0, eventIndex + 1).reverse().map((e, i) => (
          <div key={i} style={{ 
            fontSize: '0.85rem', 
            marginBottom: '4px', 
            padding: '4px 8px',
            borderRadius: '4px',
            background: i === 0 ? 'rgba(255,255,255,0.1)' : 'transparent',
            color: i === 0 ? '#fff' : '#ccc',
            borderLeft: i === 0 ? '3px solid #1976d2' : 'none'
          }}>
            <span style={{ color: '#888', marginRight: '8px' }}>[{events.length - i}]</span>
            {e.type === 'attack' && (
              <span>
                <strong>{e.attacker}</strong> {e.success ? 'HIT' : 'MISSED'} <strong>{e.defender}</strong> with {e.attack_name}
                {e.metadata?.maneuver && <span style={{ color: '#ffeb3b' }}> ({String(e.metadata.maneuver).replace('_', ' ')})</span>}
                {e.success && <span style={{ color: '#f44336' }}> (-{e.damage} HP)</span>}
                {e.is_crit && <span style={{ color: '#ffeb3b', marginLeft: '4px' }}> CRIT!</span>}
                {e.is_dead && <span style={{ color: '#9e9e9e', marginLeft: '4px' }}> [DEAD]</span>}
              </span>
            )}
            {e.type === 'resource_used' && (
              <span style={{ color: '#4fc3f7' }}>
                🛡️ <strong>{e.combatant}</strong> used {String(e.resource).replace('_', ' ')}
              </span>
            )}
            {e.type === 'save' && (
              <span>
                🛡️ <strong>{e.defender}</strong> rolled save vs <strong>{e.attacker}</strong> ({e.attack_name})
                {e.success ? <span style={{ color: '#2e7d32' }}> SAVED</span> : <span style={{ color: '#d32f2f' }}> FAILED (-{e.damage} HP)</span>}
                {e.is_dead && <span style={{ color: '#9e9e9e', marginLeft: '4px' }}> [DEAD]</span>}
              </span>
            )}
            {e.type === 'move' && <span><strong>{e.combatant}</strong> moved to ({e.to?.x}, {e.to?.y})</span>}
            {e.type === 'turn_start' && <span style={{ color: '#ffeb3b' }}>▶ <strong>{e.combatant}</strong> started their turn</span>}
          </div>
        ))}
      </div>
    </div>
  );
};
