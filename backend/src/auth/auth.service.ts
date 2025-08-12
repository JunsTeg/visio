import { Injectable, UnauthorizedException, ConflictException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { User, AuthToken, Role } from '../entities';
import { LoginDto, RegisterDto } from './dto';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(AuthToken)
    private authTokenRepository: Repository<AuthToken>,
    @InjectRepository(Role)
    private roleRepository: Repository<Role>,
    private jwtService: JwtService,
  ) {
    this.logger.log('AuthService initialisé');
  }

  async register(registerDto: RegisterDto) {
    this.logger.log(`Tentative d'inscription pour l'email: ${registerDto.email}`);
    
    const { email, password, fullName, phoneNumber, role, avatarUrl } = registerDto;

    // Vérifier si l'utilisateur existe déjà
    this.logger.debug(`Vérification de l'existence de l'utilisateur avec l'email: ${email}`);
    const existingUser = await this.userRepository.findOne({
      where: { email },
    });

    if (existingUser) {
      this.logger.warn(`Tentative d'inscription avec un email déjà existant: ${email}`);
      throw new ConflictException('Un utilisateur avec cet email existe déjà');
    }

    this.logger.debug('Aucun utilisateur existant trouvé, procédure d\'inscription en cours');

    // Récupérer le rôle choisi ou "user" par défaut
    const requestedRole = (role || 'user').toLowerCase();
    this.logger.debug(`Récupération du rôle à assigner: ${requestedRole}`);
    const userRole = await this.roleRepository.findOne({
      where: { name: requestedRole },
    });

    if (!userRole) {
      this.logger.error(`Rôle "${requestedRole}" non trouvé en base de données`);
      throw new Error('Configuration des rôles manquante. Veuillez contacter l\'administrateur.');
    }

    // Hasher le mot de passe
    this.logger.debug('Hachage du mot de passe en cours...');
    const saltRounds = 12;
    const passwordHash = await bcrypt.hash(password, saltRounds);
    this.logger.debug('Mot de passe haché avec succès');

    // Créer le nouvel utilisateur avec le rôle par défaut
    this.logger.debug('Création de l\'entité utilisateur avec le rôle par défaut');
    const user = this.userRepository.create({
      email,
      passwordHash,
      fullName,
      phoneNumber,
      avatarUrl,
      isVerified: false,
      roles: [userRole],
    });

    this.logger.debug('Sauvegarde de l\'utilisateur en base de données');
    const savedUser = await this.userRepository.save(user);
    this.logger.log(`Utilisateur créé avec succès, ID: ${savedUser.id}`);

    // Générer les tokens
    this.logger.debug('Génération des tokens d\'authentification');
    const tokens = await this.generateTokens(savedUser);
    this.logger.debug('Tokens générés avec succès');

    // Récupérer l'utilisateur avec ses rôles pour la réponse
    const userWithRoles = await this.userRepository.findOne({
      where: { id: savedUser.id },
      relations: ['roles'],
    });

    if (!userWithRoles) {
      this.logger.error(`Erreur: Impossible de récupérer l'utilisateur avec ses rôles après création`);
      throw new Error('Erreur lors de la création de l\'utilisateur');
    }

    this.logger.log(`Inscription réussie pour l'utilisateur: ${savedUser.email} (ID: ${savedUser.id})`);

    return {
      user: {
        id: userWithRoles.id,
        email: userWithRoles.email,
        fullName: userWithRoles.fullName,
        phoneNumber: userWithRoles.phoneNumber,
        avatarUrl: userWithRoles.avatarUrl,
        isVerified: userWithRoles.isVerified,
        roles: userWithRoles.roles,
      },
      ...tokens,
    };
  }

  async login(loginDto: LoginDto) {
    this.logger.log(`Tentative de connexion pour l'email: ${loginDto.email}`);
    
    const { email, password } = loginDto;

    // Trouver l'utilisateur avec ses rôles
    this.logger.debug(`Recherche de l'utilisateur avec l'email: ${email}`);
    const user = await this.userRepository.findOne({
      where: { email },
      relations: ['roles'],
    });

    if (!user) {
      this.logger.warn(`Tentative de connexion avec un email inexistant: ${email}`);
      throw new UnauthorizedException('Email ou mot de passe incorrect');
    }

    this.logger.debug(`Utilisateur trouvé, ID: ${user.id}, vérification du mot de passe`);

    // Vérifier le mot de passe
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);

    if (!isPasswordValid) {
      this.logger.warn(`Mot de passe incorrect pour l'utilisateur: ${email}`);
      throw new UnauthorizedException('Email ou mot de passe incorrect');
    }

    // Vérifier si le compte est actif
    if (!user.active) {
      this.logger.warn(`Tentative de connexion pour un compte désactivé: ${email}`);
      throw new UnauthorizedException('Compte désactivé. Veuillez contacter le support.');
    }

    this.logger.debug('Mot de passe validé avec succès');

    // Mettre à jour lastLogin et online
    user.lastLogin = new Date();
    user.online = true;
    await this.userRepository.save(user);

    // Log des rôles pour débogage
    this.logger.debug(`Rôles de l'utilisateur ${user.email}: ${JSON.stringify(user.roles?.map(r => ({ id: r.id, name: r.name })))}`);

    // Générer les tokens
    this.logger.debug('Génération des tokens d\'authentification');
    const tokens = await this.generateTokens(user);
    this.logger.debug('Tokens générés avec succès');

    this.logger.log(`Connexion réussie pour l'utilisateur: ${user.email} (ID: ${user.id})`);

    const response = {
      user: {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        phoneNumber: user.phoneNumber,
        isVerified: user.isVerified,
        createdAt: user.createdAt,
        lastLogin: user.lastLogin,
        active: user.active,
        online: user.online,
        roles: user.roles,
      },
      ...tokens,
    };

    // Log de la réponse pour débogage
    this.logger.debug(`Réponse de connexion pour ${user.email}: ${JSON.stringify({
      ...response,
      user: { ...response.user, roles: response.user.roles?.map(r => ({ id: r.id, name: r.name })) }
    })}`);

    return response;
  }

  async logout(userId: string) {
    this.logger.log(`Tentative de déconnexion pour l'utilisateur ID: ${userId}`);

    // Mettre à jour online à false
    await this.userRepository.update(userId, { online: false });

    // Supprimer tous les tokens de l'utilisateur
    this.logger.debug(`Suppression des tokens pour l'utilisateur ID: ${userId}`);
    const deleteResult = await this.authTokenRepository.delete({ userId });
    this.logger.debug(`Tokens supprimés: ${deleteResult.affected} tokens supprimés`);

    this.logger.log(`Déconnexion réussie pour l'utilisateur ID: ${userId}`);
    return { message: 'Déconnexion réussie' };
  }

  async refreshToken(refreshToken: string) {
    this.logger.log('Tentative de rafraîchissement de token');
    this.logger.debug(`Refresh token reçu: ${refreshToken.substring(0, 20)}...`);
    
    try {
      // Vérifier le refresh token
      this.logger.debug('Vérification du refresh token JWT');
      const payload = this.jwtService.verify(refreshToken, {
        secret: process.env.JWT_REFRESH_SECRET || 'refresh-secret',
      });
      this.logger.debug(`Payload JWT extrait, user ID: ${payload.sub}`);

      // Vérifier si le token existe en base
      this.logger.debug('Vérification de l\'existence du token en base de données');
      const tokenRecord = await this.authTokenRepository.findOne({
        where: { token: refreshToken, type: 'refresh' },
      });

      if (!tokenRecord) {
        this.logger.warn('Refresh token non trouvé en base de données');
        throw new UnauthorizedException('Token de rafraîchissement invalide');
      }

      this.logger.debug(`Token trouvé en base, ID: ${tokenRecord.id}, expiration: ${tokenRecord.expiresAt}`);

      // Vérifier si le token n'est pas expiré
      if (new Date() > tokenRecord.expiresAt) {
        this.logger.warn(`Refresh token expiré, ID: ${tokenRecord.id}`);
        await this.authTokenRepository.delete({ id: tokenRecord.id });
        throw new UnauthorizedException('Token de rafraîchissement expiré');
      }

      this.logger.debug('Token non expiré, récupération de l\'utilisateur');

      // Récupérer l'utilisateur
      const user = await this.userRepository.findOne({
        where: { id: payload.sub },
      });

      if (!user) {
        this.logger.warn(`Utilisateur non trouvé pour le payload: ${payload.sub}`);
        throw new UnauthorizedException('Utilisateur non trouvé');
      }

      this.logger.debug(`Utilisateur trouvé: ${user.email} (ID: ${user.id})`);

      // Générer de nouveaux tokens
      this.logger.debug('Génération de nouveaux tokens');
      const tokens = await this.generateTokens(user);
      this.logger.debug('Nouveaux tokens générés avec succès');

      // Supprimer l'ancien refresh token
      this.logger.debug(`Suppression de l'ancien refresh token, ID: ${tokenRecord.id}`);
      await this.authTokenRepository.delete({ id: tokenRecord.id });

      this.logger.log(`Rafraîchissement de token réussi pour l'utilisateur: ${user.email} (ID: ${user.id})`);

      return tokens;
    } catch (error) {
      this.logger.error(`Erreur lors du rafraîchissement de token: ${error.message}`, error.stack);
      throw new UnauthorizedException('Token de rafraîchissement invalide');
    }
  }

  private async generateTokens(user: User) {
    this.logger.debug(`Génération de tokens pour l'utilisateur: ${user.email} (ID: ${user.id})`);
    
    const payload = { sub: user.id, email: user.email };
    this.logger.debug(`Payload JWT créé: ${JSON.stringify(payload)}`);

    // Générer access token (15 minutes)
    this.logger.debug('Génération du access token (15 minutes)');
    const accessToken = this.jwtService.sign(payload, {
      secret: process.env.JWT_SECRET || 'access-secret',
      expiresIn: '15m',
    });

    // Générer refresh token (7 jours)
    this.logger.debug('Génération du refresh token (7 jours)');
    const refreshToken = this.jwtService.sign(payload, {
      secret: process.env.JWT_REFRESH_SECRET || 'refresh-secret',
      expiresIn: '7d',
    });

    // Sauvegarder le refresh token en base (7 jours)
    this.logger.debug('Calcul de la date d\'expiration du refresh token');
    const refreshTokenExpiry = new Date();
    refreshTokenExpiry.setDate(refreshTokenExpiry.getDate() + 7);

    this.logger.debug('Sauvegarde du refresh token en base de données');
    const savedToken = await this.authTokenRepository.save({
      userId: user.id,
      token: refreshToken,
      type: 'refresh',
      expiresAt: refreshTokenExpiry,
    });
    this.logger.debug(`Refresh token sauvegardé, ID: ${savedToken.id}`);

    this.logger.debug('Génération des tokens terminée avec succès');

    return {
      accessToken,
      refreshToken,
    };
  }

  async validateUser(userId: string): Promise<User | null> {
    this.logger.debug(`Validation de l'utilisateur avec l'ID: ${userId}`);
    
    const user = await this.userRepository.findOne({
      where: { id: userId },
      relations: ['roles'],
    });

    if (user) {
      this.logger.debug(`Utilisateur validé: ${user.email} (ID: ${user.id})`);
      this.logger.debug(`Rôles de l'utilisateur ${user.email}: ${JSON.stringify(user.roles?.map(r => ({ id: r.id, name: r.name })))}`);
    } else {
      this.logger.debug(`Utilisateur non trouvé pour l'ID: ${userId}`);
    }

    return user;
  }

  async validateUserByCredentials(email: string, password: string): Promise<User | null> {
    this.logger.debug(`Validation des credentials pour l'email: ${email}`);
    
    const user = await this.userRepository.findOne({
      where: { email },
    });

    if (!user) {
      this.logger.debug(`Aucun utilisateur trouvé pour l'email: ${email}`);
      return null;
    }

    this.logger.debug(`Utilisateur trouvé, vérification du mot de passe pour: ${user.email}`);
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    
    if (isPasswordValid) {
      this.logger.debug(`Credentials validés pour l'utilisateur: ${user.email} (ID: ${user.id})`);
    } else {
      this.logger.debug(`Mot de passe incorrect pour l'utilisateur: ${user.email}`);
    }
    
    return isPasswordValid ? user : null;
  }
} 