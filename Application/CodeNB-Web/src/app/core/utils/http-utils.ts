import { HttpParams } from '@angular/common/http';

export function buildHttpParams(filters: Record<string, any>): HttpParams {
  let params = new HttpParams();

  Object.entries(filters).forEach(([key, value]) => {
    if (value !== null && value !== undefined) {
      if (typeof value === 'number') {
        params = params.set(key, value.toString());
      } else if (typeof value === 'string') {
        const trimmedValue = value.trim();
        if (trimmedValue !== '') {
          params = params.set(key, trimmedValue);
        }
      } else {
        params = params.set(key, value?.toString() ?? '');
      }
    }
  });

  return params;
}

export function sanitizeRequestBody(obj: any): any {
  if (Array.isArray(obj)) {
    return obj.map(sanitizeRequestBody);
  }

  if (obj !== null && typeof obj === 'object') {
    const cleaned: any = {};
    Object.entries(obj).forEach(([key, value]) => {
      if (typeof value === 'string' && value.trim() === '') {
        cleaned[key] = null;
      } else if (value === undefined) {
        cleaned[key] = null;
      } else if (typeof value === 'object') {
        cleaned[key] = sanitizeRequestBody(value);
      } else {
        cleaned[key] = value;
      }
    });
    return cleaned;
  }

  return obj;
}
