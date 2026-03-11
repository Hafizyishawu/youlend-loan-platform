import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { LoanService } from './loan.service';
import { Loan, CreateLoanRequest, UpdateLoanRequest } from '../models/loan.model';

describe('LoanService', () => {
  let service: LoanService;
  let httpMock: HttpTestingController;
  const apiUrl = '/api/v1/loans'; // Use hardcoded API URL for tests

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [LoanService]
    });
    service = TestBed.inject(LoanService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify();
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  it('should get all loans', () => {
    const mockLoans: Loan[] = [
      {
        loanId: '123',
        borrowerName: 'John Doe',
        repaymentAmount: 15000,
        fundingAmount: 10000,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ];

    service.getAllLoans().subscribe(loans => {
      expect(loans.length).toBe(1);
      expect(loans).toEqual(mockLoans);
    });

    const req = httpMock.expectOne(apiUrl);
    expect(req.request.method).toBe('GET');
    req.flush(mockLoans);
  });

  it('should get loan by ID', () => {
    const mockLoan: Loan = {
      loanId: '123',
      borrowerName: 'John Doe',
      repaymentAmount: 15000,
      fundingAmount: 10000,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    service.getLoanById('123').subscribe(loan => {
      expect(loan).toEqual(mockLoan);
    });

    const req = httpMock.expectOne(`${apiUrl}/123`);
    expect(req.request.method).toBe('GET');
    req.flush(mockLoan);
  });

  it('should search loans by borrower name', () => {
    const mockLoans: Loan[] = [];

    service.searchLoansByBorrowerName('John Doe').subscribe(loans => {
      expect(loans).toEqual(mockLoans);
    });

    const req = httpMock.expectOne(req => req.url === `${apiUrl}/search`);
    expect(req.request.method).toBe('GET');
    expect(req.request.params.get('borrowerName')).toBe('John Doe');
    req.flush(mockLoans);
  });

  it('should create a loan', () => {
    const createRequest: CreateLoanRequest = {
      borrowerName: 'Jane Smith',
      repaymentAmount: 20000,
      fundingAmount: 15000
    };

    const mockLoan: Loan = {
      loanId: '456',
      ...createRequest,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    service.createLoan(createRequest).subscribe(loan => {
      expect(loan).toEqual(mockLoan);
    });

    const req = httpMock.expectOne(apiUrl);
    expect(req.request.method).toBe('POST');
    expect(req.request.body).toEqual(createRequest);
    req.flush(mockLoan);
  });

  it('should update a loan', () => {
    const updateRequest: UpdateLoanRequest = {
      borrowerName: 'Jane Smith Updated',
      repaymentAmount: 25000,
      fundingAmount: 18000
    };

    const mockLoan: Loan = {
      loanId: '456',
      ...updateRequest,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    service.updateLoan('456', updateRequest).subscribe(loan => {
      expect(loan).toEqual(mockLoan);
    });

    const req = httpMock.expectOne(`${apiUrl}/456`);
    expect(req.request.method).toBe('PUT');
    expect(req.request.body).toEqual(updateRequest);
    req.flush(mockLoan);
  });

  it('should delete a loan', () => {
    service.deleteLoan('456').subscribe();

    const req = httpMock.expectOne(`${apiUrl}/456`);
    expect(req.request.method).toBe('DELETE');
    req.flush(null);
  });
});