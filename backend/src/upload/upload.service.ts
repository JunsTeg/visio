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

  async storeAvatar(file: Express.Multer.File) {
    // Vérifier le type de fichier
    if (!file.mimetype.match(/^image\/(jpeg|jpg|png|gif|webp)$/)) {
      throw new BadRequestException('Seules les images sont autorisées');
    }

    // Vérifier la taille
    if (file.size > 5 * 1024 * 1024) {
      throw new BadRequestException('Fichier trop volumineux (max 5MB)');
    }

    // Générer un nom unique
    const timestamp = Date.now();
    const uniqueId = uuidv4().substring(0, 8);
    const extension = extname(file.originalname);
    const filename = `avatar_${timestamp}_${uniqueId}${extension}`;

    // Chemin de destination
    const uploadPath = path.join(process.cwd(), this.uploadsDir, this.avatarsDir);
    const filePath = path.join(uploadPath, filename);

    try {
      // Écrire le fichier
      fs.writeFileSync(filePath, file.buffer);
      
      // Générer l'URL
      const avatarUrl = this.generateAvatarUrl(filename);
      
      return {
        filename,
        originalName: file.originalname,
        size: file.size,
        mimetype: file.mimetype,
        avatarUrl,
      };
    } catch (error) {
      throw new BadRequestException(`Erreur lors de l'écriture du fichier: ${error.message}`);
    }
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
}
