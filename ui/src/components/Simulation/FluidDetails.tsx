import React from 'react';

interface Field {
  name: string;
  label: string;
  type: 'select' | 'checkbox' | 'number' | 'text' | 'multi-checkbox';
  zone: string;
  options_key?: string;
  dynamic_options?: boolean;
  grouped_options?: boolean;
  path?: string;
  min?: number;
  max?: number;
  visible_if?: {
    field: string;
    in?: string[];
    not_in?: string[];
    is?: any;
  };
}

interface FluidDetailsProps {
  schema: { character_fields: Field[] };
  metadata: any;
  data: any;
  onChange: (e: any) => void;
  onToggleList?: (field: string, item: string) => void;
  zone?: string;
  testIdPrefix?: string;
  sectionStyle?: React.CSSProperties;
  labelStyle?: React.CSSProperties;
}

export const FluidDetails: React.FC<FluidDetailsProps> = ({ 
  schema, metadata, data, onChange, onToggleList, zone, testIdPrefix = 'char-builder', sectionStyle, labelStyle 
}) => {
  const isFieldVisible = (field: Field) => {
    if (!field.visible_if) return true;
    const { field: targetField, in: inValues, not_in: notInValues, is: isValue } = field.visible_if;
    
    let actualValue;
    if (targetField === 'not_monster') {
      actualValue = !metadata.monsters?.includes(data.type);
    } else {
      actualValue = data[targetField];
    }

    if (inValues) return inValues.includes(actualValue);
    if (notInValues) return !notInValues.includes(actualValue);
    if (isValue !== undefined) return actualValue === isValue;
    return true;
  };

  const getValue = (field: Field) => {
    if (field.path) {
      const parts = field.path.split('.');
      let val = data;
      for (const p of parts) {
        val = val ? val[p] : undefined;
      }
      return val;
    }
    return data[field.name];
  };

  const handleChange = (field: Field, e: React.ChangeEvent<any>) => {
    const { value, type, checked } = e.target;
    let finalValue: any = type === 'checkbox' ? checked : value;
    if (field.type === 'number') finalValue = parseInt(value);

    const name = field.path ? `ability.${field.path.split('.')[1]}` : field.name;
    
    onChange({
      target: {
        name,
        value: finalValue,
        type,
        checked
      }
    });
  };

  const renderSelect = (field: Field, value: any) => {
    if (field.grouped_options) {
      const groups = metadata[field.options_key!] || { classes: [], monsters: [] };
      return (
        <select 
          name={field.name} 
          value={value} 
          onChange={(e) => handleChange(field, e)} 
          data-testid={`${testIdPrefix}-${field.name}`}
          style={{ width: '100%', padding: '0.4rem' }}
        >
          <optgroup label="Classes">
            {groups.classes.map((cls: string) => (
              <option key={cls} value={cls}>{cls.toUpperCase()}</option>
            ))}
          </optgroup>
          <optgroup label="Monsters">
            {groups.monsters.map((m: string) => (
              <option key={m} value={m}>{m.toUpperCase()}</option>
            ))}
          </optgroup>
        </select>
      );
    }

    let options = [];
    if (field.dynamic_options) {
      options = metadata[field.options_key!]?.[data.type] || [];
    } else {
      options = metadata[field.options_key!] || [];
    }

    return (
      <select 
        name={field.name} 
        value={value} 
        onChange={(e) => handleChange(field, e)} 
        data-testid={`${testIdPrefix}-${field.name}`}
        style={{ width: '100%', padding: '0.4rem' }}
      >
        <option value="">{field.name === 'subclass' ? 'Standard' : 'None'}</option>
        {options.map((opt: string) => (
          <option key={opt} value={opt}>{opt.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}</option>
        ))}
      </select>
    );
  };

  const renderMultiCheckbox = (field: Field, value: any) => {
    const options = metadata[field.options_key!] || [];
    const selected = Array.isArray(value) ? value : [];
    
    return (
      <div key={field.name} style={sectionStyle}>
        <label style={labelStyle}>{field.label}</label>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(180px, 1fr))', gap: '0.5rem' }}>
          {options.map((opt: string) => (
            <label key={opt} style={{ fontSize: '0.75rem', display: 'flex', alignItems: 'center', gap: '0.4rem', cursor: 'pointer', padding: '0.2rem', borderRadius: '2px', border: selected.includes(opt) ? '1px solid var(--accent)' : '1px solid transparent' }}>
              <input 
                type="checkbox" 
                checked={selected.includes(opt)} 
                onChange={() => onToggleList && onToggleList(field.name, opt)} 
              />
              {opt.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}
            </label>
          ))}
        </div>
      </div>
    );
  };

  const renderField = (field: Field) => {
    if (zone && field.zone !== zone) return null;
    if (!isFieldVisible(field)) return null;

    const value = getValue(field) || '';

    if (field.type === 'select') {
      return (
        <div key={field.name} style={sectionStyle}>
          <label style={labelStyle}>{field.label}</label>
          {renderSelect(field, value)}
        </div>
      );
    }

    if (field.type === 'checkbox') {
      return (
        <div key={field.name} style={{ ...sectionStyle, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer', fontSize: '0.85rem' }}>
            <input 
              type="checkbox" 
              name={field.name} 
              checked={!!value} 
              onChange={(e) => handleChange(field, e)} 
              data-testid={`${testIdPrefix}-${field.name}`}
            />
            {field.label}
          </label>
        </div>
      );
    }

    if (field.type === 'number' || field.type === 'text') {
      return (
        <div key={field.name} style={sectionStyle}>
          <label style={labelStyle}>{field.label}</label>
          <input 
            type={field.type}
            name={field.name}
            value={value}
            min={field.min}
            max={field.max}
            onChange={(e) => handleChange(field, e)}
            data-testid={`${testIdPrefix}-${field.name}`}
            style={{ width: '100%', padding: '0.4rem' }}
          />
        </div>
      );
    }

    if (field.type === 'multi-checkbox') {
      return renderMultiCheckbox(field, value);
    }

    return null;
  };

  return (
    <>
      {schema.character_fields.map(renderField)}
    </>
  );
};
