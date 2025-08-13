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
var UploadService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.UploadService = void 0;
const common_1 = require("@nestjs/common");
const path_1 = require("path");
const uuid_1 = require("uuid");
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
let UploadService = UploadService_1 = class UploadService {
    uploadsDir = 'uploads';
    avatarsDir = 'avatars';
    logger = new common_1.Logger(UploadService_1.name);
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
    async storeAvatar(file, baseUrlOverride) {
        const isImageMime = !!file.mimetype && /^image\//i.test(file.mimetype);
        const lowerExt = ((0, path_1.extname)(file.originalname) || '').toLowerCase();
        const allowedExt = new Set(['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.tif', '.tiff', '.ico', '.heic', '.heif', '.avif']);
        const isImageExt = allowedExt.has(lowerExt);
        const readHeader = () => {
            try {
                if (file.buffer && file.buffer.length > 0) {
                    return file.buffer.subarray(0, Math.min(file.buffer.length, 16));
                }
                const tempPath = file.path;
                if (tempPath && fs.existsSync(tempPath)) {
                    const fd = fs.openSync(tempPath, 'r');
                    const buf = Buffer.alloc(16);
                    fs.readSync(fd, buf, 0, 16, 0);
                    fs.closeSync(fd);
                    return buf;
                }
            }
            catch {
                return null;
            }
            return null;
        };
        const header = readHeader();
        const toStr = (b, start, len) => b.subarray(start, start + len).toString('ascii');
        let magicIsImage = false;
        let inferredExt;
        if (header) {
            if (header[0] === 0xff && header[1] === 0xd8 && header[2] === 0xff) {
                magicIsImage = true;
                inferredExt = 'jpg';
            }
            else if (header.length >= 8 && header[0] === 0x89 && toStr(header, 1, 3) === 'PNG') {
                magicIsImage = true;
                inferredExt = 'png';
            }
            else if (toStr(header, 0, 4) === 'GIF8') {
                magicIsImage = true;
                inferredExt = 'gif';
            }
            else if (toStr(header, 0, 4) === 'RIFF' && header.length >= 12 && toStr(header, 8, 4) === 'WEBP') {
                magicIsImage = true;
                inferredExt = 'webp';
            }
            else if (toStr(header, 0, 2) === 'BM') {
                magicIsImage = true;
                inferredExt = 'bmp';
            }
            else if ((header[0] === 0x49 && header[1] === 0x49 && header[2] === 0x2a && header[3] === 0x00) || (header[0] === 0x4d && header[1] === 0x4d && header[2] === 0x00 && header[3] === 0x2a)) {
                magicIsImage = true;
                inferredExt = 'tif';
            }
            else if (header[0] === 0x00 && header[1] === 0x00 && header[2] === 0x01 && header[3] === 0x00) {
                magicIsImage = true;
                inferredExt = 'ico';
            }
            else if (header.length >= 12 && toStr(header, 4, 4) === 'ftyp') {
                const brand = toStr(header, 8, 4).toLowerCase();
                if (brand.includes('heic') || brand.includes('heif')) {
                    magicIsImage = true;
                    inferredExt = 'heic';
                }
                else if (brand.includes('avif')) {
                    magicIsImage = true;
                    inferredExt = 'avif';
                }
                else {
                    magicIsImage = true;
                }
            }
        }
        if (!isImageMime && !isImageExt && !magicIsImage) {
            this.logger.warn(`Upload rejeté - mimetype: ${file.mimetype}, original: ${file.originalname}`);
            throw new common_1.BadRequestException('Seules les images sont autorisées');
        }
        if (file.size > 9 * 1024 * 1024) {
            throw new common_1.BadRequestException('Fichier trop volumineux (max 9MB)');
        }
        const timestamp = Date.now();
        const uniqueId = (0, uuid_1.v4)().substring(0, 8);
        const chosenExt = lowerExt || (inferredExt ? `.${inferredExt}` : '');
        const filename = `avatar_${timestamp}_${uniqueId}${chosenExt}`;
        const uploadPath = path.join(process.cwd(), this.uploadsDir, this.avatarsDir);
        const filePath = path.join(uploadPath, filename);
        try {
            if (file.buffer && file.buffer.length > 0) {
                fs.writeFileSync(filePath, file.buffer);
            }
            else if (file.path && fs.existsSync(file.path)) {
                const tempPath = file.path;
                try {
                    fs.renameSync(tempPath, filePath);
                }
                catch {
                    fs.copyFileSync(tempPath, filePath);
                    try {
                        fs.unlinkSync(tempPath);
                    }
                    catch { }
                }
            }
            else {
                throw new common_1.BadRequestException('Fichier non disponible pour l\'écriture');
            }
            const avatarUrl = this.generateAvatarUrl(filename, baseUrlOverride);
            return {
                filename,
                originalName: file.originalname,
                size: file.size,
                mimetype: file.mimetype,
                avatarUrl,
            };
        }
        catch (error) {
            throw new common_1.BadRequestException(`Erreur lors de l'écriture du fichier: ${error.message}`);
        }
    }
    generateAvatarUrl(filename, baseUrlOverride) {
        const baseUrl = baseUrlOverride || process.env.BASE_URL || 'http://localhost:3000';
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
};
exports.UploadService = UploadService;
exports.UploadService = UploadService = UploadService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], UploadService);
//# sourceMappingURL=upload.service.js.map