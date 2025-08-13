import { Injectable, Logger } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class LocalAuthGuard extends AuthGuard('local') {
  private readonly logger = new Logger(LocalAuthGuard.name);

  constructor() {
    super();
    this.logger.log('LocalAuthGuard initialisé');
  }

  handleRequest(err: any, user: any, info: any, context: any, status?: any) {
    if (err) {
      this.logger.error(`Erreur dans LocalAuthGuard: ${err.message}`, err.stack);
      throw err;
    }

    if (!user) {
      this.logger.warn('LocalAuthGuard - Aucun utilisateur trouvé dans la requête');
      this.logger.debug(`LocalAuthGuard - Info: ${info?.message || 'Aucune info'}`);
    } else {
      this.logger.debug(`LocalAuthGuard - Utilisateur authentifié: ${user.email} (ID: ${user.id})`);
    }

    return super.handleRequest(err, user, info, context, status);
  }
} 