import { Module, Logger } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './strategies/jwt.strategy';
import { LocalStrategy } from './strategies/local.strategy';
import { RolesGuard } from './guards/roles.guard';
import { User, AuthToken, Role } from '../entities';

@Module({
  imports: [
    TypeOrmModule.forFeature([User, AuthToken, Role]),
    PassportModule,
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'access-secret',
      signOptions: { expiresIn: '7d' },
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy, LocalStrategy, RolesGuard],
  exports: [AuthService, RolesGuard],
})
export class AuthModule {
  private readonly logger = new Logger(AuthModule.name);

  constructor() {
    this.logger.log('AuthModule initialisé avec tous les composants d\'authentification');
    this.logger.debug('Composants disponibles: AuthService, JwtStrategy, LocalStrategy, RolesGuard');
  }
} 