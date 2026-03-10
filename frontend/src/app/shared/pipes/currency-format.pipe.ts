import { Pipe, PipeTransform } from '@angular/core';

/**
 * Custom pipe for formatting currency values
 */
@Pipe({
  name: 'currencyFormat',
  standalone: true
})
export class CurrencyFormatPipe implements PipeTransform {
  transform(value: number | null | undefined): string {
    if (value == null) {
      return '£0.00';
    }

    return new Intl.NumberFormat('en-GB', {
      style: 'currency',
      currency: 'GBP'
    }).format(value);
  }
}
