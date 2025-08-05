import { LoggerService } from '@nestjs/common';

export interface LogConfig {
  level: 'error' | 'warn' | 'log' | 'debug' | 'verbose';
  enableAuthLogs: boolean;
  enableDatabaseLogs: boolean;
  enableRequestLogs: boolean;
}

export const defaultLogConfig: LogConfig = {
  level: 'debug',
  enableAuthLogs: true,
  enableDatabaseLogs: true,
  enableRequestLogs: true,
};

export class CustomLogger implements LoggerService {
  private logLevels = {
    error: 0,
    warn: 1,
    log: 2,
    debug: 3,
    verbose: 4,
  };

  constructor(private config: LogConfig = defaultLogConfig) {}

  log(message: string, context?: string) {
    if (this.shouldLog('log')) {
      console.log(`[LOG] ${this.formatMessage(message, context)}`);
    }
  }

  error(message: string, trace?: string, context?: string) {
    if (this.shouldLog('error')) {
      console.error(`[ERROR] ${this.formatMessage(message, context)}`);
      if (trace) {
        console.error(`[ERROR] Stack trace: ${trace}`);
      }
    }
  }

  warn(message: string, context?: string) {
    if (this.shouldLog('warn')) {
      console.warn(`[WARN] ${this.formatMessage(message, context)}`);
    }
  }

  debug(message: string, context?: string) {
    if (this.shouldLog('debug')) {
      console.debug(`[DEBUG] ${this.formatMessage(message, context)}`);
    }
  }

  verbose(message: string, context?: string) {
    if (this.shouldLog('verbose')) {
      console.log(`[VERBOSE] ${this.formatMessage(message, context)}`);
    }
  }

  private shouldLog(level: keyof typeof this.logLevels): boolean {
    return this.logLevels[level] <= this.logLevels[this.config.level];
  }

  private formatMessage(message: string, context?: string): string {
    const timestamp = new Date().toISOString();
    return context ? `[${timestamp}] [${context}] ${message}` : `[${timestamp}] ${message}`;
  }
}

export const createLoggerConfig = (): LogConfig => {
  return {
    level: (process.env.LOG_LEVEL as LogConfig['level']) || 'debug',
    enableAuthLogs: process.env.ENABLE_AUTH_LOGS !== 'false',
    enableDatabaseLogs: process.env.ENABLE_DATABASE_LOGS !== 'false',
    enableRequestLogs: process.env.ENABLE_REQUEST_LOGS !== 'false',
  };
}; 