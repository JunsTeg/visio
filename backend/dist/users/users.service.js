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
const upload_service_1 = require("../upload/upload.service");
let UsersService = class UsersService {
    userRepository;
    roleRepository;
    uploadService;
    constructor(userRepository, roleRepository, uploadService) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.uploadService = uploadService;
    }
    async findAll({ page = 1, limit = 20, search, role, active, online }) {
        const query = this.userRepository.createQueryBuilder('user')
            .leftJoinAndSelect('user.roles', 'userRoles');
        if (search) {
            query.andWhere('user.fullName ILIKE :search OR user.email ILIKE :search', { search: `%${search}%` });
        }
        if (role) {
            query.andWhere('userRoles.name = :role', { role });
        }
        if (active !== undefined) {
            query.andWhere('user.active = :active', { active: active === 'true' });
        }
        if (online !== undefined) {
            query.andWhere('user.online = :online', { online: online === 'true' });
        }
        const [data, total] = await query
            .skip((page - 1) * limit)
            .take(limit)
            .getManyAndCount();
        return { data, total, page: Number(page), limit: Number(limit) };
    }
    async findOne(id) {
        const user = await this.userRepository.findOne({
            where: { id },
            relations: ['roles'],
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
        const { email, password, fullName, phoneNumber, isVerified, roleIds, avatarUrl } = updateUserDto;
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
        if (avatarUrl !== undefined)
            user.avatarUrl = avatarUrl;
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
        user.active = false;
        user.online = false;
        await this.userRepository.save(user);
        return { message: 'Utilisateur désactivé avec succès' };
    }
    async activate(id) {
        const user = await this.userRepository.findOne({ where: { id } });
        if (!user) {
            throw new common_1.NotFoundException('Utilisateur non trouvé');
        }
        user.active = true;
        user.online = false;
        await this.userRepository.save(user);
        return { message: 'Utilisateur réactivé avec succès' };
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
    async getMe(userId) {
        return this.findOne(userId);
    }
    async updateMe(userId, updateProfileDto) {
        const user = await this.userRepository.findOne({
            where: { id: userId },
            relations: ['roles'],
        });
        if (!user) {
            throw new common_1.NotFoundException('Utilisateur non trouvé');
        }
        const { email, password, fullName, phoneNumber, avatarUrl } = updateProfileDto;
        if (email && email !== user.email) {
            const existingUser = await this.userRepository.findOne({ where: { email } });
            if (existingUser) {
                throw new common_1.ConflictException('Un utilisateur avec cet email existe déjà');
            }
            user.email = email;
        }
        if (fullName)
            user.fullName = fullName;
        if (phoneNumber !== undefined)
            user.phoneNumber = phoneNumber;
        if (avatarUrl !== undefined)
            user.avatarUrl = avatarUrl;
        if (password) {
            const saltRounds = 12;
            user.passwordHash = await bcrypt.hash(password, saltRounds);
        }
        await this.userRepository.save(user);
        return this.findOne(userId);
    }
    async deleteMyAvatar(userId) {
        const user = await this.userRepository.findOne({ where: { id: userId } });
        if (!user) {
            throw new common_1.NotFoundException('Utilisateur non trouvé');
        }
        if (user.avatarUrl) {
            const filename = user.avatarUrl.split('/').pop();
            if (filename) {
                await this.uploadService.deleteAvatarFile(filename);
            }
        }
        user.avatarUrl = null;
        await this.userRepository.save(user);
        return this.findOne(userId);
    }
    async getRoles() {
        return this.roleRepository.find();
    }
};
exports.UsersService = UsersService;
exports.UsersService = UsersService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(entities_1.User)),
    __param(1, (0, typeorm_1.InjectRepository)(entities_1.Role)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        upload_service_1.UploadService])
], UsersService);
//# sourceMappingURL=users.service.js.map