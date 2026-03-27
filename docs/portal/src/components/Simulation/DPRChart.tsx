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

export const DPRChart = ({ data }) => {
  if (!data || data.length === 0) return <div>No data available</div>;

  // Process data to calculate average DPR per round per team
  const roundStats = {}; // { roundNumber: { teamName: { totalDamage: 0, count: 0 } } }

  data.forEach(combat => {
    combat.rounds.forEach(round => {
      if (!roundStats[round.number]) roundStats[round.number] = {};
      
      round.events.forEach(event => {
        if (!roundStats[round.number][event.attacker]) {
          roundStats[round.number][event.attacker] = { totalDamage: 0, count: 0 };
        }
        roundStats[round.number][event.attacker].totalDamage += event.damage;
      });
    });
  });

  // Transform into Recharts format: [{ round: 1, TeamA: 10, TeamB: 5 }, ...]
  const chartData = Object.keys(roundStats).map(roundNum => {
    const entry = { round: parseInt(roundNum) };
    Object.keys(roundStats[roundNum]).forEach(attacker => {
      // Average damage for this round across all simulations
      // Note: This is simplified; real DPR would divide by total simulations that reached this round
      entry[attacker] = parseFloat((roundStats[roundNum][attacker].totalDamage / data.length).toFixed(2));
    });
    return entry;
  }).sort((a, b) => a.round - b.round);

  const attackers = Array.from(new Set(data.flatMap(c => c.teams)));
  const colors = ['#8884d8', '#82ca9d', '#ffc658', '#ff7300'];

  return (
    <div style={{ width: '100%', height: 400, marginTop: '2rem' }}>
      <h3>Average Damage Per Round (DPR)</h3>
      <ResponsiveContainer width="100%" height="100%">
        <LineChart data={chartData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="round" label={{ value: 'Round', position: 'insideBottomRight', offset: -5 }} />
          <YAxis label={{ value: 'Avg Damage', angle: -90, position: 'insideLeft' }} />
          <Tooltip />
          <Legend />
          {attackers.map((attacker, index) => (
            <Line
              key={attacker}
              type="monotone"
              dataKey={attacker}
              stroke={colors[index % colors.length]}
              activeDot={{ r: 8 }}
            />
          ))}
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
};
