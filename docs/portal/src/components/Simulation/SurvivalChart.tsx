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

  const chartData = Object.keys(winCounts).map(team => ({
    name: team,
    wins: winCounts[team],
    percentage: parseFloat(((winCounts[team] / data.length) * 100).toFixed(1))
  })).sort((a, b) => b.wins - a.wins);

  const colors = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042'];

  return (
    <div style={{ width: '100%', height: 300, marginTop: '2rem' }}>
      <h3>Win Distribution (%)</h3>
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={chartData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="name" />
          <YAxis unit="%" />
          <Tooltip formatter={(value) => `${value}%`} />
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
