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
var JwtStrategy_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.JwtStrategy = void 0;
const common_1 = require("@nestjs/common");
const passport_1 = require("@nestjs/passport");
const passport_jwt_1 = require("passport-jwt");
const auth_service_1 = require("../auth.service");
let JwtStrategy = JwtStrategy_1 = class JwtStrategy extends (0, passport_1.PassportStrategy)(passport_jwt_1.Strategy) {
    authService;
    logger = new common_1.Logger(JwtStrategy_1.name);
    constructor(authService) {
        super({
            jwtFromRequest: passport_jwt_1.ExtractJwt.fromAuthHeaderAsBearerToken(),
            ignoreExpiration: false,
            secretOrKey: process.env.JWT_SECRET || 'access-secret',
        });
        this.authService = authService;
        this.logger.log('JwtStrategy initialisée');
    }
    async validate(payload) {
        this.logger.debug(`Validation JWT - Payload reçu: ${JSON.stringify(payload)}`);
        this.logger.debug(`Validation JWT - User ID extrait: ${payload.sub}`);
        const user = await this.authService.validateUser(payload.sub);
        if (!user) {
            this.logger.warn(`Validation JWT échouée - Utilisateur non trouvé pour l'ID: ${payload.sub}`);
            throw new common_1.UnauthorizedException('Utilisateur non trouvé');
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
};
exports.JwtStrategy = JwtStrategy;
exports.JwtStrategy = JwtStrategy = JwtStrategy_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [auth_service_1.AuthService])
], JwtStrategy);
//# sourceMappingURL=jwt.strategy.js.map