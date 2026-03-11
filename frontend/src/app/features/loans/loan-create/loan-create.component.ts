import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { LoanService } from '../../../core/services/loan.service';
import { ErrorHandlerService } from '../../../core/services/error-handler.service';
import { CreateLoanRequest } from '../../../core/models/loan.model';

/**
 * Loan create component - form to create new loans
 */
@Component({
  selector: 'app-loan-create',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    ReactiveFormsModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule
  ],
  templateUrl: './loan-create.component.html',
  styleUrls: ['./loan-create.component.scss']
})
export class LoanCreateComponent {
  loanForm: FormGroup;
  submitted = false;

  constructor(
    private fb: FormBuilder,
    private loanService: LoanService,
    private errorHandler: ErrorHandlerService,
    private router: Router
  ) {
    this.loanForm = this.fb.group({
      borrowerName: ['', [Validators.required, Validators.maxLength(100)]],
      fundingAmount: ['', [Validators.required, Validators.min(0.01), Validators.max(1000000000)]],
      repaymentAmount: ['', [Validators.required, Validators.min(0.01), Validators.max(1000000000)]]
    }, { validators: this.repaymentGreaterThanFunding });
  }

  /**
   * Custom validator: repayment amount must be >= funding amount
   */
  repaymentGreaterThanFunding(group: FormGroup): { [key: string]: boolean } | null {
    const funding = group.get('fundingAmount')?.value;
    const repayment = group.get('repaymentAmount')?.value;

    if (funding && repayment && repayment < funding) {
      return { repaymentLessThanFunding: true };
    }
    return null;
  }

  /**
   * Submit form and create loan
   */
  onSubmit(): void {
    this.submitted = true;

    if (this.loanForm.invalid) {
      return;
    }

    const request: CreateLoanRequest = this.loanForm.value;

    this.loanService.createLoan(request).subscribe({
      next: () => {
        this.errorHandler.showSuccess('Loan created successfully');
        this.router.navigate(['/loans']);
      },
      error: () => {
        // Error handled by interceptor
      }
    });
  }

  /**
   * Cancel and go back to list
   */
  onCancel(): void {
    this.router.navigate(['/loans']);
  }

  /**
   * Get form control for validation messages
   */
  get f() {
    return this.loanForm.controls;
  }
}
