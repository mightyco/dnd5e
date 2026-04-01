import React from 'react';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  ErrorBar
} from 'recharts';

export const TrendChart = ({ batchResults }) => {
  if (!batchResults || !batchResults.results) return null;

  const { results } = batchResults;
  
  // Determine the primary variable for the X-axis
  // Find parameters that change across the results
  const allParamKeys = Object.keys(results[0].parameters || {});
  const variableKey = allParamKeys.find(key => {
    const values = new Set(results.map(r => r.parameters[key]));
    return values.size > 1;
  });

  if (!variableKey) return <div>Parameter Sweep requires at least one variable.</div>;

  // Group by other parameters to create multiple series (e.g., different subclasses)
  const otherKeys = allParamKeys.filter(k => k !== variableKey);
  const seriesGroups = {};

  results.forEach(run => {
    const seriesLabel = otherKeys.map(k => `${k}: ${run.parameters[k]}`).join(', ') || 'Performance';
    if (!seriesGroups[seriesLabel]) seriesGroups[seriesLabel] = [];
    
    // Calculate metrics for this point
    const winRate = (run.data.filter(c => c.winner === 'Heroes' || c.winner.includes('Hero')).length / run.data.length) * 100;
    const n = run.data.length;
    const p = winRate / 100;
    const marginOfError = (1.96 * Math.sqrt((p * (1 - p)) / n)) * 100;

    seriesGroups[seriesLabel].push({
      x: run.parameters[variableKey],
      winRate: parseFloat(winRate.toFixed(1)),
      error: parseFloat(marginOfError.toFixed(1))
    });
  });

  // Prepare data for Recharts (merge series into a single array sorted by X)
  const xValues = Array.from(new Set(results.map(r => r.parameters[variableKey]))).sort((a, b) => a - b);
  const chartData = xValues.map(x => {
    const entry = { x };
    Object.keys(seriesGroups).forEach(label => {
      const point = seriesGroups[label].find(p => p.x === x);
      if (point) {
        entry[`${label} Win Rate`] = point.winRate;
        entry[`${label} Error`] = point.error;
      }
    });
    return entry;
  });

  const seriesLabels = Object.keys(seriesGroups);
  const colors = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884d8'];

  return (
    <div style={{ width: '100%', height: 400, marginTop: '2rem', padding: '1rem', background: '#fff', border: '1px solid #ddd', borderRadius: '8px' }}>
      <h3>Parameter Sweep: {variableKey} vs Win Rate</h3>
      <p style={{ fontSize: '0.8rem', color: '#666' }}>* Vertical bars indicate 95% Confidence Interval</p>
      <ResponsiveContainer width="100%" height="100%">
        <LineChart data={chartData} margin={{ top: 20, right: 30, left: 20, bottom: 20 }}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="x" label={{ value: variableKey, position: 'insideBottom', offset: -10 }} />
          <YAxis unit="%" label={{ value: 'Win Rate', angle: -90, position: 'insideLeft' }} domain={[0, 100]} />
          <Tooltip />
          <Legend />
          {seriesLabels.map((label, index) => (
            <Line
              key={label}
              type="monotone"
              dataKey={`${label} Win Rate`}
              name={label}
              stroke={colors[index % colors.length]}
              activeDot={{ r: 8 }}
            >
              <ErrorBar dataKey={`${label} Error`} width={4} strokeWidth={2} stroke={colors[index % colors.length]} />
            </Line>
          ))}
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
};
