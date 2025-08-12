"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const common_1 = require("@nestjs/common");
const app_module_1 = require("./app.module");
const path_1 = require("path");
async function bootstrap() {
    const logger = new common_1.Logger('Bootstrap');
    const app = await core_1.NestFactory.create(app_module_1.AppModule, {
        logger: ['error', 'warn', 'log', 'debug', 'verbose'],
    });
    logger.log('Démarrage de l\'application Visio Backend');
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
    }));
    app.enableCors();
    app.useStaticAssets((0, path_1.join)(__dirname, '..', 'uploads'), {
        prefix: '/uploads/',
    });
    logger.log('Configuration CORS activée');
    logger.log('Configuration des fichiers statiques activée');
    const port = process.env.PORT ?? 3000;
    await app.listen(port);
    logger.log(`Application démarrée sur le port ${port}`);
    logger.debug('Tous les logs de débogage sont activés');
}
bootstrap();
//# sourceMappingURL=main.js.map