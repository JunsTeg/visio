import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { v4 as uuidv4 } from 'uuid';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class UploadService {
  private readonly uploadsDir = 'uploads';
  private readonly avatarsDir = 'avatars';
  private readonly logger = new Logger(UploadService.name);

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

  async storeAvatar(file: Express.Multer.File, baseUrlOverride?: string) {
    // Vérifier le type de fichier: autoriser tout image/* et extensions d'images communes (utile si mimetype est octet-stream)
    const isImageMime = !!file.mimetype && /^image\//i.test(file.mimetype);
    const lowerExt = (extname(file.originalname) || '').toLowerCase();
    const allowedExt = new Set(['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.tif', '.tiff', '.ico', '.heic', '.heif', '.avif']);
    const isImageExt = allowedExt.has(lowerExt);

    // Détection par signature magique (fallback)
    const readHeader = (): Buffer | null => {
      try {
        if (file.buffer && file.buffer.length > 0) {
          return file.buffer.subarray(0, Math.min(file.buffer.length, 16));
        }
        const tempPath = (file as any).path as string | undefined;
        if (tempPath && fs.existsSync(tempPath)) {
          const fd = fs.openSync(tempPath, 'r');
          const buf = Buffer.alloc(16);
          fs.readSync(fd, buf, 0, 16, 0);
          fs.closeSync(fd);
          return buf;
        }
      } catch {
        return null;
      }
      return null;
    };

    const header = readHeader();
    const toStr = (b: Buffer, start: number, len: number) => b.subarray(start, start + len).toString('ascii');
    let magicIsImage = false;
    let inferredExt: string | undefined;
    if (header) {
      // JPEG FF D8 FF
      if (header[0] === 0xff && header[1] === 0xd8 && header[2] === 0xff) {
        magicIsImage = true; inferredExt = 'jpg';
      }
      // PNG 89 50 4E 47 0D 0A 1A 0A
      else if (header.length >= 8 && header[0] === 0x89 && toStr(header,1,3) === 'PNG') {
        magicIsImage = true; inferredExt = 'png';
      }
      // GIF 'GIF8'
      else if (toStr(header,0,4) === 'GIF8') {
        magicIsImage = true; inferredExt = 'gif';
      }
      // WEBP 'RIFF' ... 'WEBP'
      else if (toStr(header,0,4) === 'RIFF' && header.length >= 12 && toStr(header,8,4) === 'WEBP') {
        magicIsImage = true; inferredExt = 'webp';
      }
      // BMP 'BM'
      else if (toStr(header,0,2) === 'BM') {
        magicIsImage = true; inferredExt = 'bmp';
      }
      // TIFF II*\0 or MM\0*
      else if ((header[0] === 0x49 && header[1] === 0x49 && header[2] === 0x2a && header[3] === 0x00) || (header[0] === 0x4d && header[1] === 0x4d && header[2] === 0x00 && header[3] === 0x2a)) {
        magicIsImage = true; inferredExt = 'tif';
      }
      // ICO 00 00 01 00
      else if (header[0] === 0x00 && header[1] === 0x00 && header[2] === 0x01 && header[3] === 0x00) {
        magicIsImage = true; inferredExt = 'ico';
      }
      // ISO-BMFF 'ftyp' at offset 4 (HEIC/AVIF variants)
      else if (header.length >= 12 && toStr(header,4,4) === 'ftyp') {
        const brand = toStr(header,8,4).toLowerCase();
        if (brand.includes('heic') || brand.includes('heif')) { magicIsImage = true; inferredExt = 'heic'; }
        else if (brand.includes('avif')) { magicIsImage = true; inferredExt = 'avif'; }
        else { magicIsImage = true; }
      }
    }

    if (!isImageMime && !isImageExt && !magicIsImage) {
      this.logger.warn(`Upload rejeté - mimetype: ${file.mimetype}, original: ${file.originalname}`);
      throw new BadRequestException('Seules les images sont autorisées');
    }

    // Vérifier la taille
    if (file.size > 9 * 1024 * 1024) {
      throw new BadRequestException('Fichier trop volumineux (max 9MB)');
    }

    // Générer un nom unique
    const timestamp = Date.now();
    const uniqueId = uuidv4().substring(0, 8);
    const chosenExt = lowerExt || (inferredExt ? `.${inferredExt}` : '');
    const filename = `avatar_${timestamp}_${uniqueId}${chosenExt}`;

    // Chemin de destination
    const uploadPath = path.join(process.cwd(), this.uploadsDir, this.avatarsDir);
    const filePath = path.join(uploadPath, filename);

    try {
      // Écrire le fichier depuis buffer (memoryStorage) ou déplacer/copier depuis un chemin temporaire (diskStorage)
      if (file.buffer && file.buffer.length > 0) {
        fs.writeFileSync(filePath, file.buffer);
      } else if ((file as any).path && fs.existsSync((file as any).path)) {
        const tempPath = (file as any).path as string;
        try {
          fs.renameSync(tempPath, filePath);
        } catch {
          fs.copyFileSync(tempPath, filePath);
          try { fs.unlinkSync(tempPath); } catch {}
        }
      } else {
        throw new BadRequestException('Fichier non disponible pour l\'écriture');
      }
      
      // Générer l'URL
      const avatarUrl = this.generateAvatarUrl(filename, baseUrlOverride);
      
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

  generateAvatarUrl(filename: string, baseUrlOverride?: string): string {
    const baseUrl = baseUrlOverride || process.env.BASE_URL || 'http://localhost:3000';
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
