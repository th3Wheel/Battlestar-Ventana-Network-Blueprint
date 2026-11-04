import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { parseDateRange } from '../.agents/skills/pr-dashboard/scripts/lib/utils.mjs';

describe('parseDateRange', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date(2026, 10, 2, 12));
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it.each([
    ['feb 2006', { start: '2006-02-01', end: '2006-02-28', label: 'Feb 2006' }],
    ['February 2031', { start: '2031-02-01', end: '2031-02-28', label: 'February 2031' }],
    ['sept 2024', { start: '2024-09-01', end: '2024-09-30', label: 'Sept 2024' }],
    ['may 2030', { start: '2030-05-01', end: '2030-05-31', label: 'May 2030' }],
  ])('reads a month and year from %j', (text, expected) => {
    expect(parseDateRange(text)).toEqual(expected);
  });

  it.each([
    ['feb', { start: '2026-02-01', end: '2026-02-28', label: 'Feb 2026' }],
    ['SEPTEMBER', { start: '2026-09-01', end: '2026-09-30', label: 'September 2026' }],
    ['december', { start: '2026-12-01', end: '2026-12-31', label: 'December 2026' }],
  ])('assumes the current year for a bare month %j', (text, expected) => {
    expect(parseDateRange(text)).toEqual(expected);
  });

  it('keeps the other phrases working', () => {
    expect(parseDateRange('last month')).toEqual({ start: '2026-10-01', end: '2026-10-31', label: 'Last month' });
    expect(parseDateRange('next month')).toEqual({ start: '2026-12-01', end: '2026-12-31', label: 'Next month' });
    expect(parseDateRange('last 3 days')).toEqual({ start: '2026-10-31', end: '2026-11-02', label: 'Last 3 days' });
  });

  it('falls back to the last 7 days', () => {
    expect(parseDateRange('nonsense')).toEqual({ start: '2026-10-27', end: '2026-11-02', label: 'Last 7 days' });
  });
});
