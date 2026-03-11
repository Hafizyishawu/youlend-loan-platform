import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';
import { LoginComponent } from './features/auth/login/login.component';
import { CallbackComponent } from './features/auth/callback/callback.component';
import { LoanListComponent } from './features/loans/loan-list/loan-list.component';
import { LoanCreateComponent } from './features/loans/loan-create/loan-create.component';
import { LoanDetailComponent } from './features/loans/loan-detail/loan-detail.component';
import { LoanEditComponent } from './features/loans/loan-edit/loan-edit.component';

export const routes: Routes = [
  { path: '', redirectTo: '/loans', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'callback', component: CallbackComponent },
  { 
    path: 'loans', 
    component: LoanListComponent,
    canActivate: [authGuard]
  },
  { 
    path: 'loans/create', 
    component: LoanCreateComponent,
    canActivate: [authGuard]
  },
  { 
    path: 'loans/:id', 
    component: LoanDetailComponent,
    canActivate: [authGuard]
  },
  { 
    path: 'loans/:id/edit', 
    component: LoanEditComponent,
    canActivate: [authGuard]
  },
  { path: '**', redirectTo: '/loans' }
];
