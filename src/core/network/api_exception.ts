export class ApiException extends Error {
  public statusCode: number;
  public details?: any;

  constructor(message: string, statusCode: number = 500, details?: any) {
    super(message);
    this.name = 'ApiException';
    this.statusCode = statusCode;
    this.details = details;
  }
}

export class ValidationException extends ApiException {
  constructor(message: string, details?: any) {
    super(message, 422, details);
    this.name = 'ValidationException';
  }
}

export class NotFoundException extends ApiException {
  constructor(message: string = 'Resource not found') {
    super(message, 404);
    this.name = 'NotFoundException';
  }
}

export class UnauthorizedException extends ApiException {
  constructor(message: string = 'Unauthorized access') {
    super(message, 401);
    this.name = 'UnauthorizedException';
  }
}
