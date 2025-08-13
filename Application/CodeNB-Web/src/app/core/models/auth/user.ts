export class User {
  id: number;
  firstName: string;
  lastName: string;
  role: string;
  token: string;
  expiresIn: number;
}

export type AuthUser = Omit<User, 'token' | 'expiresIn'> & {
  authenticated: boolean;
};

export type AuthData = AuthUser & {
  token: string;
  expiresAt: string;
};
