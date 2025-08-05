import { Injectable, UnauthorizedException, Logger } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-local';
import { AuthService } from '../auth.service';

@Injectable()
export class LocalStrategy extends PassportStrategy(Strategy) {
  private readonly logger = new Logger(LocalStrategy.name);

  constructor(private authService: AuthService) {
    super({
      usernameField: 'email',
    });
    this.logger.log('LocalStrategy initialisée');
  }

  async validate(email: string, password: string) {
    this.logger.debug(`Validation locale - Tentative de connexion pour l'email: ${email}`);
    this.logger.debug(`Validation locale - Vérification des credentials`);
    
    const user = await this.authService.validateUserByCredentials(email, password);
    
    if (!user) {
      this.logger.warn(`Validation locale échouée - Credentials invalides pour l'email: ${email}`);
      throw new UnauthorizedException('Email ou mot de passe incorrect');
    }

    this.logger.debug(`Validation locale réussie pour l'utilisateur: ${user.email} (ID: ${user.id})`);

    return user;
  }
} 