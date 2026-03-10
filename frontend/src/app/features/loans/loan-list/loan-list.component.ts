import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatCardModule } from '@angular/material/card';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { LoanService } from '../../../core/services/loan.service';
import { ErrorHandlerService } from '../../../core/services/error-handler.service';
import { Loan } from '../../../core/models/loan.model';
import { CurrencyFormatPipe } from '../../../shared/pipes/currency-format.pipe';
import { ConfirmDialogComponent } from '../../../shared/components/confirm-dialog/confirm-dialog.component';

/**
 * Loan list component - displays all loans in a table
 */
@Component({
  selector: 'app-loan-list',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    FormsModule,
    MatTableModule,
    MatButtonModule,
    MatIconModule,
    MatFormFieldModule,
    MatInputModule,
    MatCardModule,
    MatDialogModule,
    CurrencyFormatPipe
  ],
  templateUrl: './loan-list.component.html',
  styleUrls: ['./loan-list.component.scss']
})
export class LoanListComponent implements OnInit {
  loans: Loan[] = [];
  filteredLoans: Loan[] = [];
  searchTerm = '';
  displayedColumns: string[] = ['borrowerName', 'fundingAmount', 'repaymentAmount', 'createdAt', 'actions'];

  constructor(
    private loanService: LoanService,
    private errorHandler: ErrorHandlerService,
    private dialog: MatDialog
  ) {}

  ngOnInit(): void {
    this.loadLoans();
  }

  /**
   * Load all loans from API
   */
  loadLoans(): void {
    this.loanService.getAllLoans().subscribe({
      next: (loans) => {
        this.loans = loans;
        this.filteredLoans = loans;
      },
      error: () => {
        // Error handled by interceptor
      }
    });
  }

  /**
   * Search loans by borrower name
   */
  searchLoans(): void {
    if (!this.searchTerm.trim()) {
      this.filteredLoans = this.loans;
      return;
    }

    this.loanService.searchLoansByBorrowerName(this.searchTerm).subscribe({
      next: (loans) => {
        this.filteredLoans = loans;
      },
      error: () => {
        // Error handled by interceptor
      }
    });
  }

  /**
   * Clear search and show all loans
   */
  clearSearch(): void {
    this.searchTerm = '';
    this.filteredLoans = this.loans;
  }

  /**
   * Delete a loan with confirmation
   */
  deleteLoan(loan: Loan): void {
    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      width: '400px',
      data: {
        title: 'Delete Loan',
        message: `Are you sure you want to delete the loan for ${loan.borrowerName}?`,
        confirmText: 'Delete',
        cancelText: 'Cancel'
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.loanService.deleteLoan(loan.loanId).subscribe({
          next: () => {
            this.errorHandler.showSuccess('Loan deleted successfully');
            this.loadLoans();
          },
          error: () => {
            // Error handled by interceptor
          }
        });
      }
    });
  }
}
