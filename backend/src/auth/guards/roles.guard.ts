import { Injectable, CanActivate, ExecutionContext, ForbiddenException, Logger } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, Role } from '../../entities';

@Injectable()
export class RolesGuard implements CanActivate {
  private readonly logger = new Logger(RolesGuard.name);

  constructor(
    private reflector: Reflector,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Role)
    private roleRepository: Repository<Role>,
  ) {
    this.logger.log('RolesGuard initialisé');
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requiredRoles = this.reflector.get<string[]>('roles', context.getHandler());
    
    this.logger.debug(`Vérification des rôles - Rôles requis: ${JSON.stringify(requiredRoles)}`);
    
    if (!requiredRoles) {
      this.logger.debug('Aucun rôle requis, accès autorisé');
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      this.logger.warn('RolesGuard - Utilisateur non authentifié');
      throw new ForbiddenException('Utilisateur non authentifié');
    }

    this.logger.debug(`Vérification des rôles pour l'utilisateur: ${user.email} (ID: ${user.id})`);

    // Récupérer l'utilisateur avec ses rôles
    this.logger.debug('Récupération de l\'utilisateur avec ses rôles');
    const userWithRoles = await this.userRepository.findOne({
      where: { id: user.id },
      relations: ['roles'],
    });

    if (!userWithRoles) {
      this.logger.warn(`RolesGuard - Utilisateur non trouvé en base pour l'ID: ${user.id}`);
      throw new ForbiddenException('Utilisateur non trouvé');
    }

    const userRoles = userWithRoles.roles.map(role => role.name);
    this.logger.debug(`Rôles de l'utilisateur: ${JSON.stringify(userRoles)}`);
    
    const hasRequiredRole = requiredRoles.some(role => userRoles.includes(role));
    this.logger.debug(`L'utilisateur a-t-il les rôles requis? ${hasRequiredRole}`);

    if (!hasRequiredRole) {
      this.logger.warn(`Permissions insuffisantes - Utilisateur: ${user.email}, Rôles: ${userRoles}, Requis: ${requiredRoles}`);
      throw new ForbiddenException('Permissions insuffisantes');
    }

    this.logger.debug(`Accès autorisé pour l'utilisateur: ${user.email} avec les rôles: ${userRoles}`);
    return true;
  }
} 