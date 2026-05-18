export interface ApiResponse<T = unknown> {
  status: number;
  message: string;
  result?: T;
  pagination?: unknown;
}

export function ok<T>(message: string, result?: T, pagination?: unknown): ApiResponse<T> {
  return {
    status: 200,
    message,
    result,
    pagination,
  };
}

export function fail(message: string, status = 400): ApiResponse {
  return {
    status,
    message,
  };
}
