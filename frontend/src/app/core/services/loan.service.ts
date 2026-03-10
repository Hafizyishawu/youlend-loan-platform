import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { Loan, CreateLoanRequest, UpdateLoanRequest } from '../models/loan.model';

/**
 * Service for loan API operations
 */
@Injectable({
  providedIn: 'root'
})
export class LoanService {
  private readonly apiUrl = `${environment.apiUrl}/loans`;

  constructor(private http: HttpClient) {}

  /**
   * Get all loans
   */
  getAllLoans(): Observable<Loan[]> {
    return this.http.get<Loan[]>(this.apiUrl);
  }

  /**
   * Get loan by ID
   */
  getLoanById(loanId: string): Observable<Loan> {
    return this.http.get<Loan>(`${this.apiUrl}/${loanId}`);
  }

  /**
   * Search loans by borrower name
   */
  searchLoansByBorrowerName(borrowerName: string): Observable<Loan[]> {
    const params = new HttpParams().set('borrowerName', borrowerName);
    return this.http.get<Loan[]>(`${this.apiUrl}/search`, { params });
  }

  /**
   * Create a new loan
   */
  createLoan(request: CreateLoanRequest): Observable<Loan> {
    return this.http.post<Loan>(this.apiUrl, request);
  }

  /**
   * Update an existing loan
   */
  updateLoan(loanId: string, request: UpdateLoanRequest): Observable<Loan> {
    return this.http.put<Loan>(`${this.apiUrl}/${loanId}`, request);
  }

  /**
   * Delete a loan
   */
  deleteLoan(loanId: string): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${loanId}`);
  }
}
