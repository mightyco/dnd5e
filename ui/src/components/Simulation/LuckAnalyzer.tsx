import React from 'react';
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
  if (!data || data.length === 0) return null;

  // Aggregate d20 rolls across all combats
  const distribution = Array(20).fill(0).reduce((acc, _, i) => ({ ...acc, [i + 1]: 0 }), {});
  let totalD20Rolls = 0;
  let sumD20Rolls = 0;

  data.forEach(combat => {
    combat.rounds.forEach(round => {
      round.events.forEach(event => {
        const raw = event.metadata?.picked_roll;
        // Only count d20 rolls (attack rolls, saves)
        if (raw && (event.type === 'attack' || event.type === 'save')) {
          distribution[raw]++;
          totalD20Rolls++;
          sumD20Rolls += raw;
        }
      });
    });
  });

  if (totalD20Rolls === 0) return null;

  const avgRoll = sumD20Rolls / totalD20Rolls;
  const luckRating = avgRoll - 10.5;
  const expectedFrequency = totalD20Rolls / 20;

  const chartData = Object.entries(distribution).map(([roll, count]) => ({
    roll: parseInt(roll),
    count,
    deviation: ((count / expectedFrequency) - 1) * 100
  }));

  const getBarColor = (roll) => {
    if (roll === 1) return '#d32f2f'; // Nat 1
    if (roll === 20) return '#2e7d32'; // Nat 20
    return '#8884d8';
  };

  return (
    <div style={{ marginTop: '2rem', padding: '1.5rem', background: '#fff', border: '1px solid #ddd', borderRadius: '8px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h3>Math Transparency: Dice Engine Analysis</h3>
        <div style={{ textAlign: 'right' }}>
          <div style={{ fontSize: '1.2rem', fontWeight: 'bold', color: luckRating >= 0 ? '#2e7d32' : '#d32f2f' }}>
            Luck Rating: {luckRating >= 0 ? '+' : ''}{luckRating.toFixed(2)}
          </div>
          <div style={{ fontSize: '0.8rem', color: '#666' }}>Avg d20: {avgRoll.toFixed(2)} (Expected: 10.5)</div>
        </div>
      </div>

      <div style={{ width: '100%', height: 250, marginTop: '1rem' }}>
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={chartData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="roll" tick={{ fontSize: 12 }} />
            <YAxis hide />
            <Tooltip 
              formatter={(value, name) => [value, name === 'count' ? 'Roll Count' : name]}
              labelFormatter={(label) => `Roll: ${label}`}
            />
            <Bar dataKey="count">
              {chartData.map((entry, index) => (
                <Cell key={`cell-${index}`} fill={getBarColor(entry.roll)} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>
      <p style={{ fontSize: '0.75rem', color: '#999', marginTop: '0.5rem', textAlign: 'center' }}>
        Distribution of {totalD20Rolls} d20 rolls. A "Luck Rating" of 0.0 indicates perfect statistical average.
      </p>
    </div>
  );
};
