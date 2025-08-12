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

    try {
      const result = await this.uploadService.storeAvatar(file);
      return result;
    } catch (error) {
      throw new BadRequestException(`Erreur lors de l'upload: ${error.message}`);
    }
  }

  @Post('avatar')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FileInterceptor('avatar'))
  async uploadAvatar(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('Aucun fichier fourni');
    }

    try {
      const result = await this.uploadService.storeAvatar(file);
      return result;
    } catch (error) {
      throw new BadRequestException(`Erreur lors de l'upload: ${error.message}`);
    }
  }
}
