export declare class UploadService {
    private readonly uploadsDir;
    private readonly avatarsDir;
    private readonly logger;
    constructor();
    private ensureDirectoriesExist;
    storeAvatar(file: Express.Multer.File, baseUrlOverride?: string): Promise<{
        filename: string;
        originalName: string;
        size: number;
        mimetype: string;
        avatarUrl: string;
    }>;
    generateAvatarUrl(filename: string, baseUrlOverride?: string): string;
    deleteAvatarFile(filename: string): Promise<void>;
}
