import { Injectable } from '@angular/core';
import { MatSnackBar } from '@angular/material/snack-bar';
import { HttpErrorResponse } from '@angular/common/http';
import { ErrorResponse } from '../models/loan.model';

/**
 * Service for handling and displaying errors
 */
@Injectable({
  providedIn: 'root'
})
export class ErrorHandlerService {
  constructor(private snackBar: MatSnackBar) {}

  /**
   * Handle HTTP errors and show user-friendly messages
   */
  handleError(error: HttpErrorResponse): void {
    let message = 'An unexpected error occurred';

    if (error.error instanceof ErrorEvent) {
      // Client-side error
      message = `Error: ${error.error.message}`;
    } else {
      // Server-side error
      const errorResponse = error.error as ErrorResponse;
      
      if (errorResponse?.message) {
        message = errorResponse.message;
      } else if (error.status === 0) {
        message = 'Unable to connect to server. Please check your connection.';
      } else if (error.status === 404) {
        message = 'Resource not found';
      } else if (error.status === 400) {
        message = 'Invalid request. Please check your input.';
      } else if (error.status === 500) {
        message = 'Server error. Please try again later.';
      } else {
        message = `Error ${error.status}: ${error.statusText}`;
      }

      // Handle validation errors
      if (errorResponse?.validationErrors) {
        const validationMessages = Object.entries(errorResponse.validationErrors)
          .map(([field, errors]) => `${field}: ${errors.join(', ')}`)
          .join('\n');
        message = `Validation errors:\n${validationMessages}`;
      }
    }

    this.showError(message);
    console.error('HTTP Error:', error);
  }

  /**
   * Show error message to user
   */
  showError(message: string): void {
    this.snackBar.open(message, 'Close', {
      duration: 5000,
      horizontalPosition: 'end',
      verticalPosition: 'top',
      panelClass: ['error-snackbar']
    });
  }

  /**
   * Show success message to user
   */
  showSuccess(message: string): void {
    this.snackBar.open(message, 'Close', {
      duration: 3000,
      horizontalPosition: 'end',
      verticalPosition: 'top',
      panelClass: ['success-snackbar']
    });
  }

  /**
   * Show info message to user
   */
  showInfo(message: string): void {
    this.snackBar.open(message, 'Close', {
      duration: 3000,
      horizontalPosition: 'end',
      verticalPosition: 'top',
      panelClass: ['info-snackbar']
    });
  }
}
