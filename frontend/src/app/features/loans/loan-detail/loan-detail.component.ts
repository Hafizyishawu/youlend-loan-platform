import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatDividerModule } from '@angular/material/divider';
import { LoanService } from '../../../core/services/loan.service';
import { Loan } from '../../../core/models/loan.model';
import { CurrencyFormatPipe } from '../../../shared/pipes/currency-format.pipe';

@Component({
  selector: 'app-loan-detail',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatDividerModule,
    CurrencyFormatPipe
  ],
  templateUrl: './loan-detail.component.html',
  styleUrls: ['./loan-detail.component.scss']
})
export class LoanDetailComponent implements OnInit {
  loan: Loan | null = null;
  loanId: string = '';

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private loanService: LoanService
  ) {}

  ngOnInit(): void {
    this.loanId = this.route.snapshot.params['id'];
    this.loadLoan();
  }

  loadLoan(): void {
    this.loanService.getLoanById(this.loanId).subscribe({
      next: (loan) => this.loan = loan,
      error: () => this.router.navigate(['/loans'])
    });
  }

  goBack(): void {
    this.router.navigate(['/loans']);
  }

  editLoan(): void {
    this.router.navigate(['/loans', this.loanId, 'edit']);
  }
}
