import React, { useState, useEffect } from 'react';

export const CharacterBuilder = ({ onSave }) => {
  const [metadata, setMetadata] = useState({ 
    classes: [], 
    subclasses: {}, 
    monsters: [], 
    feats: [],
    fighting_styles: [],
    weapons: [],
    armor: [],
    shields: []
  });

  const [char, setChar] = useState({
    name: 'New Hero',
    type: 'fighter',
    level: 5,
    subclass: '',
    abilities: {
      strength: 18,
      dexterity: 14,
      constitution: 14,
      intelligence: 10,
      wisdom: 10,
      charisma: 10
    },
    weapon: 'longsword',
    armor: 'breastplate',
    shield: false,
    feats: [],
    fightingStyle: ''
  });

  useEffect(() => {
    fetch('/api/metadata')
      .then(res => res.json())
      .then(data => setMetadata(data))
      .catch(err => console.error('Failed to load metadata', err));
  }, []);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    
    if (name.startsWith('ability.')) {
      const ability = name.split('.')[1];
      setChar(prev => ({
        ...prev,
        abilities: { ...prev.abilities, [ability]: parseInt(value) }
      }));
      return;
    }

    setChar(prev => {
      const updated = { 
        ...prev, 
        [name]: type === 'checkbox' ? checked : (name === 'level' ? parseInt(value) : value) 
      };
      
      if (name === 'type') {
        const scs = metadata.subclasses[value] || [];
        updated.subclass = scs.length > 0 ? scs[0] : '';
        
        // Auto-optimize stats based on class
        const newAbilities = { ...prev.abilities };
        if (['wizard', 'warlock', 'sorcerer'].includes(value)) {
          newAbilities.intelligence = 18;
          newAbilities.strength = 10;
        } else if (['rogue', 'monk', 'ranger'].includes(value)) {
          newAbilities.dexterity = 18;
          newAbilities.strength = 10;
        } else {
          newAbilities.strength = 18;
          newAbilities.dexterity = 14;
        }
        updated.abilities = newAbilities;
      }
      return updated;
    });
  };

  const handleFeatToggle = (feat) => {
    setChar(prev => {
      const feats = prev.feats || [];
      const updatedFeats = feats.includes(feat)
        ? feats.filter(f => f !== feat)
        : [...feats, feat];
      return { ...prev, feats: updatedFeats };
    });
  };

  const isClass = metadata.classes.includes(char.type);
  const subclasses = metadata.subclasses[char.type] || [];
  const selectedFeats = char.feats || [];

  const sectionStyle: React.CSSProperties = {
    padding: '1rem',
    border: '1px solid #eee',
    borderRadius: '4px',
    background: '#fafafa',
    marginBottom: '1rem'
  };

  const labelStyle: React.CSSProperties = {
    fontSize: '0.75rem',
    fontWeight: 'bold',
    display: 'block',
    marginBottom: '0.3rem',
    color: '#666'
  };

  return (
    <div style={{ padding: '1.5rem', border: '1px solid #ddd', borderRadius: '8px', background: '#fff', marginBottom: '1rem', boxShadow: '0 4px 6px rgba(0,0,0,0.05)' }}>
      <h3 style={{ marginTop: 0, borderBottom: '2px solid var(--accent, #2e7d32)', paddingBottom: '0.5rem' }}>Advanced Character Builder</h3>
      
      {/* Basic Info */}
      <div style={{ display: 'grid', gridTemplateColumns: '2fr 2fr 1fr', gap: '1rem', marginBottom: '1rem' }}>
        <div>
          <label style={labelStyle}>Name</label>
          <input type="text" name="name" value={char.name} onChange={handleChange} style={{ width: '100%', padding: '0.5rem' }} />
        </div>
        <div>
          <label style={labelStyle}>Class / Monster</label>
          <select name="type" value={char.type} onChange={handleChange} style={{ width: '100%', padding: '0.5rem' }}>
            <optgroup label="Classes">
              {metadata.classes.map(cls => (
                <option key={cls} value={cls}>{cls.toUpperCase()}</option>
              ))}
            </optgroup>
            <optgroup label="Monsters">
              {metadata.monsters.map(m => (
                <option key={m} value={m}>{m.toUpperCase()}</option>
              ))}
            </optgroup>
          </select>
        </div>
        <div>
          <label style={labelStyle}>Level</label>
          <input type="number" name="level" value={char.level} onChange={handleChange} min="1" max="20" style={{ width: '100%', padding: '0.5rem' }} />
        </div>
      </div>

      {isClass && (
        <>
          {/* Subclass & Abilities */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 2fr', gap: '1rem' }}>
            <div style={sectionStyle}>
              <label style={labelStyle}>Subclass</label>
              <select name="subclass" value={char.subclass} onChange={handleChange} style={{ width: '100%', padding: '0.4rem' }}>
                <option value="">None (Standard)</option>
                {subclasses.map(sc => (
                  <option key={sc} value={sc}>{sc.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}</option>
                ))}
              </select>
            </div>

            {['fighter', 'paladin', 'ranger'].includes(char.type) && (
              <div style={sectionStyle}>
                <label style={labelStyle}>Fighting Style</label>
                <select name="fightingStyle" value={char.fightingStyle} onChange={handleChange} style={{ width: '100%', padding: '0.4rem' }}>
                  <option value="">None</option>
                  {(metadata.fighting_styles || []).map(fs => (
                    <option key={fs} value={fs}>{fs.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}</option>
                  ))}
                </select>
              </div>
            )}
            
            <div style={sectionStyle}>
              <label style={labelStyle}>Ability Scores</label>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gap: '0.5rem' }}>
                {Object.keys(char.abilities).map(ability => (
                  <div key={ability}>
                    <label style={{ ...labelStyle, textAlign: 'center', fontSize: '0.6rem' }}>{ability.slice(0, 3).toUpperCase()}</label>
                    <input 
                      type="number" 
                      name={`ability.${ability}`} 
                      value={char.abilities[ability]} 
                      onChange={handleChange} 
                      style={{ width: '100%', textAlign: 'center', padding: '0.2rem' }} 
                    />
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Equipment */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '1rem' }}>
            <div style={sectionStyle}>
              <label style={labelStyle}>Weapon</label>
              <select name="weapon" value={char.weapon} onChange={handleChange} style={{ width: '100%', padding: '0.4rem' }}>
                {metadata.weapons.map(w => (
                  <option key={w} value={w}>{w.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ')}</option>
                ))}
              </select>
            </div>
            <div style={sectionStyle}>
              <label style={labelStyle}>Armor</label>
              <select name="armor" value={char.armor} onChange={handleChange} style={{ width: '100%', padding: '0.4rem' }}>
                <option value="">Unarmored</option>
                {metadata.armor.map(a => (
                  <option key={a} value={a}>{a.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ')}</option>
                ))}
              </select>
            </div>
            <div style={{ ...sectionStyle, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer', fontSize: '0.85rem' }}>
                <input type="checkbox" name="shield" checked={char.shield} onChange={handleChange} />
                Equip Shield (+2 AC)
              </label>
            </div>
          </div>

          {/* Feats */}
          <div style={sectionStyle}>
            <label style={labelStyle}>Feats (2024)</label>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(180px, 1fr))', gap: '0.5rem' }}>
              {metadata.feats.map(feat => (
                <label key={feat} style={{ fontSize: '0.75rem', display: 'flex', alignItems: 'center', gap: '0.4rem', cursor: 'pointer', padding: '0.2rem', borderRadius: '2px', border: selectedFeats.includes(feat) ? '1px solid var(--accent)' : '1px solid transparent' }}>
                  <input type="checkbox" checked={selectedFeats.includes(feat)} onChange={() => handleFeatToggle(feat)} />
                  {feat.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}
                </label>
              ))}
            </div>
          </div>
        </>
      )}

      <button 
        onClick={() => onSave(char)}
        style={{ 
          marginTop: '0.5rem',
          padding: '12px 20px', 
          background: 'var(--accent, #2e7d32)', 
          color: '#fff', 
          border: 'none', 
          borderRadius: '4px',
          cursor: 'pointer',
          fontWeight: 'bold',
          width: '100%',
          fontSize: '1rem',
          transition: 'background 0.2s'
        }}
      >
        Save to Character Pool
      </button>
    </div>
  );
};
