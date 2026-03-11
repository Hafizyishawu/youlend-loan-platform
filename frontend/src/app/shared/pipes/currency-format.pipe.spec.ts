import { CurrencyFormatPipe } from './currency-format.pipe';

describe('CurrencyFormatPipe', () => {
  let pipe: CurrencyFormatPipe;

  beforeEach(() => {
    pipe = new CurrencyFormatPipe();
  });

  it('should create an instance', () => {
    expect(pipe).toBeTruthy();
  });

  it('should format number as GBP currency', () => {
    expect(pipe.transform(1000)).toBe('£1,000.00');
  });

  it('should format decimal values correctly', () => {
    expect(pipe.transform(1234.56)).toBe('£1,234.56');
  });

  it('should handle zero', () => {
    expect(pipe.transform(0)).toBe('£0.00');
  });

  it('should handle null', () => {
    expect(pipe.transform(null)).toBe('£0.00');
  });

  it('should handle undefined', () => {
    expect(pipe.transform(undefined)).toBe('£0.00');
  });
});