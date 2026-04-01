import React, { useState } from 'react';
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
  const [metric, setMetric] = useState('winRate'); // 'winRate' or 'avgDPR'

  if (!batchResults || !batchResults.results) return null;

  const { results } = batchResults;
  
  const allParamKeys = Object.keys(results[0].parameters || {});
  const variableKey = allParamKeys.find(key => {
    const values = new Set(results.map(r => r.parameters[key]));
    return values.size > 1;
  });

  if (!variableKey) return <div>Parameter Sweep requires at least one variable.</div>;

  const otherKeys = allParamKeys.filter(k => k !== variableKey);
  const seriesGroups = {};

  results.forEach(run => {
    const seriesLabel = otherKeys.map(k => `${k}: ${run.parameters[k]}`).join(', ') || 'Performance';
    if (!seriesGroups[seriesLabel]) seriesGroups[seriesLabel] = [];
    
    // Win Rate Calculation
    const winRate = (run.data.filter(c => c.winner === 'Heroes' || c.winner.includes('Hero')).length / run.data.length) * 100;
    const n = run.data.length;
    const p = winRate / 100;
    const winError = (1.96 * Math.sqrt((p * (1 - p)) / n)) * 100;

    // Avg DPR Calculation (Heroes only)
    let totalDmg = 0;
    let totalRounds = 0;
    run.data.forEach(c => {
      totalRounds += c.rounds.length;
      c.rounds.forEach(r => {
        r.events.forEach(e => {
          if (['attack', 'save'].includes(e.type) && (e.attacker === 'Hero' || e.attacker?.includes('Hero'))) {
            totalDmg += e.damage;
          }
        });
      });
    });
    const avgDPR = totalDmg / totalRounds;

    seriesGroups[seriesLabel].push({
      x: run.parameters[variableKey],
      winRate: parseFloat(winRate.toFixed(1)),
      winError: parseFloat(winError.toFixed(1)),
      avgDPR: parseFloat(avgDPR.toFixed(2)),
      dprError: 0 // Simplification: no DPR error bars for now
    });
  });

  const xValues = Array.from(new Set(results.map(r => r.parameters[variableKey]))).sort((a, b) => a - b);
  const chartData = xValues.map(x => {
    const entry = { x };
    Object.keys(seriesGroups).forEach(label => {
      const point = seriesGroups[label].find(p => p.x === x);
      if (point) {
        entry[`${label} Value`] = metric === 'winRate' ? point.winRate : point.avgDPR;
        entry[`${label} Error`] = metric === 'winRate' ? point.winError : 0;
      }
    });
    return entry;
  });

  const seriesLabels = Object.keys(seriesGroups);
  const colors = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884d8'];

  return (
    <div style={{ width: '100%', height: 450, marginTop: '2rem', padding: '1.5rem', background: '#fff', border: '1px solid #ddd', borderRadius: '8px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
        <h3 style={{ margin: 0 }}>Sweep Analysis: {variableKey}</h3>
        <div style={{ display: 'flex', gap: '0.5rem', background: '#eee', padding: '4px', borderRadius: '6px' }}>
          <button 
            onClick={() => setMetric('winRate')} 
            style={{ padding: '4px 12px', border: 'none', borderRadius: '4px', background: metric === 'winRate' ? '#fff' : 'none', cursor: 'pointer' }}
          >Win Rate</button>
          <button 
            onClick={() => setMetric('avgDPR')} 
            style={{ padding: '4px 12px', border: 'none', borderRadius: '4px', background: metric === 'avgDPR' ? '#fff' : 'none', cursor: 'pointer' }}
          >Hero Avg DPR</button>
        </div>
      </div>
      
      <p style={{ fontSize: '0.8rem', color: '#666' }}>
        * Vertical bars indicate 95% Confidence Interval (Win Rate only)
      </p>
      
      <ResponsiveContainer width="100%" height="80%">
        <LineChart data={chartData} margin={{ top: 20, right: 30, left: 20, bottom: 20 }}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="x" label={{ value: variableKey, position: 'insideBottom', offset: -10 }} />
          <YAxis 
            unit={metric === 'winRate' ? '%' : ''} 
            label={{ value: metric === 'winRate' ? 'Win Rate' : 'Avg DPR', angle: -90, position: 'insideLeft' }} 
            domain={metric === 'winRate' ? [0, 100] : ['auto', 'auto']} 
          />
          <Tooltip />
          <Legend />
          {seriesLabels.map((label, index) => (
            <Line
              key={label}
              type="monotone"
              dataKey={`${label} Value`}
              name={label}
              stroke={colors[index % colors.length]}
              activeDot={{ r: 8 }}
            >
              {metric === 'winRate' && (
                <ErrorBar dataKey={`${label} Error`} width={4} strokeWidth={2} stroke={colors[index % colors.length]} />
              )}
            </Line>
          ))}
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
};
