import React, { useState } from 'react';

export const CharacterBuilder = ({ onSave }) => {
  const [char, setChar] = useState({
    name: 'New Hero',
    type: 'fighter',
    level: 1,
    subclass: ''
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setChar(prev => ({ ...prev, [name]: name === 'level' ? parseInt(value) : value }));
  };

  return (
    <div style={{ padding: '1.5rem', border: '1px solid #ddd', borderRadius: '8px', background: '#fff', marginBottom: '1rem' }}>
      <h3>Character Builder</h3>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
        <div>
          <label>Name: </label>
          <input type="text" name="name" value={char.name} onChange={handleChange} style={{ width: '100%' }} />
        </div>
        <div>
          <label>Class / Monster: </label>
          <select name="type" value={char.type} onChange={handleChange} style={{ width: '100%' }}>
            <optgroup label="Classes">
              <option value="fighter">Fighter</option>
              <option value="wizard">Wizard</option>
            </optgroup>
            <optgroup label="Monsters">
              <option value="goblin">Goblin (CR 1/4)</option>
              <option value="bugbear">Bugbear (CR 1)</option>
              <option value="ogre">Ogre (CR 2)</option>
            </optgroup>
          </select>
        </div>
        <div>
          <label>Level: </label>
          <input type="number" name="level" value={char.level} onChange={handleChange} min="1" max="20" style={{ width: '100%' }} />
        </div>
        {char.type === 'fighter' && (
          <div>
            <label>Subclass: </label>
            <select name="subclass" value={char.subclass} onChange={handleChange} style={{ width: '100%' }}>
              <option value="">Standard</option>
              <option value="champion">Champion</option>
              <option value="battlemaster">Battlemaster</option>
            </select>
          </div>
        )}
      </div>
      <button 
        onClick={() => onSave(char)}
        style={{ 
          marginTop: '1rem',
          padding: '6px 16px', 
          background: '#2e7d32', 
          color: '#fff', 
          border: 'none', 
          borderRadius: '4px',
          cursor: 'pointer'
        }}
      >
        Add to Pool
      </button>
    </div>
  );
};
