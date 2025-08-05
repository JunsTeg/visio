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
Object.defineProperty(exports, "__esModule", { value: true });
exports.UsersService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const bcrypt = __importStar(require("bcryptjs"));
const entities_1 = require("../entities");
let UsersService = class UsersService {
    userRepository;
    roleRepository;
    constructor(userRepository, roleRepository) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
    }
    async findAll() {
        return this.userRepository.find({
            relations: ['roles'],
            select: ['id', 'fullName', 'email', 'phoneNumber', 'isVerified', 'createdAt'],
        });
    }
    async findOne(id) {
        const user = await this.userRepository.findOne({
            where: { id },
            relations: ['roles'],
            select: ['id', 'fullName', 'email', 'phoneNumber', 'isVerified', 'createdAt'],
        });
        if (!user) {
            throw new common_1.NotFoundException('Utilisateur non trouvé');
        }
        return user;
    }
    async create(createUserDto) {
        const { email, password, fullName, phoneNumber, isVerified = false, roleIds = [] } = createUserDto;
        const existingUser = await this.userRepository.findOne({
            where: { email },
        });
        if (existingUser) {
            throw new common_1.ConflictException('Un utilisateur avec cet email existe déjà');
        }
        const saltRounds = 12;
        const passwordHash = await bcrypt.hash(password, saltRounds);
        let roles = [];
        if (roleIds.length > 0) {
            roles = await this.roleRepository.find({
                where: roleIds.map(id => ({ id }))
            });
        }
        const user = this.userRepository.create({
            email,
            passwordHash,
            fullName,
            phoneNumber,
            isVerified,
            roles,
        });
        const savedUser = await this.userRepository.save(user);
        return this.findOne(savedUser.id);
    }
    async update(id, updateUserDto) {
        const user = await this.userRepository.findOne({
            where: { id },
            relations: ['roles'],
        });
        if (!user) {
            throw new common_1.NotFoundException('Utilisateur non trouvé');
        }
        const { email, password, fullName, phoneNumber, isVerified, roleIds } = updateUserDto;
        if (email && email !== user.email) {
            const existingUser = await this.userRepository.findOne({
                where: { email },
            });
            if (existingUser) {
                throw new common_1.ConflictException('Un utilisateur avec cet email existe déjà');
            }
            user.email = email;
        }
        if (fullName)
            user.fullName = fullName;
        if (phoneNumber !== undefined)
            user.phoneNumber = phoneNumber;
        if (isVerified !== undefined)
            user.isVerified = isVerified;
        if (password) {
            const saltRounds = 12;
            user.passwordHash = await bcrypt.hash(password, saltRounds);
        }
        if (roleIds !== undefined) {
            const roles = await this.roleRepository.find({
                where: roleIds.map(id => ({ id }))
            });
            user.roles = roles;
        }
        await this.userRepository.save(user);
        return this.findOne(id);
    }
    async remove(id) {
        const user = await this.userRepository.findOne({
            where: { id },
        });
        if (!user) {
            throw new common_1.NotFoundException('Utilisateur non trouvé');
        }
        await this.userRepository.remove(user);
        return { message: 'Utilisateur supprimé avec succès' };
    }
    async updateRoles(id, roleIds) {
        const user = await this.userRepository.findOne({
            where: { id },
            relations: ['roles'],
        });
        if (!user) {
            throw new common_1.NotFoundException('Utilisateur non trouvé');
        }
        const roles = await this.roleRepository.find({
            where: roleIds.map(id => ({ id }))
        });
        user.roles = roles;
        await this.userRepository.save(user);
        return this.findOne(id);
    }
};
exports.UsersService = UsersService;
exports.UsersService = UsersService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(entities_1.User)),
    __param(1, (0, typeorm_1.InjectRepository)(entities_1.Role)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository])
], UsersService);
//# sourceMappingURL=users.service.js.map