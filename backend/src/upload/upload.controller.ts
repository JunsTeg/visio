import {
  Controller,
  Post,
  UseInterceptors,
  UploadedFile,
  UseGuards,
  BadRequestException,
  Req,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UploadService } from './upload.service';

@Controller('upload')
export class UploadController {
  constructor(private readonly uploadService: UploadService) {}

  private getBaseUrl(req: any): string | undefined {
    try {
      const proto = (req.headers['x-forwarded-proto'] as string) || req.protocol || 'http';
      const host = req.headers['host'] as string;
      if (host) {
        return `${proto}://${host}`;
      }
    } catch {}
    return undefined;
  }

  @Post('avatar/public')
  @UseInterceptors(FileInterceptor('avatar'))
  async uploadAvatarPublic(@UploadedFile() file: Express.Multer.File, @Req() req: any) {
    if (!file) {
      throw new BadRequestException('Aucun fichier fourni');
    }

    try {
      const baseUrl = this.getBaseUrl(req);
      const result = await this.uploadService.storeAvatar(file, baseUrl);
      return result;
    } catch (error) {
      throw new BadRequestException(`Erreur lors de l'upload: ${error.message}`);
    }
  }

  @Post('avatar')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FileInterceptor('avatar'))
  async uploadAvatar(@UploadedFile() file: Express.Multer.File, @Req() req: any) {
    if (!file) {
      throw new BadRequestException('Aucun fichier fourni');
    }

    try {
      const baseUrl = this.getBaseUrl(req);
      const result = await this.uploadService.storeAvatar(file, baseUrl);
      return result;
    } catch (error) {
      throw new BadRequestException(`Erreur lors de l'upload: ${error.message}`);
    }
  }
}
