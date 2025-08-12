import { Injectable, BadRequestException } from '@nestjs/common';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { v4 as uuidv4 } from 'uuid';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class UploadService {
  private readonly uploadsDir = 'uploads';
  private readonly avatarsDir = 'avatars';

  constructor() {
    this.ensureDirectoriesExist();
  }

  private ensureDirectoriesExist() {
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
      storage: diskStorage({
        destination: (req, file, cb) => {
          const uploadPath = path.join(process.cwd(), this.uploadsDir, this.avatarsDir);
          cb(null, uploadPath);
        },
        filename: (req, file, cb) => {
          // Générer un nom unique avec timestamp
          const timestamp = Date.now();
          const uniqueId = uuidv4().substring(0, 8);
          const extension = extname(file.originalname);
          const filename = `avatar_${timestamp}_${uniqueId}${extension}`;
          cb(null, filename);
        },
      }),
      fileFilter: (req, file, cb) => {
        // Vérifier le type de fichier
        if (!file.mimetype.match(/^image\/(jpeg|jpg|png|gif|webp)$/)) {
          return cb(new BadRequestException('Seules les images sont autorisées'), false);
        }
        cb(null, true);
      },
      limits: {
        fileSize: 5 * 1024 * 1024, // 5MB max
      },
    };
  }

  generateAvatarUrl(filename: string): string {
    const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
    return `${baseUrl}/${this.uploadsDir}/${this.avatarsDir}/${filename}`;
  }

  async deleteAvatarFile(filename: string): Promise<void> {
    try {
      const filePath = path.join(process.cwd(), this.uploadsDir, this.avatarsDir, filename);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    } catch (error) {
      console.error('Erreur lors de la suppression du fichier avatar:', error);
    }
  }

  getAvatarFilePath(filename: string): string {
    return path.join(process.cwd(), this.uploadsDir, this.avatarsDir, filename);
  }
}
