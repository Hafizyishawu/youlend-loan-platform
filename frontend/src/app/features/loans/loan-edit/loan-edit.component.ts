import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { LoanService } from '../../../core/services/loan.service';
import { ErrorHandlerService } from '../../../core/services/error-handler.service';
import { UpdateLoanRequest } from '../../../core/models/loan.model';

@Component({
  selector: 'app-loan-edit',
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
  templateUrl: './loan-edit.component.html',
  styleUrls: ['./loan-edit.component.scss']
})
export class LoanEditComponent implements OnInit {
  loanForm: FormGroup;
  submitted = false;
  loanId: string = '';

  constructor(
    private fb: FormBuilder,
    private route: ActivatedRoute,
    private router: Router,
    private loanService: LoanService,
    private errorHandler: ErrorHandlerService
  ) {
    this.loanForm = this.fb.group({
      borrowerName: ['', [Validators.required, Validators.maxLength(100)]],
      fundingAmount: ['', [Validators.required, Validators.min(0.01), Validators.max(1000000000)]],
      repaymentAmount: ['', [Validators.required, Validators.min(0.01), Validators.max(1000000000)]]
    }, { validators: this.repaymentGreaterThanFunding });
  }

  ngOnInit(): void {
    this.loanId = this.route.snapshot.params['id'];
    this.loadLoan();
  }

  repaymentGreaterThanFunding(group: FormGroup): { [key: string]: boolean } | null {
    const funding = group.get('fundingAmount')?.value;
    const repayment = group.get('repaymentAmount')?.value;

    if (funding && repayment && repayment < funding) {
      return { repaymentLessThanFunding: true };
    }
    return null;
  }

  loadLoan(): void {
    this.loanService.getLoanById(this.loanId).subscribe({
      next: (loan) => {
        this.loanForm.patchValue({
          borrowerName: loan.borrowerName,
          fundingAmount: loan.fundingAmount,
          repaymentAmount: loan.repaymentAmount
        });
      },
      error: () => {
        this.router.navigate(['/loans']);
      }
    });
  }

  onSubmit(): void {
    this.submitted = true;

    if (this.loanForm.invalid) {
      return;
    }

    const request: UpdateLoanRequest = this.loanForm.value;

    this.loanService.updateLoan(this.loanId, request).subscribe({
      next: () => {
        this.errorHandler.showSuccess('Loan updated successfully');
        this.router.navigate(['/loans', this.loanId]);
      },
      error: () => {
        // Error handled by interceptor
      }
    });
  }

  onCancel(): void {
    this.router.navigate(['/loans', this.loanId]);
  }

  get f() {
    return this.loanForm.controls;
  }
}
