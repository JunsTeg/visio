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
var JwtAuthGuard_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.JwtAuthGuard = void 0;
const common_1 = require("@nestjs/common");
const passport_1 = require("@nestjs/passport");
let JwtAuthGuard = JwtAuthGuard_1 = class JwtAuthGuard extends (0, passport_1.AuthGuard)('jwt') {
    logger = new common_1.Logger(JwtAuthGuard_1.name);
    constructor() {
        super();
        this.logger.log('JwtAuthGuard initialisé');
    }
    handleRequest(err, user, info, context, status) {
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
        }
        else {
            this.logger.debug(`JwtAuthGuard - Utilisateur authentifié: ${user.email} (ID: ${user.id})`);
        }
        return super.handleRequest(err, user, info, context, status);
    }
};
exports.JwtAuthGuard = JwtAuthGuard;
exports.JwtAuthGuard = JwtAuthGuard = JwtAuthGuard_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], JwtAuthGuard);
//# sourceMappingURL=jwt-auth.guard.js.map