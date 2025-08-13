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
var RolesGuard_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.RolesGuard = void 0;
const common_1 = require("@nestjs/common");
const core_1 = require("@nestjs/core");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const entities_1 = require("../../entities");
let RolesGuard = RolesGuard_1 = class RolesGuard {
    reflector;
    userRepository;
    roleRepository;
    logger = new common_1.Logger(RolesGuard_1.name);
    constructor(reflector, userRepository, roleRepository) {
        this.reflector = reflector;
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.logger.log('RolesGuard initialisé');
    }
    async canActivate(context) {
        const requiredRoles = this.reflector.get('roles', context.getHandler());
        this.logger.debug(`Vérification des rôles - Rôles requis: ${JSON.stringify(requiredRoles)}`);
        if (!requiredRoles) {
            this.logger.debug('Aucun rôle requis, accès autorisé');
            return true;
        }
        const request = context.switchToHttp().getRequest();
        const user = request.user;
        if (!user) {
            this.logger.warn('RolesGuard - Utilisateur non authentifié');
            throw new common_1.ForbiddenException('Utilisateur non authentifié');
        }
        this.logger.debug(`Vérification des rôles pour l'utilisateur: ${user.email} (ID: ${user.id})`);
        this.logger.debug('Récupération de l\'utilisateur avec ses rôles');
        const userWithRoles = await this.userRepository.findOne({
            where: { id: user.id },
            relations: ['roles'],
        });
        if (!userWithRoles) {
            this.logger.warn(`RolesGuard - Utilisateur non trouvé en base pour l'ID: ${user.id}`);
            throw new common_1.ForbiddenException('Utilisateur non trouvé');
        }
        const userRoles = userWithRoles.roles.map(role => role.name);
        this.logger.debug(`Rôles de l'utilisateur: ${JSON.stringify(userRoles)}`);
        const hasRequiredRole = requiredRoles.some(role => userRoles.includes(role));
        this.logger.debug(`L'utilisateur a-t-il les rôles requis? ${hasRequiredRole}`);
        if (!hasRequiredRole) {
            this.logger.warn(`Permissions insuffisantes - Utilisateur: ${user.email}, Rôles: ${userRoles}, Requis: ${requiredRoles}`);
            throw new common_1.ForbiddenException('Permissions insuffisantes');
        }
        this.logger.debug(`Accès autorisé pour l'utilisateur: ${user.email} avec les rôles: ${userRoles}`);
        return true;
    }
};
exports.RolesGuard = RolesGuard;
exports.RolesGuard = RolesGuard = RolesGuard_1 = __decorate([
    (0, common_1.Injectable)(),
    __param(1, (0, typeorm_1.InjectRepository)(entities_1.User)),
    __param(2, (0, typeorm_1.InjectRepository)(entities_1.Role)),
    __metadata("design:paramtypes", [core_1.Reflector,
        typeorm_2.Repository,
        typeorm_2.Repository])
], RolesGuard);
//# sourceMappingURL=roles.guard.js.map