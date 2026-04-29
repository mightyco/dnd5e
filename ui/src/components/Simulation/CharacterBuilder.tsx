import React, { useState, useEffect } from 'react';

export const CharacterBuilder = ({ onSave }) => {
  const [metadata, setMetadata] = useState({ classes: [], subclasses: {}, monsters: [] });
  const [char, setChar] = useState({
    name: 'New Hero',
    type: 'fighter',
    level: 1,
    subclass: ''
  });

  useEffect(() => {
    fetch('/api/metadata')
      .then(res => res.json())
      .then(data => setMetadata(data))
      .catch(err => console.error('Failed to load metadata', err));
  }, []);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setChar(prev => {
      const updated = { ...prev, [name]: name === 'level' ? parseInt(value) : value };
      if (name === 'type') {
        const subclasses = metadata.subclasses[value] || [];
        updated.subclass = subclasses.length > 0 ? subclasses[0] : '';
      }
      return updated;
    });
  };

  const isClass = metadata.classes.includes(char.type);
  const subclasses = metadata.subclasses[char.type] || [];

  return (
    <div style={{ padding: '1.5rem', border: '1px solid #ddd', borderRadius: '8px', background: '#fff', marginBottom: '1rem' }}>
      <h3 style={{ marginTop: 0 }}>Character Builder</h3>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
        <div>
          <label style={{ fontSize: '0.85rem', fontWeight: 'bold' }}>Name: </label>
          <input type="text" name="name" value={char.name} onChange={handleChange} style={{ width: '100%', padding: '0.4rem' }} />
        </div>
        <div>
          <label style={{ fontSize: '0.85rem', fontWeight: 'bold' }}>Type: </label>
          <select name="type" value={char.type} onChange={handleChange} style={{ width: '100%', padding: '0.4rem' }}>
            <optgroup label="Classes">
              {metadata.classes.map(cls => (
                <option key={cls} value={cls}>{cls.charAt(0).toUpperCase() + cls.slice(1)}</option>
              ))}
            </optgroup>
            <optgroup label="Monsters">
              {metadata.monsters.map(m => (
                <option key={m} value={m}>{m.charAt(0).toUpperCase() + m.slice(1)}</option>
              ))}
            </optgroup>
          </select>
        </div>
        <div>
          <label style={{ fontSize: '0.85rem', fontWeight: 'bold' }}>Level: </label>
          <input type="number" name="level" value={char.level} onChange={handleChange} min="1" max="20" style={{ width: '100%', padding: '0.4rem' }} />
        </div>
        {isClass && subclasses.length > 0 && (
          <div>
            <label style={{ fontSize: '0.85rem', fontWeight: 'bold' }}>Subclass: </label>
            <select name="subclass" value={char.subclass} onChange={handleChange} style={{ width: '100%', padding: '0.4rem' }}>
              <option value="">Standard</option>
              {subclasses.map(sc => (
                <option key={sc} value={sc}>{sc.charAt(0).toUpperCase() + sc.slice(1)}</option>
              ))}
            </select>
          </div>
        )}
      </div>
      <button 
        onClick={() => onSave(char)}
        style={{ 
          marginTop: '1.5rem',
          padding: '8px 20px', 
          background: 'var(--accent, #2e7d32)', 
          color: '#fff', 
          border: 'none', 
          borderRadius: '4px',
          cursor: 'pointer',
          fontWeight: 'bold',
          width: '100%'
        }}
      >
        Add to Character Pool
      </button>
    </div>
  );
};

