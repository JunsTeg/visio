import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import { User, AuthToken } from '../entities';
import { LoginDto, RegisterDto } from './dto';
export declare class AuthService {
    private userRepository;
    private authTokenRepository;
    private jwtService;
    private readonly logger;
    constructor(userRepository: Repository<User>, authTokenRepository: Repository<AuthToken>, jwtService: JwtService);
    register(registerDto: RegisterDto): Promise<{
        accessToken: string;
        refreshToken: string;
        user: {
            id: string;
            email: string;
            fullName: string;
            phoneNumber: string;
            isVerified: boolean;
            roles: import("../entities").Role[];
        };
    }>;
    login(loginDto: LoginDto): Promise<{
        accessToken: string;
        refreshToken: string;
        user: {
            id: string;
            email: string;
            fullName: string;
            phoneNumber: string;
            isVerified: boolean;
            createdAt: Date;
            lastLogin: Date;
            active: boolean;
            online: boolean;
            roles: import("../entities").Role[];
        };
    }>;
    logout(userId: string): Promise<{
        message: string;
    }>;
    refreshToken(refreshToken: string): Promise<{
        user: {
            id: string;
            email: string;
            fullName: string;
            phoneNumber: string;
            isVerified: boolean;
            createdAt: Date;
            lastLogin: Date;
            active: boolean;
            online: boolean;
            roles: import("../entities").Role[];
        };
        accessToken: string;
        refreshToken: string;
    }>;
    private generateTokens;
    validateUser(userId: string): Promise<User | null>;
    validateUserByCredentials(email: string, password: string): Promise<User | null>;
    getUserWithRoles(userId: string): Promise<User>;
}
