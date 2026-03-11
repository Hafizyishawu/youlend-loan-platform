/**
 * Loan domain model matching backend API
 */
export interface Loan {
  loanId: string;
  borrowerName: string;
  repaymentAmount: number;
  fundingAmount: number;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Request payload for creating a loan
 */
export interface CreateLoanRequest {
  borrowerName: string;
  repaymentAmount: number;
  fundingAmount: number;
}

/**
 * Request payload for updating a loan
 */
export interface UpdateLoanRequest {
  borrowerName: string;
  repaymentAmount: number;
  fundingAmount: number;
}

/**
 * API error response
 */
export interface ErrorResponse {
  message: string;
  statusCode: number;
  correlationId: string;
  timestamp: Date;
  validationErrors?: { [key: string]: string[] };
}
