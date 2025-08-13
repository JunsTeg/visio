import { UploadService } from './upload.service';
export declare class UploadController {
    private readonly uploadService;
    constructor(uploadService: UploadService);
    private getBaseUrl;
    uploadAvatarPublic(file: Express.Multer.File, req: any): Promise<{
        filename: string;
        originalName: string;
        size: number;
        mimetype: string;
        avatarUrl: string;
    }>;
    uploadAvatar(file: Express.Multer.File, req: any): Promise<{
        filename: string;
        originalName: string;
        size: number;
        mimetype: string;
        avatarUrl: string;
    }>;
}
