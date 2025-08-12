import { AuthService } from './auth.service';
import { LoginDto, RegisterDto } from './dto';
export declare class AuthController {
    private authService;
    private readonly logger;
    constructor(authService: AuthService);
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
    login(loginDto: LoginDto, req: any): Promise<{
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
    logout(user: any): Promise<{
        message: string;
    }>;
    refreshToken(body: {
        refreshToken: string;
    }): Promise<{
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
    getProfile(user: any): Promise<import("../entities").User>;
}
