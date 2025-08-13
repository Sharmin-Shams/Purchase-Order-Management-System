export class ApiMessageResponse {
  status: string;
  message: string;
}

export class ApiErrorsResponse {
  status: number;
  error: Error;
}

export class ValidationError {
  description: string;
  field: string;
}

export class Error {
  errors: ValidationError[];
}
