import React, { useState, useEffect } from 'react';
import { FluidDetails } from './FluidDetails';

export const CharacterBuilder = ({ onSave }) => {
  const [metadata, setMetadata] = useState({ 
    classes: [], 
    subclasses: {}, 
    monsters: [], 
    feats: [],
    fighting_styles: [],
    weapons: [],
    armor: [],
    shields: [],
    ui_schema: { character_fields: [] }
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
    ac: 16,
    hp: 44,
    max_hp: 44,
    feats: [],
    fightingStyle: ''
  });

  const calculateAC = (c) => {
    let base = 10;
    const dexMod = Math.floor((c.abilities.dexterity - 10) / 2);
    
    // Simplified AC Logic for UI preview
    const armorAC = {
      'padded': 11 + dexMod,
      'leather': 11 + dexMod,
      'studded_leather': 12 + dexMod,
      'hide': 12 + Math.min(2, dexMod),
      'chain_shirt': 13 + Math.min(2, dexMod),
      'breastplate': 14 + Math.min(2, dexMod),
      'half_plate': 15 + Math.min(2, dexMod),
      'ring_mail': 14,
      'chain_mail': 16,
      'splint': 17,
      'plate': 18
    };

    base = armorAC[c.armor] || (10 + dexMod);
    if (c.shield) base += 2;
    return base;
  };

  const calculateHP = (c) => {
    const conMod = Math.floor((c.abilities.constitution - 10) / 2);
    const hitDie = ['wizard', 'sorcerer', 'warlock'].includes(c.type) ? 6 : (['fighter', 'paladin', 'ranger'].includes(c.type) ? 10 : 8);
    return hitDie + (c.level - 1) * (hitDie / 2 + 1) + (c.level * conMod);
  };

  useEffect(() => {
    fetch('/api/metadata')
      .then(res => res.json())
      .then(data => {
        if (!data.ui_schema) {
          data.ui_schema = { character_fields: [] };
        }
        setMetadata(data);
      })
      .catch(err => console.error('Failed to load metadata', err));
  }, []);

  // Update AC/HP when dependencies change
  useEffect(() => {
    setChar(prev => ({
      ...prev,
      ac: calculateAC(prev),
      hp: Math.floor(calculateHP(prev)),
      max_hp: Math.floor(calculateHP(prev))
    }));
  }, [char.abilities, char.armor, char.shield, char.level, char.type]);

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

  const handleToggleList = (field, item) => {
    setChar(prev => {
      const list = prev[field] || [];
      const updated = list.includes(item)
        ? list.filter(i => i !== item)
        : [...list, item];
      return { ...prev, [field]: updated };
    });
  };

  const isClass = metadata.classes.includes(char.type);

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
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '2px solid var(--accent, #2e7d32)', paddingBottom: '0.5rem', marginBottom: '1rem' }}>
        <h3 style={{ margin: 0 }}>Advanced Character Builder</h3>
        <div style={{ display: 'flex', gap: '1rem', fontSize: '0.85rem' }}>
          <span>AC: <strong>{char.ac}</strong></span>
          <span>HP: <strong>{char.max_hp}</strong></span>
        </div>
      </div>
      
      {/* BASIC ZONE */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(120px, 1fr))', gap: '1rem', marginBottom: '1rem' }}>
        <FluidDetails 
          schema={metadata.ui_schema}
          metadata={metadata}
          data={char}
          onChange={handleChange}
          zone="basic"
          labelStyle={labelStyle}
        />
      </div>

      {isClass && (
        <>
          {/* STATS ZONE */}
          <div style={sectionStyle}>
            <label style={labelStyle}>Ability Scores</label>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gap: '0.5rem' }}>
              <FluidDetails 
                schema={metadata.ui_schema}
                metadata={metadata}
                data={char}
                onChange={handleChange}
                zone="stats"
                labelStyle={{ ...labelStyle, textAlign: 'center', fontSize: '0.6rem' }}
              />
            </div>
          </div>

          {/* EQUIPMENT ZONE */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(150px, 1fr))', gap: '1rem' }}>
            <FluidDetails 
              schema={metadata.ui_schema}
              metadata={metadata}
              data={char}
              onChange={handleChange}
              zone="equipment"
              sectionStyle={sectionStyle}
              labelStyle={labelStyle}
            />
          </div>

          {/* FEATS ZONE */}
          <FluidDetails 
            schema={metadata.ui_schema}
            metadata={metadata}
            data={char}
            onChange={handleChange}
            onToggleList={handleToggleList}
            zone="feats"
            sectionStyle={sectionStyle}
            labelStyle={labelStyle}
          />
        </>
      )}

      <button onClick={() => onSave(char)} data-testid="save-to-pool-btn" style={{ marginTop: '0.5rem', padding: '12px 20px', background: 'var(--accent, #2e7d32)', color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold', width: '100%', fontSize: '1rem', transition: 'background 0.2s' }}>
        Save to Character Pool
      </button>
    </div>
  );
};
