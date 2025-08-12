export declare class UploadService {
    private readonly uploadsDir;
    private readonly avatarsDir;
    constructor();
    private ensureDirectoriesExist;
    getAvatarStorageConfig(): {
        storage: import("multer").StorageEngine;
        fileFilter: (req: any, file: any, cb: any) => any;
        limits: {
            fileSize: number;
        };
    };
    generateAvatarUrl(filename: string): string;
    deleteAvatarFile(filename: string): Promise<void>;
    getAvatarFilePath(filename: string): string;
}
