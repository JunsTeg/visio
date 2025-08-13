import { User } from './user.entity';
export declare class AuthToken {
    id: number;
    userId: string;
    token: string;
    type: string;
    expiresAt: Date;
    createdAt: Date;
    user: User;
}
