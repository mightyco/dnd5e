import '@testing-library/jest-dom/vitest';
import { vi } from 'vitest';

// Mock ResizeObserver as a class, which is what Recharts expects
global.ResizeObserver = class ResizeObserver {
    observe() {}
    unobserve() {}
    disconnect() {}
};
