import React from 'react';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer
} from 'recharts';

export const DPRChart = ({ datasets }) => {
  if (!datasets || datasets.length === 0) return <div>No data available</div>;

  // Normalize datasets to always be an array of result sets
  const rawRuns = Array.isArray(datasets[0]) ? datasets : [datasets];
  const runs = rawRuns.filter(r => !!r && Array.isArray(r));
  
  if (runs.length === 0) return <div>No data available</div>;

  const roundStats = {}; // { roundNumber: { label: { totalDamage: 0 } } }

  runs.forEach((run, runIdx) => {
    const runLabel = `Run ${runIdx + 1}`;
    run.forEach(combat => {
      if (!combat || !combat.rounds) return;
      combat.rounds.forEach(round => {
        if (!roundStats[round.number]) roundStats[round.number] = {};
        
        round.events.forEach(event => {
          const key = runs.length > 1 ? `${runLabel}: ${event.attacker}` : event.attacker;
          if (!roundStats[round.number][key]) {
            roundStats[round.number][key] = { totalDamage: 0 };
          }
          roundStats[round.number][key].totalDamage += event.damage;
        });
      });
    });
  });

  if (Object.keys(roundStats).length === 0) return <div>No data available</div>;

  const chartData = Object.keys(roundStats).map(roundNum => {
    const entry = { round: parseInt(roundNum) };
    Object.keys(roundStats[roundNum]).forEach(key => {
      // Find which run this key belongs to to get the correct divisor
      const runIdxMatch = key.match(/^Run (\d+):/);
      const runIdx = runIdxMatch ? parseInt(runIdxMatch[1]) - 1 : 0;
      entry[key] = parseFloat((roundStats[roundNum][key].totalDamage / runs[runIdx].length).toFixed(2));
    });
    return entry;
  }).sort((a, b) => a.round - b.round);

  const keys = Object.keys(chartData[0] || {}).filter(k => k !== 'round');
  const colors = ['#8884d8', '#82ca9d', '#ffc658', '#ff7300', '#0088FE', '#00C49F'];

  return (
    <div style={{ width: '100%', height: 400, marginTop: '2rem' }}>
      <h3>Average Damage Per Round (DPR) {runs.length > 1 && '(Comparison Mode)'}</h3>
      <ResponsiveContainer width="100%" height="100%">
        <LineChart data={chartData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="round" label={{ value: 'Round', position: 'insideBottomRight', offset: -5 }} />
          <YAxis label={{ value: 'Avg Damage', angle: -90, position: 'insideLeft' }} />
          <Tooltip />
          <Legend />
          {keys.map((key, index) => (
            <Line
              key={key}
              type="monotone"
              dataKey={key}
              stroke={colors[index % colors.length]}
              activeDot={{ r: 8 }}
            />
          ))}
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
};
