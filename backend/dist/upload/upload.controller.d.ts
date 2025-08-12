import { UploadService } from './upload.service';
export declare class UploadController {
    private readonly uploadService;
    constructor(uploadService: UploadService);
    uploadAvatarPublic(file: Express.Multer.File): Promise<unknown>;
    uploadAvatar(file: Express.Multer.File): Promise<unknown>;
}
