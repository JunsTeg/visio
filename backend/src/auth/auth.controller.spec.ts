import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

describe('AuthController', () => {
  let controller: AuthController;
  let authService: AuthService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [
        {
          provide: AuthService,
          useValue: {
            register: jest.fn(),
            login: jest.fn(),
            logout: jest.fn(),
            refreshToken: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<AuthController>(AuthController);
    authService = module.get<AuthService>(AuthService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('register', () => {
    it('should register a new user', async () => {
      const registerDto = {
        fullName: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
        phoneNumber: '+33123456789',
      };

      const expectedResult = {
        user: {
          id: 'uuid',
          email: 'john@example.com',
          fullName: 'John Doe',
          phoneNumber: '+33123456789',
          isVerified: false,
        },
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      };

      jest.spyOn(authService, 'register').mockResolvedValue(expectedResult);

      const result = await controller.register(registerDto);

      expect(result).toEqual(expectedResult);
      expect(authService.register).toHaveBeenCalledWith(registerDto);
    });
  });

  describe('login', () => {
    it('should login a user', async () => {
      const loginDto = {
        email: 'john@example.com',
        password: 'password123',
      };

      const expectedResult = {
        user: {
          id: 'uuid',
          email: 'john@example.com',
          fullName: 'John Doe',
          phoneNumber: '+33123456789',
          isVerified: false,
        },
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      };

      jest.spyOn(authService, 'login').mockResolvedValue(expectedResult);

      const result = await controller.login(loginDto, {} as any);

      expect(result).toEqual(expectedResult);
      expect(authService.login).toHaveBeenCalledWith(loginDto);
    });
  });
}); 