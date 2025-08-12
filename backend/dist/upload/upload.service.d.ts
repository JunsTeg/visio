export declare class UploadService {
    private readonly uploadsDir;
    private readonly avatarsDir;
    constructor();
    private ensureDirectoriesExist;
    storeAvatar(file: Express.Multer.File): Promise<{
        filename: string;
        originalName: string;
        size: number;
        mimetype: string;
        avatarUrl: string;
    }>;
    generateAvatarUrl(filename: string): string;
    deleteAvatarFile(filename: string): Promise<void>;
}
