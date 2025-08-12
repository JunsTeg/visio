import {
  Controller,
  Post,
  UseInterceptors,
  UploadedFile,
  UseGuards,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UploadService } from './upload.service';

@Controller('upload')
export class UploadController {
  constructor(private readonly uploadService: UploadService) {}

  @Post('avatar/public')
  @UseInterceptors(FileInterceptor('avatar'))
  async uploadAvatarPublic(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('Aucun fichier fourni');
    }

    // Configurer le stockage
    const storageConfig = this.uploadService.getAvatarStorageConfig();
    const multerStorage = storageConfig.storage;

    // Stocker le fichier
    return new Promise((resolve, reject) => {
      multerStorage._handleFile(
        { file } as any,
        file,
        (error: any, info: any) => {
          if (error) {
            reject(error);
            return;
          }

          // Générer l'URL de l'avatar
          const avatarUrl = this.uploadService.generateAvatarUrl(file.filename);
          
          resolve({
            filename: file.filename,
            originalName: file.originalname,
            size: file.size,
            mimetype: file.mimetype,
            avatarUrl,
          });
        },
      );
    });
  }

  @Post('avatar')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FileInterceptor('avatar'))
  async uploadAvatar(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('Aucun fichier fourni');
    }

    // Configurer le stockage
    const storageConfig = this.uploadService.getAvatarStorageConfig();
    const multerStorage = storageConfig.storage;

    // Stocker le fichier
    return new Promise((resolve, reject) => {
      multerStorage._handleFile(
        { file } as any,
        file,
        (error: any, info: any) => {
          if (error) {
            reject(error);
            return;
          }

          // Générer l'URL de l'avatar
          const avatarUrl = this.uploadService.generateAvatarUrl(file.filename);
          
          resolve({
            filename: file.filename,
            originalName: file.originalname,
            size: file.size,
            mimetype: file.mimetype,
            avatarUrl,
          });
        },
      );
    });
  }
}
