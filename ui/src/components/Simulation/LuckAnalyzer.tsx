import React, { useState } from 'react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Cell
} from 'recharts';

export const LuckAnalyzer = ({ data }) => {
  const [filter, setFilter] = useState('All'); // 'All', 'Heroes', 'Monsters'

  if (!data || data.length === 0) return null;

  // Aggregate d20 rolls
  const distribution = Array(20).fill(0).reduce((acc, _, i) => ({ ...acc, [i + 1]: 0 }), {});
  let totalD20Rolls = 0;
  let sumD20Rolls = 0;

  data.forEach(combat => {
    combat.rounds.forEach(round => {
      round.events.forEach(event => {
        const raw = event.metadata?.picked_roll;
        if (raw && (event.type === 'attack' || event.type === 'save')) {
          const isHero = event.attacker === 'Hero' || event.attacker?.includes('Hero') || event.combatant?.includes('Hero');
          const isMonster = !isHero;

          if (filter === 'All' || (filter === 'Heroes' && isHero) || (filter === 'Monsters' && isMonster)) {
            distribution[raw]++;
            totalD20Rolls++;
            sumD20Rolls += raw;
          }
        }
      });
    });
  });

  if (totalD20Rolls === 0) return <div style={{ marginTop: '2rem' }}>No d20 rolls found for filter: {filter}</div>;

  const avgRoll = sumD20Rolls / totalD20Rolls;
  const luckRating = avgRoll - 10.5;
  const expectedFrequency = totalD20Rolls / 20;

  const chartData = Object.entries(distribution).map(([roll, count]) => ({
    roll: parseInt(roll),
    count,
    deviation: ((count / expectedFrequency) - 1) * 100
  }));

  return (
    <div style={{ marginTop: '2rem', padding: '1.5rem', background: '#fff', border: '1px solid #ddd', borderRadius: '8px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h3 style={{ margin: 0 }}>Dice Engine Analysis</h3>
          <div style={{ display: 'flex', gap: '0.5rem', marginTop: '0.5rem' }}>
            {['All', 'Heroes', 'Monsters'].map(f => (
              <button 
                key={f}
                onClick={() => setFilter(f)}
                style={{ 
                  padding: '2px 10px', fontSize: '0.7rem', borderRadius: '4px', border: '1px solid #ccc',
                  background: filter === f ? '#1976d2' : '#fff', color: filter === f ? '#fff' : '#000',
                  cursor: 'pointer'
                }}
              >{f}</button>
            ))}
          </div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <div style={{ fontSize: '1.2rem', fontWeight: 'bold', color: luckRating >= 0 ? '#2e7d32' : '#d32f2f' }}>
            {filter} Luck: {luckRating >= 0 ? '+' : ''}{luckRating.toFixed(2)}
          </div>
          <div style={{ fontSize: '0.8rem', color: '#666' }}>Avg: {avgRoll.toFixed(2)} (Expected: 10.5)</div>
        </div>
      </div>

      <div style={{ width: '100%', height: 200, marginTop: '1rem' }}>
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={chartData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="roll" tick={{ fontSize: 10 }} />
            <YAxis hide />
            <Tooltip />
            <Bar dataKey="count">
              {chartData.map((entry, index) => (
                <Cell key={`cell-${index}`} fill={entry.roll === 1 ? '#d32f2f' : (entry.roll === 20 ? '#2e7d32' : '#8884d8')} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
};
