import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { UploadModule } from './upload/upload.module';
import { DatabaseConfig } from './config/database.config';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [DatabaseConfig],
    }),
    TypeOrmModule.forRootAsync({
      useFactory: DatabaseConfig,
      inject: [ConfigModule],
    }),
    AuthModule,
    UsersModule,
    UploadModule,
  ],
})
export class AppModule {}
