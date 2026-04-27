import React from 'react';

export const HeroEfficiency = ({ data }) => {
  if (!data || data.length === 0) return null;

  const totalSims = data.length;
  let totalRounds = 0;
  let totalHeroDamage = 0;
  let totalEnemiesKilled = 0;
  let totalHeroHPRemaining = 0;

  data.forEach(sim => {
    totalRounds += sim.rounds.length;
    
    // Damage Dealt by Hero
    sim.rounds.forEach(round => {
      round.events.forEach(event => {
        if (event.type === 'attack' && event.attacker.toLowerCase().includes('hero')) {
          totalHeroDamage += (event.damage || 0);
        }
      });
    });

    // Enemies Killed (Combatants that are not heroes and have 0 HP)
    const enemies = sim.combatants.filter(c => !c.name.toLowerCase().includes('hero'));
    const killed = enemies.filter(e => e.hit_points <= 0).length;
    totalEnemiesKilled += killed;

    // Hero Health
    const hero = sim.combatants.find(c => c.name.toLowerCase().includes('hero'));
    if (hero) {
      totalHeroHPRemaining += (hero.hit_points / hero.max_hp);
    }
  });

  const avgRounds = (totalRounds / totalSims).toFixed(1);
  const avgDamage = (totalHeroDamage / totalSims).toFixed(1);
  const avgKills = (totalEnemiesKilled / totalSims).toFixed(1);
  const avgSurvivalHealth = (totalHeroHPRemaining / totalSims * 100).toFixed(1);

  return (
    <div style={{ padding: '1.5rem', background: '#f0f4f8', borderRadius: '12px', border: '1px solid #d1d9e6' }}>
      <h3 style={{ marginTop: 0, color: '#2c3e50', borderBottom: '2px solid #d1d9e6', paddingBottom: '0.5rem' }}>Hero Efficiency Score</h3>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem', marginTop: '1rem' }}>
        <div className="stat-card" style={{ background: '#fff', padding: '1rem', borderRadius: '8px', boxShadow: '0 2px 4px rgba(0,0,0,0.05)' }}>
          <div style={{ fontSize: '0.8rem', color: '#7f8c8d', textTransform: 'uppercase', fontWeight: 'bold' }}>Avg Rounds Survived</div>
          <div style={{ fontSize: '1.5rem', fontWeight: 'bold', color: '#2980b9' }}>{avgRounds}</div>
        </div>
        <div className="stat-card" style={{ background: '#fff', padding: '1rem', borderRadius: '8px', boxShadow: '0 2px 4px rgba(0,0,0,0.05)' }}>
          <div style={{ fontSize: '0.8rem', color: '#7f8c8d', textTransform: 'uppercase', fontWeight: 'bold' }}>Avg Damage Dealt</div>
          <div style={{ fontSize: '1.5rem', fontWeight: 'bold', color: '#c0392b' }}>{avgDamage}</div>
        </div>
        <div className="stat-card" style={{ background: '#fff', padding: '1rem', borderRadius: '8px', boxShadow: '0 2px 4px rgba(0,0,0,0.05)' }}>
          <div style={{ fontSize: '0.8rem', color: '#7f8c8d', textTransform: 'uppercase', fontWeight: 'bold' }}>Avg Enemies Defeated</div>
          <div style={{ fontSize: '1.5rem', fontWeight: 'bold', color: '#27ae60' }}>{avgKills}</div>
        </div>
        <div className="stat-card" style={{ background: '#fff', padding: '1rem', borderRadius: '8px', boxShadow: '0 2px 4px rgba(0,0,0,0.05)' }}>
          <div style={{ fontSize: '0.8rem', color: '#7f8c8d', textTransform: 'uppercase', fontWeight: 'bold' }}>Avg Health Remaining</div>
          <div style={{ fontSize: '1.5rem', fontWeight: 'bold', color: '#f39c12' }}>{avgSurvivalHealth}%</div>
        </div>
      </div>
    </div>
  );
};
