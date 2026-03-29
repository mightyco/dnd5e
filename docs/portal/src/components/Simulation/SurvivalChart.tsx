import React from 'react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  Cell
} from 'recharts';

export const SurvivalChart = ({ data }) => {
  if (!data || data.length === 0) return <div>No data available</div>;

  const winCounts = {}; // { teamName: count }
  data.forEach(combat => {
    if (combat.winner) {
      winCounts[combat.winner] = (winCounts[combat.winner] || 0) + 1;
    }
  });

  const chartData = Object.keys(winCounts).map(team => {
    const p = winCounts[team] / data.length;
    const n = data.length;
    const marginOfError = 1.96 * Math.sqrt((p * (1 - p)) / n);
    return {
      name: team,
      wins: winCounts[team],
      percentage: parseFloat((p * 100).toFixed(1)),
      ci: parseFloat((marginOfError * 100).toFixed(1))
    };
  }).sort((a, b) => b.wins - a.wins);

  const colors = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042'];

  return (
    <div style={{ width: '100%', height: 300, marginTop: '2rem' }}>
      <h3>Win Distribution (%)</h3>
      <div style={{ fontSize: '0.8rem', color: '#666', marginBottom: '0.5rem' }}>
        * Error bars represent 95% Confidence Interval (n={data.length})
      </div>
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={chartData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="name" />
          <YAxis unit="%" />
          <Tooltip formatter={(value, name, props) => {
            if (name === 'Win Rate') return [`${value}% ± ${props.payload.ci}%`, name];
            return [value, name];
          }} />
          <Legend />
          <Bar dataKey="percentage" name="Win Rate">
            {chartData.map((entry, index) => (
              <Cell key={`cell-${index}`} fill={colors[index % colors.length]} />
            ))}
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
};
