import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter, withInMemoryScrolling } from '@angular/router';
import { provideToastr } from 'ngx-toastr';
import { routes } from './app.routes';
import { provideAnimations } from '@angular/platform-browser/animations';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { authInterceptor } from '@interceptors/auth.interceptor';
import { provideCharts, withDefaultRegisterables } from 'ng2-charts';

const memoryScrolling = withInMemoryScrolling({
  anchorScrolling: 'enabled',
  scrollPositionRestoration: 'enabled',
});

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes, memoryScrolling),
    provideAnimations(),
    provideToastr({
      positionClass: 'toast-top-center',
      timeOut: 1500,
    }),
    provideHttpClient(withInterceptors([authInterceptor])), provideCharts(withDefaultRegisterables()),
  ],
};
