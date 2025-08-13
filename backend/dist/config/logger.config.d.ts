import { LoggerService } from '@nestjs/common';
export interface LogConfig {
    level: 'error' | 'warn' | 'log' | 'debug' | 'verbose';
    enableAuthLogs: boolean;
    enableDatabaseLogs: boolean;
    enableRequestLogs: boolean;
}
export declare const defaultLogConfig: LogConfig;
export declare class CustomLogger implements LoggerService {
    private config;
    private logLevels;
    constructor(config?: LogConfig);
    log(message: string, context?: string): void;
    error(message: string, trace?: string, context?: string): void;
    warn(message: string, context?: string): void;
    debug(message: string, context?: string): void;
    verbose(message: string, context?: string): void;
    private shouldLog;
    private formatMessage;
}
export declare const createLoggerConfig: () => LogConfig;
