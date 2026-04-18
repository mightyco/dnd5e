import React, { useState, useEffect, useMemo } from 'react';

// SPEC-0009: Visual Combat Playback Component
// This component renders a 2D tactical grid and animates combat events.

interface Point {
  x: number;
  y: number;
  z: number;
}

interface CombatEvent {
  type: string;
  combatant?: string;
  attacker?: string;
  defender?: string;
  to?: Point;
  damage?: number;
  snapshot?: Record<string, any>;
  [key: string]: any;
}

const GRID_SIZE = 50; 
const PADDING = 20;

export const CombatPlayback: React.FC<{ combatData: any[] | any }> = ({ combatData }) => {
  const [simulationIndex, setSimulationIndex] = useState(0);
  const [currentEventIndex, setCurrentEventIndex] = useState(0);
  const [isPlaying, setIsPlaybackRunning] = useState(false);
  const [playbackSpeed, setPlaybackSpeed] = useState(1000); 

  // Normalize combatData to a single combat object
  const currentCombat = useMemo(() => {
    if (Array.isArray(combatData)) {
      return combatData[simulationIndex] || combatData[0];
    }
    return combatData;
  }, [combatData, simulationIndex]);

  // Flatten all rounds and events into a single sequence for playback
  const events = useMemo(() => {
    try {
      const allEvents: CombatEvent[] = [];
      if (!currentCombat || !currentCombat.rounds) return allEvents;

      currentCombat.rounds.forEach(round => {
        round.events.forEach(event => {
          allEvents.push(event);
        });
      });
      return allEvents;
    } catch (e) {
      console.error('DEBUG: Error processing events:', e);
      return [];
    }
  }, [currentCombat]);

  const currentState = useMemo(() => {
    try {
      if (!currentCombat || !currentCombat.initial_positions) return {};
      const state = { ...currentCombat.initial_positions };
      
      for (let i = 0; i <= currentEventIndex; i++) {
        const e = events[i];
        if (!e) continue;

        if (e.snapshot) {
          Object.assign(state, e.snapshot);
        } else if (e.type === 'move' && e.combatant && e.to) {
          state[e.combatant] = { ...state[e.combatant], ...e.to };
        }
      }
      return state;
    } catch (e) {
      console.error('DEBUG: Error computing state:', e);
      return {};
    }
  }, [events, currentEventIndex, currentCombat]);

  useEffect(() => {
    let timer: any;
    if (isPlaying && currentEventIndex < events.length - 1) {
      timer = setTimeout(() => {
        setCurrentEventIndex(prev => prev + 1);
      }, playbackSpeed);
    } else if (currentEventIndex >= events.length - 1) {
      setIsPlaybackRunning(false);
    }
    return () => clearTimeout(timer);
  }, [isPlaying, currentEventIndex, events.length, playbackSpeed]);

  if (!currentCombat || !currentCombat.rounds) {
    return (
      <div style={{ padding: '2rem', border: '1px dashed #666', textAlign: 'center', color: '#666' }}>
        No spatial data available for this simulation.
      </div>
    );
  }

  // Determine grid bounds safely
  const combatantList = Object.values(currentState) as any[];
  const minX = Math.min(0, ...combatantList.map(c => c.x || 0));
  const maxX = Math.max(100, ...combatantList.map(c => c.x || 0));
  const minY = Math.min(0, ...combatantList.map(c => c.y || 0));
  const maxY = Math.max(50, ...combatantList.map(c => c.y || 0));

  const width = ((maxX - minX) / 5 * GRID_SIZE) + PADDING * 2;
  const height = ((maxY - minY) / 5 * GRID_SIZE) + PADDING * 2;

  const toScreen = (val: number, isY = false) => {
    const min = isY ? minY : minX;
    return ((val - min) / 5 * GRID_SIZE) + PADDING;
  };

  return (
    <div className="combat-playback-container" data-testid="combat-playback" style={{ background: '#222', color: '#fff', padding: '1rem', borderRadius: '8px', border: '1px solid #444' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
        <div>
          <h3 style={{ margin: 0, color: '#fff' }}>🎥 Tactical Replay</h3>
          {Array.isArray(combatData) && combatData.length > 1 && (
            <select 
              value={simulationIndex} 
              onChange={(e) => { setSimulationIndex(parseInt(e.target.value)); setCurrentEventIndex(0); }}
              style={{ marginTop: '0.5rem', fontSize: '0.7rem', background: '#333', color: '#fff' }}
            >
              {combatData.slice(0, 10).map((_, i) => (
                <option key={i} value={i}>Simulation #{i + 1}</option>
              ))}
            </select>
          )}
        </div>
        <div style={{ display: 'flex', gap: '0.5rem' }}>
          <button onClick={() => setCurrentEventIndex(0)} title="Reset">⏮</button>
          <button onClick={() => setIsPlaybackRunning(!isPlaying)} title={isPlaying ? "Pause" : "Play"}>
            {isPlaying ? '⏸' : '▶️'}
          </button>
          <button onClick={() => setCurrentEventIndex(prev => Math.min(events.length - 1, prev + 1))} title="Step">⏭</button>
          <select 
            value={playbackSpeed} 
            onChange={(e) => setPlaybackSpeed(parseInt(e.target.value))}
            style={{ background: '#333', color: '#fff', border: '1px solid #555' }}
          >
            <option value={2000}>0.5x</option>
            <option value={1000}>1.0x</option>
            <option value={500}>2.0x</option>
            <option value={200}>4.0x</option>
          </select>
        </div>
      </div>

      <div style={{ overflow: 'auto', maxHeight: '500px', border: '1px solid #444', background: '#1a1a1a', borderRadius: '4px' }}>
        <svg width={width} height={height} style={{ display: 'block' }}>
          {/* Grid Lines */}
          {Array.from({ length: Math.ceil((maxX - minX) / 5) + 1 }).map((_, i) => (
            <line 
              key={`v-${i}`} 
              x1={toScreen(minX + i * 5)} y1={toScreen(minY)} 
              x2={toScreen(minX + i * 5)} y2={toScreen(maxY)} 
              stroke="#333" strokeWidth="1" 
            />
          ))}
          {Array.from({ length: Math.ceil((maxY - minY) / 5) + 1 }).map((_, i) => (
            <line 
              key={`h-${i}`} 
              x1={toScreen(minX)} y1={toScreen(minY + i * 5)} 
              x2={toScreen(maxX)} y2={toScreen(minY + i * 5)} 
              stroke="#333" strokeWidth="1" 
            />
          ))}

          {/* Combatants */}
          {Object.entries(currentState).map(([name, data]: [string, any]) => (
            <g key={name} transform={`translate(${toScreen(data.x || 0)}, ${toScreen(data.y || 0)})`} style={{ transition: 'transform 0.3s ease-out' }}>
              <circle r="15" fill={data.hp > 0 ? '#444' : '#111'} stroke={data.hp > 0 ? '#888' : '#333'} strokeWidth="2" />
              <text textAnchor="middle" dy="5" fontSize="10" fill={data.hp > 0 ? "#fff" : "#666"} style={{ pointerEvents: 'none' }}>
                {name.substring(0, 2)}
              </text>
              <rect x="-15" y="-22" width="30" height="4" fill="#d32f2f" />
              <rect x="-15" y="-22" width={(Math.max(0, data.hp) / data.max_hp) * 30} height="4" fill="#2e7d32" />
              {data.z > 0 && (
                <text x="12" y="-12" fontSize="8" fill="#4fc3f7">↑{data.z}ft</text>
              )}
            </g>
          ))}

          {/* Active Event Highlights */}
          {events[currentEventIndex]?.type === 'attack' && (
            <line 
              x1={toScreen(currentState[events[currentEventIndex].attacker!]?.x || 0)} 
              y1={toScreen(currentState[events[currentEventIndex].attacker!]?.y || 0)}
              x2={toScreen(currentState[events[currentEventIndex].defender!]?.x || 0)} 
              y2={toScreen(currentState[events[currentEventIndex].defender!]?.y || 0)}
              stroke={events[currentEventIndex].success ? '#f44336' : '#9e9e9e'}
              strokeWidth="2"
              strokeDasharray={events[currentEventIndex].success ? "0" : "4"}
            />
          )}
        </svg>
      </div>

      <div style={{ marginTop: '0.5rem', fontSize: '0.8rem', color: '#aaa', textAlign: 'center' }}>
        Event {currentEventIndex + 1} / {events.length}: {events[currentEventIndex]?.type} {events[currentEventIndex]?.combatant || events[currentEventIndex]?.attacker || ''}
      </div>
    </div>
  );
};
