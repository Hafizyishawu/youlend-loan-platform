import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';

import { inject } from '@angular/core';
import { AuthService } from '@auth0/auth0-angular';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-root',
  imports: [
    RouterOutlet,
    CommonModule,
  ],
  templateUrl: './app.html',
})
export class App {
  protected readonly window = window;
  protected auth = inject(AuthService);
}
