"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
var AuthController_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const common_1 = require("@nestjs/common");
const auth_service_1 = require("./auth.service");
const dto_1 = require("./dto");
const jwt_auth_guard_1 = require("./guards/jwt-auth.guard");
const local_auth_guard_1 = require("./guards/local-auth.guard");
const current_user_decorator_1 = require("./decorators/current-user.decorator");
let AuthController = AuthController_1 = class AuthController {
    authService;
    logger = new common_1.Logger(AuthController_1.name);
    constructor(authService) {
        this.authService = authService;
        this.logger.log('AuthController initialisé');
    }
    async register(registerDto) {
        this.logger.log(`Requête d'inscription reçue pour l'email: ${registerDto.email}`);
        this.logger.debug(`Données d'inscription: ${JSON.stringify({ ...registerDto, password: '[MASKED]' })}`);
        try {
            const result = await this.authService.register(registerDto);
            this.logger.log(`Inscription réussie pour l'email: ${registerDto.email}`);
            return result;
        }
        catch (error) {
            this.logger.error(`Erreur lors de l'inscription pour l'email: ${registerDto.email}`, error.stack);
            throw error;
        }
    }
    async login(loginDto, req) {
        this.logger.log(`Requête de connexion reçue pour l'email: ${loginDto.email}`);
        this.logger.debug(`Données de connexion: ${JSON.stringify({ ...loginDto, password: '[MASKED]' })}`);
        try {
            const result = await this.authService.login(loginDto);
            this.logger.log(`Connexion réussie pour l'email: ${loginDto.email}`);
            return result;
        }
        catch (error) {
            this.logger.error(`Erreur lors de la connexion pour l'email: ${loginDto.email}`, error.stack);
            throw error;
        }
    }
    async logout(user) {
        this.logger.log(`Requête de déconnexion reçue pour l'utilisateur ID: ${user.id}`);
        this.logger.debug(`Utilisateur déconnecté: ${user.email} (ID: ${user.id})`);
        try {
            const result = await this.authService.logout(user.id);
            this.logger.log(`Déconnexion réussie pour l'utilisateur ID: ${user.id}`);
            return result;
        }
        catch (error) {
            this.logger.error(`Erreur lors de la déconnexion pour l'utilisateur ID: ${user.id}`, error.stack);
            throw error;
        }
    }
    async refreshToken(body) {
        this.logger.log('Requête de rafraîchissement de token reçue');
        this.logger.debug(`Refresh token reçu: ${body.refreshToken.substring(0, 20)}...`);
        try {
            const result = await this.authService.refreshToken(body.refreshToken);
            this.logger.log('Rafraîchissement de token réussi');
            return result;
        }
        catch (error) {
            this.logger.error('Erreur lors du rafraîchissement de token', error.stack);
            throw error;
        }
    }
    async getProfile(user) {
        this.logger.log(`Requête de profil reçue pour l'utilisateur ID: ${user.id}`);
        this.logger.debug(`Profil demandé pour: ${user.email} (ID: ${user.id})`);
        const fullUser = await this.authService.getUserWithRoles(user.id);
        return fullUser;
    }
};
exports.AuthController = AuthController;
__decorate([
    (0, common_1.Post)('register'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.RegisterDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "register", null);
__decorate([
    (0, common_1.UseGuards)(local_auth_guard_1.LocalAuthGuard),
    (0, common_1.Post)('login'),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.LoginDto, Object]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "login", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Post)('logout'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "logout", null);
__decorate([
    (0, common_1.Post)('refresh'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "refreshToken", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Get)('profile'),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "getProfile", null);
exports.AuthController = AuthController = AuthController_1 = __decorate([
    (0, common_1.Controller)('auth'),
    __metadata("design:paramtypes", [auth_service_1.AuthService])
], AuthController);
//# sourceMappingURL=auth.controller.js.map