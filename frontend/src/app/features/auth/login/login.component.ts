import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, MatCardModule, MatButtonModule, MatIconModule],
  template: `
    <div class="login-container">
      <mat-card class="login-card">
        <mat-card-header>
          <mat-card-title>
            <mat-icon class="brand-icon">account_balance</mat-icon>
            <span>YouLend Loan Manager</span>
          </mat-card-title>
        </mat-card-header>
        
        <mat-card-content>
          <p class="welcome-text">Welcome! Please log in to manage your loans.</p>
        </mat-card-content>
        
        <mat-card-actions>
          <button mat-raised-button color="primary" (click)="login()" class="login-button">
            <mat-icon>login</mat-icon>
            Login with Auth0
          </button>
        </mat-card-actions>
      </mat-card>
    </div>
  `,
  styles: [`
    .login-container {
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: calc(100vh - 64px);
      padding: 24px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }

    .login-card {
      max-width: 400px;
      text-align: center;
      
      mat-card-title {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        font-size: 24px;
        
        .brand-icon {
          font-size: 32px;
          width: 32px;
          height: 32px;
        }
      }
    }

    .welcome-text {
      margin: 24px 0;
      color: rgba(0, 0, 0, 0.6);
    }

    .login-button {
      width: 100%;
      height: 48px;
      font-size: 16px;
    }
  `]
})
export class LoginComponent {
  constructor(private authService: AuthService) {}

  login(): void {
    this.authService.login();
  }
}
