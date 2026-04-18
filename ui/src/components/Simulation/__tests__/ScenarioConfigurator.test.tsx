import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { ScenarioConfigurator } from '../ScenarioConfigurator';

describe('ScenarioConfigurator', () => {
  it('renders the configurator title', () => {
    render(<ScenarioConfigurator onRun={vi.fn()} />);
    expect(screen.getByText('Scientific Lab Runner')).toBeInTheDocument();
  });

  it('adds a variable correctly', () => {
    render(<ScenarioConfigurator onRun={vi.fn()} />);
    
    const nameInput = screen.getByPlaceholderText('Var Name (e.g. count)');
    const valInput = screen.getByPlaceholderText('Values (e.g. [1,2,4])');
    const addBtn = screen.getByText('Add Variable');

    fireEvent.change(nameInput, { target: { value: 'enemy_count' } });
    fireEvent.change(valInput, { target: { value: '[1, 2, 3]' } });
    fireEvent.click(addBtn);

    expect(screen.getByText('enemy_count')).toBeInTheDocument();
    expect(screen.getByText('[1,2,3]')).toBeInTheDocument();
  });

  it('fails to add invalid JSON variable', () => {
    const alertMock = vi.spyOn(window, 'alert').mockImplementation(() => {});
    render(<ScenarioConfigurator onRun={vi.fn()} />);
    
    const nameInput = screen.getByPlaceholderText('Var Name (e.g. count)');
    const valInput = screen.getByPlaceholderText('Values (e.g. [1,2,4])');
    const addBtn = screen.getByText('Add Variable');

    fireEvent.change(nameInput, { target: { value: 'bad_var' } });
    fireEvent.change(valInput, { target: { value: 'not-json' } });
    fireEvent.click(addBtn);

    expect(alertMock).toHaveBeenCalledWith('Values must be a valid JSON array, e.g. [1, 2, 4]');
    alertMock.mockRestore();
  });
});
