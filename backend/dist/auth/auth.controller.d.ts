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
        };
    }>;
    logout(user: any): Promise<{
        message: string;
    }>;
    refreshToken(body: {
        refreshToken: string;
    }): Promise<{
        accessToken: string;
        refreshToken: string;
    }>;
    getProfile(user: any): any;
}
