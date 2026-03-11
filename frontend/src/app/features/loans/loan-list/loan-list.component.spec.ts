import { ComponentFixture, TestBed } from '@angular/core/testing';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { MatDialogModule } from '@angular/material/dialog';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { LoanListComponent } from './loan-list.component';
import { LoanService } from '../../../core/services/loan.service';
import { of } from 'rxjs';

describe('LoanListComponent', () => {
  let component: LoanListComponent;
  let fixture: ComponentFixture<LoanListComponent>;
  let loanService: jasmine.SpyObj<LoanService>;

  beforeEach(async () => {
    const loanServiceSpy = jasmine.createSpyObj('LoanService', ['getAllLoans', 'searchLoansByBorrowerName', 'deleteLoan']);

    await TestBed.configureTestingModule({
      imports: [
        LoanListComponent,
        HttpClientTestingModule,
        MatDialogModule,
        MatSnackBarModule,
        NoopAnimationsModule
      ],
      providers: [
        { provide: LoanService, useValue: loanServiceSpy }
      ]
    }).compileComponents();

    loanService = TestBed.inject(LoanService) as jasmine.SpyObj<LoanService>;
    fixture = TestBed.createComponent(LoanListComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should load loans on init', () => {
    const mockLoans = [
      {
        loanId: '123',
        borrowerName: 'John Doe',
        repaymentAmount: 15000,
        fundingAmount: 10000,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ];

    loanService.getAllLoans.and.returnValue(of(mockLoans));
    
    component.ngOnInit();

    expect(loanService.getAllLoans).toHaveBeenCalled();
    expect(component.loans.length).toBe(1);
    expect(component.filteredLoans.length).toBe(1);
  });

  it('should search loans by borrower name', () => {
    const mockLoans = [
      {
        loanId: '123',
        borrowerName: 'John Doe',
        repaymentAmount: 15000,
        fundingAmount: 10000,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ];

    loanService.searchLoansByBorrowerName.and.returnValue(of(mockLoans));
    
    component.searchTerm = 'John';
    component.searchLoans();

    expect(loanService.searchLoansByBorrowerName).toHaveBeenCalledWith('John');
    expect(component.filteredLoans.length).toBe(1);
  });

  it('should clear search', () => {
    component.loans = [
      {
        loanId: '123',
        borrowerName: 'John Doe',
        repaymentAmount: 15000,
        fundingAmount: 10000,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ];
    component.searchTerm = 'test';

    component.clearSearch();

    expect(component.searchTerm).toBe('');
    expect(component.filteredLoans).toEqual(component.loans);
  });
});
