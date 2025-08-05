import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { getRepositoryToken } from '@nestjs/typeorm';
import { User, Role } from '../entities';
import * as bcrypt from 'bcryptjs';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);

  const userRepository = app.get(getRepositoryToken(User));
  const roleRepository = app.get(getRepositoryToken(Role));

  console.log('🚀 Initialisation des rôles et utilisateur admin...');

  try {
    // Créer les rôles de base
    const adminRole = roleRepository.create({
      name: 'admin',
      description: 'Administrateur avec tous les droits',
    });

    const userRole = roleRepository.create({
      name: 'user',
      description: 'Utilisateur standard',
    });

    const sellerRole = roleRepository.create({
      name: 'seller',
      description: 'Vendeur de produits',
    });

    await roleRepository.save([adminRole, userRole, sellerRole]);
    console.log('✅ Rôles créés avec succès');

    // Vérifier si l'admin existe déjà
    const existingAdmin = await userRepository.findOne({
      where: { email: 'admin@visio.com' },
    });

    if (!existingAdmin) {
      // Créer l'utilisateur admin
      const passwordHash = await bcrypt.hash('admin123', 12);
      
      const adminUser = userRepository.create({
        fullName: 'Administrateur Visio',
        email: 'admin@visio.com',
        passwordHash,
        phoneNumber: '+33123456789',
        isVerified: true,
        roles: [adminRole],
      });

      await userRepository.save(adminUser);
      console.log('✅ Utilisateur admin créé avec succès');
      console.log('📧 Email: admin@visio.com');
      console.log('🔑 Mot de passe: admin123');
    } else {
      console.log('ℹ️ L\'utilisateur admin existe déjà');
    }

  } catch (error) {
    console.error('❌ Erreur lors de l\'initialisation:', error);
  } finally {
    await app.close();
  }
}

bootstrap(); 