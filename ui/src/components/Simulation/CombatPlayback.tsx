import React, { useState, useEffect, useMemo } from 'react';

// SPEC-0009: Visual Combat Playback Component
// This component renders a 2D tactical grid and animates combat events.

interface Point {
  x: number;
  y: number;
  z: number;
}

interface CombatantState {
  name: string;
  x: number;
  y: number;
  z: number;
  hp: number;
  max_hp: number;
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

const GRID_SIZE = 50; // pixels per 5ft square
const PADDING = 20;

export const CombatPlayback = ({ combatData }) => {
  const [currentEventIndex, setCurrentEventIndex] = useState(0);
  const [isPlaying, setIsPlaybackRunning] = useState(false);
  const [playbackSpeed, setPlaybackSpeed] = useState(1000); // ms per event

  // Flatten all rounds and events into a single sequence for playback
  const events = useMemo(() => {
    const allEvents: CombatEvent[] = [];
    if (!combatData) return allEvents;

    combatData.rounds.forEach(round => {
      round.events.forEach(event => {
        allEvents.push(event);
      });
    });
    return allEvents;
  }, [combatData]);

  // Derived state: current positions and HP of all combatants
  const currentState = useMemo(() => {
    if (events.length === 0) return combatData?.initial_positions || {};
    
    // Start with initial and apply all events up to current index
    const state = { ...combatData?.initial_positions };
    
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
  }, [events, currentEventIndex, combatData]);

  // Playback timer
  useEffect(() => {
    let timer;
    if (isPlaying && currentEventIndex < events.length - 1) {
      timer = setTimeout(() => {
        setCurrentEventIndex(prev => prev + 1);
      }, playbackSpeed);
    } else {
      setIsPlaybackRunning(false);
    }
    return () => clearTimeout(timer);
  }, [isPlaying, currentEventIndex, events.length, playbackSpeed]);

  if (!combatData) return null;

  // Determine grid bounds
  const combatants = Object.values(currentState) as any[];
  const minX = Math.min(0, ...combatants.map(c => c.x));
  const maxX = Math.max(100, ...combatants.map(c => c.x));
  const minY = Math.min(0, ...combatants.map(c => c.y));
  const maxY = Math.max(50, ...combatants.map(c => c.y));

  const width = (maxX - minX) / 5 * GRID_SIZE + PADDING * 2;
  const height = (maxY - minY) / 5 * GRID_SIZE + PADDING * 2;

  const toScreen = (val: number, isY = false) => {
    const min = isY ? minY : minX;
    return (val - min) / 5 * GRID_SIZE + PADDING;
  };

  return (
    <div style={{ background: '#222', color: '#fff', padding: '1rem', borderRadius: '8px', marginTop: '1rem' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
        <h3 style={{ margin: 0 }}>🎥 Tactical Replay</h3>
        <div style={{ display: 'flex', gap: '0.5rem' }}>
          <button onClick={() => setCurrentEventIndex(0)}>⏮</button>
          <button onClick={() => setIsPlaybackRunning(!isPlaying)}>
            {isPlaying ? '⏸' : '▶️'}
          </button>
          <button onClick={() => setCurrentEventIndex(prev => Math.min(events.length - 1, prev + 1))}>⏭</button>
          <select value={playbackSpeed} onChange={(e) => setPlaybackSpeed(parseInt(e.target.value))}>
            <option value={2000}>0.5x</option>
            <option value={1000}>1.0x</option>
            <option value={500}>2.0x</option>
            <option value={200}>4.0x</option>
          </select>
        </div>
      </div>

      <div style={{ overflow: 'auto', maxHeight: '500px', border: '1px solid #444', background: '#1a1a1a' }}>
        <svg width={width} height={height}>
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
            <g key={name} transform={`translate(${toScreen(data.x)}, ${toScreen(data.y)})`} style={{ transition: 'transform 0.3s ease-out' }}>
              <circle r="15" fill={data.hp > 0 ? '#444' : '#222'} stroke="#666" strokeWidth="2" />
              <text textAnchor="middle" dy="5" fontSize="10" fill="#fff" style={{ pointerEvents: 'none' }}>
                {name.substring(0, 2)}
              </text>
              {/* HP Bar */}
              <rect x="-15" y="-22" width="30" height="4" fill="#d32f2f" />
              <rect x="-15" y="-22" width={(data.hp / data.max_hp) * 30} height="4" fill="#2e7d32" />
              {/* Altitude Indicator */}
              {data.z > 0 && (
                <text x="12" y="-12" fontSize="8" fill="#4fc3f7">↑{data.z}ft</text>
              )}
            </g>
          ))}

          {/* Active Event Highlights */}
          {events[currentEventIndex]?.type === 'attack' && (
            <line 
              x1={toScreen(currentState[events[currentEventIndex].attacker!]?.x)} 
              y1={toScreen(currentState[events[currentEventIndex].attacker!]?.y)}
              x2={toScreen(currentState[events[currentEventIndex].defender!]?.x)} 
              y2={toScreen(currentState[events[currentEventIndex].defender!]?.y)}
              stroke={events[currentEventIndex].success ? '#f44336' : '#9e9e9e'}
              strokeWidth="2"
              strokeDasharray={events[currentEventIndex].success ? "0" : "4"}
            />
          )}
        </svg>
      </div>

      <div style={{ marginTop: '0.5rem', fontSize: '0.8rem', color: '#aaa', textAlign: 'center' }}>
        Event {currentEventIndex + 1} / {events.length}: {events[currentEventIndex]?.type} {events[currentEventIndex]?.combatant || events[currentEventIndex]?.attacker}
      </div>
    </div>
  );
};
