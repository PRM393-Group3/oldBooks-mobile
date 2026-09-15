import { ApiException, NotFoundException, ValidationException } from './api_exception';

export interface ApiResponse<T> {
  data: T;
  message?: string;
  success: boolean;
  timestamp: string;
}

export class ApiClient {
  private baseUrl: string;
  private token: string | null = 'mock-escrow-bearer-token-alexander-vance';

  constructor(baseUrl: string = '/api/v1') {
    this.baseUrl = baseUrl;
  }

  public setToken(token: string | null): void {
    this.token = token;
  }

  public async get<T>(endpoint: string, mockResolver?: () => T): Promise<ApiResponse<T>> {
    await this.simulateNetwork();
    if (mockResolver) {
      const data = mockResolver();
      if (!data) throw new NotFoundException(`Endpoint ${endpoint} not found`);
      return {
        data,
        success: true,
        timestamp: new Date().toISOString()
      };
    }
    throw new ApiException(`GET ${endpoint} not implemented on live server`, 501);
  }

  public async post<T, B = any>(endpoint: string, body?: B, mockResolver?: (body: B) => T): Promise<ApiResponse<T>> {
    await this.simulateNetwork();
    if (mockResolver) {
      const data = mockResolver(body as B);
      return {
        data,
        success: true,
        timestamp: new Date().toISOString()
      };
    }
    throw new ApiException(`POST ${endpoint} not implemented`, 501);
  }

  public async patch<T, B = any>(endpoint: string, body?: B, mockResolver?: (body: B) => T): Promise<ApiResponse<T>> {
    await this.simulateNetwork();
    if (mockResolver) {
      const data = mockResolver(body as B);
      return {
        data,
        success: true,
        timestamp: new Date().toISOString()
      };
    }
    throw new ApiException(`PATCH ${endpoint} not implemented`, 501);
  }

  public async delete<T>(endpoint: string, mockResolver?: () => T): Promise<ApiResponse<T>> {
    await this.simulateNetwork();
    if (mockResolver) {
      const data = mockResolver();
      return {
        data,
        success: true,
        timestamp: new Date().toISOString()
      };
    }
    throw new ApiException(`DELETE ${endpoint} not implemented`, 501);
  }

  private simulateNetwork(delayMs: number = 80): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, delayMs));
  }
}

export const defaultApiClient = new ApiClient('/api/v1');
