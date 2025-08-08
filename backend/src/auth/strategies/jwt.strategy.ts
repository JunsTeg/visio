import { Injectable, UnauthorizedException, Logger } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { AuthService } from '../auth.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  private readonly logger = new Logger(JwtStrategy.name);

  constructor(private authService: AuthService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'access-secret',
    });
    this.logger.log('JwtStrategy initialisée');
  }

  async validate(payload: any) {
    this.logger.debug(`Validation JWT - Payload reçu: ${JSON.stringify(payload)}`);
    this.logger.debug(`Validation JWT - User ID extrait: ${payload.sub}`);
    
    const user = await this.authService.validateUser(payload.sub);
    
    if (!user) {
      this.logger.warn(`Validation JWT échouée - Utilisateur non trouvé pour l'ID: ${payload.sub}`);
      throw new UnauthorizedException('Utilisateur non trouvé');
    }

    this.logger.debug(`Validation JWT réussie pour l'utilisateur: ${user.email} (ID: ${user.id})`);

    return {
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      isVerified: user.isVerified,
      lastLogin: user.lastLogin,
      active: user.active,
      online: user.online,
      createdAt: user.createdAt,
      roles: user.roles,
    };
  }
} 