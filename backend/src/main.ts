import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { AppModule } from './app.module';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';

async function bootstrap() {
  // Configuration des logs
  const logger = new Logger('Bootstrap');
  
  // Créer l'application avec les logs activés
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    logger: ['error', 'warn', 'log', 'debug', 'verbose'],
  });
  
  logger.log('Démarrage de l\'application Visio Backend');
  
  // Configuration de la validation globale
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));

  // Configuration CORS
  app.enableCors();
  
  // Configuration des fichiers statiques pour les uploads
  app.useStaticAssets(join(__dirname, '..', 'uploads'), {
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
