import { Injectable, Logger } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  private readonly logger = new Logger(JwtAuthGuard.name);

  constructor() {
    super();
    this.logger.log('JwtAuthGuard initialisé');
  }

  handleRequest(err: any, user: any, info: any, context: any, status?: any) {
    if (err) {
      this.logger.error(`Erreur dans JwtAuthGuard: ${err.message}`, err.stack);
      throw err;
    }

    if (!user) {
      const req = context?.switchToHttp?.().getRequest?.();
      const method = req?.method;
      const url = req?.originalUrl || req?.url;
      this.logger.warn('JwtAuthGuard - Aucun utilisateur trouvé dans la requête');
      this.logger.debug(`JwtAuthGuard - Info: ${info?.message || 'Aucune info'}`);
      if (method && url) {
        this.logger.debug(`JwtAuthGuard - Requête: ${method} ${url}`);
      }
    } else {
      this.logger.debug(`JwtAuthGuard - Utilisateur authentifié: ${user.email} (ID: ${user.id})`);
    }

    return super.handleRequest(err, user, info, context, status);
  }
} 