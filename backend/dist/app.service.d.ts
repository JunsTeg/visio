import { DataSource } from 'typeorm';
export declare class AppService {
    private dataSource;
    constructor(dataSource: DataSource);
    getHello(): string;
    testDatabaseConnection(): Promise<{
        status: string;
        message: string;
    }>;
}
