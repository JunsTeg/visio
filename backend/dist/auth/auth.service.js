"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
var AuthService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const jwt_1 = require("@nestjs/jwt");
const bcrypt = __importStar(require("bcryptjs"));
const entities_1 = require("../entities");
let AuthService = AuthService_1 = class AuthService {
    userRepository;
    authTokenRepository;
    jwtService;
    logger = new common_1.Logger(AuthService_1.name);
    constructor(userRepository, authTokenRepository, jwtService) {
        this.userRepository = userRepository;
        this.authTokenRepository = authTokenRepository;
        this.jwtService = jwtService;
        this.logger.log('AuthService initialisé');
    }
    async register(registerDto) {
        this.logger.log(`Tentative d'inscription pour l'email: ${registerDto.email}`);
        const { email, password, fullName, phoneNumber } = registerDto;
        this.logger.debug(`Vérification de l'existence de l'utilisateur avec l'email: ${email}`);
        const existingUser = await this.userRepository.findOne({
            where: { email },
        });
        if (existingUser) {
            this.logger.warn(`Tentative d'inscription avec un email déjà existant: ${email}`);
            throw new common_1.ConflictException('Un utilisateur avec cet email existe déjà');
        }
        this.logger.debug('Aucun utilisateur existant trouvé, procédure d\'inscription en cours');
        this.logger.debug('Hachage du mot de passe en cours...');
        const saltRounds = 12;
        const passwordHash = await bcrypt.hash(password, saltRounds);
        this.logger.debug('Mot de passe haché avec succès');
        this.logger.debug('Création de l\'entité utilisateur');
        const user = this.userRepository.create({
            email,
            passwordHash,
            fullName,
            phoneNumber,
            isVerified: false,
        });
        this.logger.debug('Sauvegarde de l\'utilisateur en base de données');
        const savedUser = await this.userRepository.save(user);
        this.logger.log(`Utilisateur créé avec succès, ID: ${savedUser.id}`);
        this.logger.debug('Génération des tokens d\'authentification');
        const tokens = await this.generateTokens(savedUser);
        this.logger.debug('Tokens générés avec succès');
        this.logger.log(`Inscription réussie pour l'utilisateur: ${savedUser.email} (ID: ${savedUser.id})`);
        return {
            user: {
                id: savedUser.id,
                email: savedUser.email,
                fullName: savedUser.fullName,
                phoneNumber: savedUser.phoneNumber,
                isVerified: savedUser.isVerified,
                roles: savedUser.roles || [],
            },
            ...tokens,
        };
    }
    async login(loginDto) {
        this.logger.log(`Tentative de connexion pour l'email: ${loginDto.email}`);
        const { email, password } = loginDto;
        this.logger.debug(`Recherche de l'utilisateur avec l'email: ${email}`);
        const user = await this.userRepository.findOne({
            where: { email },
        });
        if (!user) {
            this.logger.warn(`Tentative de connexion avec un email inexistant: ${email}`);
            throw new common_1.UnauthorizedException('Email ou mot de passe incorrect');
        }
        this.logger.debug(`Utilisateur trouvé, ID: ${user.id}, vérification du mot de passe`);
        const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
        if (!isPasswordValid) {
            this.logger.warn(`Mot de passe incorrect pour l'utilisateur: ${email}`);
            throw new common_1.UnauthorizedException('Email ou mot de passe incorrect');
        }
        if (!user.active) {
            this.logger.warn(`Tentative de connexion pour un compte désactivé: ${email}`);
            throw new common_1.UnauthorizedException('Compte désactivé. Veuillez contacter le support.');
        }
        this.logger.debug('Mot de passe validé avec succès');
        user.lastLogin = new Date();
        user.online = true;
        await this.userRepository.save(user);
        const userWithRoles = await this.userRepository.findOne({
            where: { id: user.id },
            relations: ['roles'],
        });
        this.logger.debug('Génération des tokens d\'authentification');
        const tokens = await this.generateTokens(user);
        this.logger.debug('Tokens générés avec succès');
        this.logger.log(`Connexion réussie pour l'utilisateur: ${user.email} (ID: ${user.id})`);
        return {
            user: {
                id: userWithRoles.id,
                email: userWithRoles.email,
                fullName: userWithRoles.fullName,
                phoneNumber: userWithRoles.phoneNumber,
                isVerified: userWithRoles.isVerified,
                createdAt: userWithRoles.createdAt,
                lastLogin: userWithRoles.lastLogin,
                active: userWithRoles.active,
                online: userWithRoles.online,
                roles: userWithRoles.roles,
            },
            ...tokens,
        };
    }
    async logout(userId) {
        this.logger.log(`Tentative de déconnexion pour l'utilisateur ID: ${userId}`);
        await this.userRepository.update(userId, { online: false });
        this.logger.debug(`Suppression des tokens pour l'utilisateur ID: ${userId}`);
        const deleteResult = await this.authTokenRepository.delete({ userId });
        this.logger.debug(`Tokens supprimés: ${deleteResult.affected} tokens supprimés`);
        this.logger.log(`Déconnexion réussie pour l'utilisateur ID: ${userId}`);
        return { message: 'Déconnexion réussie' };
    }
    async refreshToken(refreshToken) {
        this.logger.log('Tentative de rafraîchissement de token');
        this.logger.debug(`Refresh token reçu: ${refreshToken.substring(0, 20)}...`);
        try {
            this.logger.debug('Vérification du refresh token JWT');
            const payload = this.jwtService.verify(refreshToken, {
                secret: process.env.JWT_REFRESH_SECRET || 'refresh-secret',
            });
            this.logger.debug(`Payload JWT extrait, user ID: ${payload.sub}`);
            this.logger.debug('Vérification de l\'existence du token en base de données');
            const tokenRecord = await this.authTokenRepository.findOne({
                where: { token: refreshToken, type: 'refresh' },
            });
            if (!tokenRecord) {
                this.logger.warn('Refresh token non trouvé en base de données');
                throw new common_1.UnauthorizedException('Token de rafraîchissement invalide');
            }
            this.logger.debug(`Token trouvé en base, ID: ${tokenRecord.id}, expiration: ${tokenRecord.expiresAt}`);
            if (new Date() > tokenRecord.expiresAt) {
                this.logger.warn(`Refresh token expiré, ID: ${tokenRecord.id}`);
                await this.authTokenRepository.delete({ id: tokenRecord.id });
                throw new common_1.UnauthorizedException('Token de rafraîchissement expiré');
            }
            this.logger.debug('Token non expiré, récupération de l\'utilisateur');
            const user = await this.userRepository.findOne({
                where: { id: payload.sub },
            });
            if (!user) {
                this.logger.warn(`Utilisateur non trouvé pour le payload: ${payload.sub}`);
                throw new common_1.UnauthorizedException('Utilisateur non trouvé');
            }
            this.logger.debug(`Utilisateur trouvé: ${user.email} (ID: ${user.id})`);
            this.logger.debug('Génération de nouveaux tokens');
            const tokens = await this.generateTokens(user);
            this.logger.debug('Nouveaux tokens générés avec succès');
            this.logger.debug(`Suppression de l'ancien refresh token, ID: ${tokenRecord.id}`);
            await this.authTokenRepository.delete({ id: tokenRecord.id });
            const userWithRoles = await this.userRepository.findOne({
                where: { id: user.id },
                relations: ['roles'],
            });
            this.logger.log(`Rafraîchissement de token réussi pour l'utilisateur: ${user.email} (ID: ${user.id})`);
            return {
                ...tokens,
                user: {
                    id: userWithRoles.id,
                    email: userWithRoles.email,
                    fullName: userWithRoles.fullName,
                    phoneNumber: userWithRoles.phoneNumber,
                    isVerified: userWithRoles.isVerified,
                    createdAt: userWithRoles.createdAt,
                    lastLogin: userWithRoles.lastLogin,
                    active: userWithRoles.active,
                    online: userWithRoles.online,
                    roles: userWithRoles.roles,
                },
            };
        }
        catch (error) {
            this.logger.error(`Erreur lors du rafraîchissement de token: ${error.message}`, error.stack);
            throw new common_1.UnauthorizedException('Token de rafraîchissement invalide');
        }
    }
    async generateTokens(user) {
        this.logger.debug(`Génération de tokens pour l'utilisateur: ${user.email} (ID: ${user.id})`);
        const payload = { sub: user.id, email: user.email };
        this.logger.debug(`Payload JWT créé: ${JSON.stringify(payload)}`);
        this.logger.debug('Génération du access token (15 minutes)');
        const accessToken = this.jwtService.sign(payload, {
            secret: process.env.JWT_SECRET || 'access-secret',
            expiresIn: '15m',
        });
        this.logger.debug('Génération du refresh token (7 jours)');
        const refreshToken = this.jwtService.sign(payload, {
            secret: process.env.JWT_REFRESH_SECRET || 'refresh-secret',
            expiresIn: '7d',
        });
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
    async validateUser(userId) {
        this.logger.debug(`Validation de l'utilisateur avec l'ID: ${userId}`);
        const user = await this.userRepository.findOne({
            where: { id: userId },
            relations: ['roles'],
        });
        if (user) {
            this.logger.debug(`Utilisateur validé: ${user.email} (ID: ${user.id})`);
        }
        else {
            this.logger.debug(`Utilisateur non trouvé pour l'ID: ${userId}`);
        }
        return user;
    }
    async validateUserByCredentials(email, password) {
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
        }
        else {
            this.logger.debug(`Mot de passe incorrect pour l'utilisateur: ${user.email}`);
        }
        return isPasswordValid ? user : null;
    }
    async getUserWithRoles(userId) {
        this.logger.debug(`Récupération de l'utilisateur avec rôles pour l'ID: ${userId}`);
        const user = await this.userRepository.findOne({
            where: { id: userId },
            relations: ['roles'],
        });
        if (!user) {
            this.logger.warn(`Utilisateur non trouvé pour l'ID: ${userId}`);
            throw new common_1.UnauthorizedException('Utilisateur non trouvé');
        }
        this.logger.debug(`Utilisateur récupéré avec ${user.roles?.length || 0} rôles`);
        return user;
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = AuthService_1 = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(entities_1.User)),
    __param(1, (0, typeorm_1.InjectRepository)(entities_1.AuthToken)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        jwt_1.JwtService])
], AuthService);
//# sourceMappingURL=auth.service.js.map