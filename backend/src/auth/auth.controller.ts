import { Controller, Post, Body, UseGuards, Request, Get, Logger } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto, RegisterDto } from './dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { LocalAuthGuard } from './guards/local-auth.guard';
import { CurrentUser } from './decorators/current-user.decorator';

@Controller('auth')
export class AuthController {
  private readonly logger = new Logger(AuthController.name);

  constructor(private authService: AuthService) {
    this.logger.log('AuthController initialisé');
  }

  @Post('register')
  async register(@Body() registerDto: RegisterDto) {
    this.logger.log(`Requête d'inscription reçue pour l'email: ${registerDto.email}`);
    this.logger.debug(`Données d'inscription: ${JSON.stringify({ ...registerDto, password: '[MASKED]' })}`);
    
    try {
      const result = await this.authService.register(registerDto);
      this.logger.log(`Inscription réussie pour l'email: ${registerDto.email}`);
      return result;
    } catch (error) {
      this.logger.error(`Erreur lors de l'inscription pour l'email: ${registerDto.email}`, error.stack);
      throw error;
    }
  }

  @UseGuards(LocalAuthGuard)
  @Post('login')
  async login(@Body() loginDto: LoginDto, @Request() req) {
    this.logger.log(`Requête de connexion reçue pour l'email: ${loginDto.email}`);
    this.logger.debug(`Données de connexion: ${JSON.stringify({ ...loginDto, password: '[MASKED]' })}`);
    
    try {
      const result = await this.authService.login(loginDto);
      this.logger.log(`Connexion réussie pour l'email: ${loginDto.email}`);
      return result;
    } catch (error) {
      this.logger.error(`Erreur lors de la connexion pour l'email: ${loginDto.email}`, error.stack);
      throw error;
    }
  }

  @UseGuards(JwtAuthGuard)
  @Post('logout')
  async logout(@CurrentUser() user) {
    this.logger.log(`Requête de déconnexion reçue pour l'utilisateur ID: ${user.id}`);
    this.logger.debug(`Utilisateur déconnecté: ${user.email} (ID: ${user.id})`);
    
    try {
      const result = await this.authService.logout(user.id);
      this.logger.log(`Déconnexion réussie pour l'utilisateur ID: ${user.id}`);
      return result;
    } catch (error) {
      this.logger.error(`Erreur lors de la déconnexion pour l'utilisateur ID: ${user.id}`, error.stack);
      throw error;
    }
  }

  @Post('refresh')
  async refreshToken(@Body() body: { refreshToken: string }) {
    this.logger.log('Requête de rafraîchissement de token reçue');
    this.logger.debug(`Refresh token reçu: ${body.refreshToken.substring(0, 20)}...`);
    
    try {
      const result = await this.authService.refreshToken(body.refreshToken);
      this.logger.log('Rafraîchissement de token réussi');
      return result;
    } catch (error) {
      this.logger.error('Erreur lors du rafraîchissement de token', error.stack);
      throw error;
    }
  }

  @UseGuards(JwtAuthGuard)
  @Get('profile')
  getProfile(@CurrentUser() user) {
    this.logger.log(`Requête de profil reçue pour l'utilisateur ID: ${user.id}`);
    this.logger.debug(`Profil demandé pour: ${user.email} (ID: ${user.id})`);
    
    return user;
  }
} 