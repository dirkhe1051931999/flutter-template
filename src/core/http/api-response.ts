export interface ApiResponse<T = unknown> {
  status: number;
  message: string;
  errors?: string;
  result?: T;
  total_rows?: number;
  total_page?: number;
  current_page?: number;
  more_page?: boolean;
}

type Pagination = {
  total_rows?: number;
  total_page?: number;
  current_page?: number;
  more_page?: boolean;
};

export function ok<T>(message: string, result?: T, pagination?: Pagination): ApiResponse<T> {
  const response: ApiResponse<T> = {
    status: 200,
    message,
    result,
  };

  if (pagination) {
    response.total_rows = pagination.total_rows;
    response.total_page = pagination.total_page;
    response.current_page = pagination.current_page;
    response.more_page = pagination.more_page;
  }

  return response;
}

export function fail(message: string, status = 400): ApiResponse {
  return {
    status,
    message,
  };
}

export function failWithErrors(message: string, status = 400): ApiResponse {
  return {
    status,
    message,
    errors: message,
  };
}
