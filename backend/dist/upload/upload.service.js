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
Object.defineProperty(exports, "__esModule", { value: true });
exports.UploadService = void 0;
const common_1 = require("@nestjs/common");
const multer_1 = require("multer");
const path_1 = require("path");
const uuid_1 = require("uuid");
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
let UploadService = class UploadService {
    uploadsDir = 'uploads';
    avatarsDir = 'avatars';
    constructor() {
        this.ensureDirectoriesExist();
    }
    ensureDirectoriesExist() {
        const uploadsPath = path.join(process.cwd(), this.uploadsDir);
        const avatarsPath = path.join(uploadsPath, this.avatarsDir);
        if (!fs.existsSync(uploadsPath)) {
            fs.mkdirSync(uploadsPath, { recursive: true });
        }
        if (!fs.existsSync(avatarsPath)) {
            fs.mkdirSync(avatarsPath, { recursive: true });
        }
    }
    getAvatarStorageConfig() {
        return {
            storage: (0, multer_1.diskStorage)({
                destination: (req, file, cb) => {
                    const uploadPath = path.join(process.cwd(), this.uploadsDir, this.avatarsDir);
                    cb(null, uploadPath);
                },
                filename: (req, file, cb) => {
                    const timestamp = Date.now();
                    const uniqueId = (0, uuid_1.v4)().substring(0, 8);
                    const extension = (0, path_1.extname)(file.originalname);
                    const filename = `avatar_${timestamp}_${uniqueId}${extension}`;
                    cb(null, filename);
                },
            }),
            fileFilter: (req, file, cb) => {
                if (!file.mimetype.match(/^image\/(jpeg|jpg|png|gif|webp)$/)) {
                    return cb(new common_1.BadRequestException('Seules les images sont autorisées'), false);
                }
                cb(null, true);
            },
            limits: {
                fileSize: 5 * 1024 * 1024,
            },
        };
    }
    generateAvatarUrl(filename) {
        const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
        return `${baseUrl}/${this.uploadsDir}/${this.avatarsDir}/${filename}`;
    }
    async deleteAvatarFile(filename) {
        try {
            const filePath = path.join(process.cwd(), this.uploadsDir, this.avatarsDir, filename);
            if (fs.existsSync(filePath)) {
                fs.unlinkSync(filePath);
            }
        }
        catch (error) {
            console.error('Erreur lors de la suppression du fichier avatar:', error);
        }
    }
    getAvatarFilePath(filename) {
        return path.join(process.cwd(), this.uploadsDir, this.avatarsDir, filename);
    }
};
exports.UploadService = UploadService;
exports.UploadService = UploadService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], UploadService);
//# sourceMappingURL=upload.service.js.map