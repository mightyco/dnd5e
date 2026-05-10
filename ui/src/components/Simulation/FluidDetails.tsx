import React from 'react';

interface Field {
  name: string;
  label: string;
  type: 'select' | 'checkbox' | 'number' | 'text';
  options_key?: string;
  visible_if?: {
    field: string;
    in?: string[];
    not_in?: string[];
  };
}

interface FluidDetailsProps {
  schema: { character_fields: Field[] };
  metadata: any;
  data: any;
  onChange: (e: any) => void;
  sectionStyle?: React.CSSProperties;
  labelStyle?: React.CSSProperties;
}

export const FluidDetails: React.FC<FluidDetailsProps> = ({ 
  schema, metadata, data, onChange, sectionStyle, labelStyle 
}) => {
  const isFieldVisible = (field: Field) => {
    if (!field.visible_if) return true;
    const { field: targetField, in: inValues, not_in: notInValues } = field.visible_if;
    const actualValue = data[targetField];
    if (inValues) return inValues.includes(actualValue);
    if (notInValues) return !notInValues.includes(actualValue);
    return true;
  };

  const renderField = (field: Field) => {
    if (!isFieldVisible(field)) return null;

    if (field.type === 'select') {
      const options = metadata[field.options_key!] || [];
      return (
        <div key={field.name} style={sectionStyle}>
          <label style={labelStyle}>{field.label}</label>
          <select 
            name={field.name} 
            value={data[field.name] || ''} 
            onChange={onChange} 
            data-testid={`char-builder-${field.name}`}
            style={{ width: '100%', padding: '0.4rem' }}
          >
            <option value="">None</option>
            {options.map((opt: string) => (
              <option key={opt} value={opt}>{opt.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}</option>
            ))}
          </select>
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
              checked={!!data[field.name]} 
              onChange={onChange} 
              data-testid={`char-builder-${field.name}`}
            />
            {field.label}
          </label>
        </div>
      );
    }

    return null;
  };

  return (
    <>
      {schema.character_fields.map(renderField)}
    </>
  );
};
