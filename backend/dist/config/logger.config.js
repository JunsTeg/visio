"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createLoggerConfig = exports.CustomLogger = exports.defaultLogConfig = void 0;
exports.defaultLogConfig = {
    level: 'debug',
    enableAuthLogs: true,
    enableDatabaseLogs: true,
    enableRequestLogs: true,
};
class CustomLogger {
    config;
    logLevels = {
        error: 0,
        warn: 1,
        log: 2,
        debug: 3,
        verbose: 4,
    };
    constructor(config = exports.defaultLogConfig) {
        this.config = config;
    }
    log(message, context) {
        if (this.shouldLog('log')) {
            console.log(`[LOG] ${this.formatMessage(message, context)}`);
        }
    }
    error(message, trace, context) {
        if (this.shouldLog('error')) {
            console.error(`[ERROR] ${this.formatMessage(message, context)}`);
            if (trace) {
                console.error(`[ERROR] Stack trace: ${trace}`);
            }
        }
    }
    warn(message, context) {
        if (this.shouldLog('warn')) {
            console.warn(`[WARN] ${this.formatMessage(message, context)}`);
        }
    }
    debug(message, context) {
        if (this.shouldLog('debug')) {
            console.debug(`[DEBUG] ${this.formatMessage(message, context)}`);
        }
    }
    verbose(message, context) {
        if (this.shouldLog('verbose')) {
            console.log(`[VERBOSE] ${this.formatMessage(message, context)}`);
        }
    }
    shouldLog(level) {
        return this.logLevels[level] <= this.logLevels[this.config.level];
    }
    formatMessage(message, context) {
        const timestamp = new Date().toISOString();
        return context ? `[${timestamp}] [${context}] ${message}` : `[${timestamp}] ${message}`;
    }
}
exports.CustomLogger = CustomLogger;
const createLoggerConfig = () => {
    return {
        level: process.env.LOG_LEVEL || 'debug',
        enableAuthLogs: process.env.ENABLE_AUTH_LOGS !== 'false',
        enableDatabaseLogs: process.env.ENABLE_DATABASE_LOGS !== 'false',
        enableRequestLogs: process.env.ENABLE_REQUEST_LOGS !== 'false',
    };
};
exports.createLoggerConfig = createLoggerConfig;
//# sourceMappingURL=logger.config.js.map