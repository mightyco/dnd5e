import React from 'react';

export const OutcomeLabel = ({ combat }) => {
  const rounds = combat.rounds.length;
  const winner = combat.winner;
  const winnerHP = combat.rounds[rounds - 1].events
    .filter(e => e.combatant === winner || e.attacker === winner)
    .reduce((acc, e) => e.metadata?.current_hp || acc, 0); // This is crude, need better HP tracking in results
  
  // Actually, we can check the last event's target_hp for the loser to be 0, 
  // and the winners should have some HP left.
  
  let label = 'Close';
  let color = '#ffa000';

  if (rounds < 4) {
    label = 'Stomp';
    color = '#2e7d32';
  } else if (rounds > 10) {
    label = 'Slog';
    color = '#d32f2f';
  }

  return (
    <span style={{ 
      fontSize: '0.7rem', 
      padding: '2px 6px', 
      background: color, 
      color: '#fff', 
      borderRadius: '4px',
      marginLeft: '0.5rem'
    }}>
      {label}
    </span>
  );
};

export const DeltaAnalysis = ({ datasets }) => {
  if (datasets.length < 2) return null;

  const runA = datasets[0];
  const runB = datasets[1];

  const getAvgDPR = (run) => {
    let totalDmg = 0;
    let totalRounds = 0;
    run.forEach(c => {
      totalRounds += c.rounds.length;
      c.rounds.forEach(r => {
        r.events.forEach(e => {
          if (['attack', 'save'].includes(e.type)) totalDmg += e.damage;
        });
      });
    });
    return totalDmg / totalRounds;
  };

  const getWinRate = (run) => {
    const wins = run.filter(c => c.winner === run[0].winner).length;
    return (wins / run.length) * 100;
  };

  const dprA = getAvgDPR(runA);
  const dprB = getAvgDPR(runB);
  const winA = getWinRate(runA);
  const winB = getWinRate(runB);

  const deltaDPR = ((dprB / dprA - 1) * 100).toFixed(1);
  const deltaWin = (winB - winA).toFixed(1);

  return (
    <div style={{ marginTop: '2rem', padding: '1rem', border: '1px solid #ddd', borderRadius: '8px', background: '#fff' }}>
      <h3>Delta Analysis (Comparative)</h3>
      <table style={{ width: '100%', borderCollapse: 'collapse' }}>
        <thead>
          <tr style={{ textAlign: 'left', borderBottom: '2px solid #eee' }}>
            <th style={{ padding: '0.5rem' }}>Metric</th>
            <th style={{ padding: '0.5rem' }}>Run 1</th>
            <th style={{ padding: '0.5rem' }}>Run 2</th>
            <th style={{ padding: '0.5rem' }}>Delta</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td style={{ padding: '0.5rem' }}>Avg DPR</td>
            <td style={{ padding: '0.5rem' }}>{dprA.toFixed(1)}</td>
            <td style={{ padding: '0.5rem' }}>{dprB.toFixed(1)}</td>
            <td style={{ padding: '0.5rem', color: parseFloat(deltaDPR) >= 0 ? '#2e7d32' : '#d32f2f' }}>
              {parseFloat(deltaDPR) >= 0 ? '+' : ''}{deltaDPR}%
            </td>
          </tr>
          <tr>
            <td style={{ padding: '0.5rem' }}>Win Rate (%)</td>
            <td style={{ padding: '0.5rem' }}>{winA.toFixed(1)}%</td>
            <td style={{ padding: '0.5rem' }}>{winB.toFixed(1)}%</td>
            <td style={{ padding: '0.5rem', color: parseFloat(deltaWin) >= 0 ? '#2e7d32' : '#d32f2f' }}>
              {parseFloat(deltaWin) >= 0 ? '+' : ''}{deltaWin}%
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  );
};
