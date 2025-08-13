"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("../app.module");
const typeorm_1 = require("@nestjs/typeorm");
const entities_1 = require("../entities");
const bcrypt = __importStar(require("bcryptjs"));
async function bootstrap() {
    const app = await core_1.NestFactory.createApplicationContext(app_module_1.AppModule);
    const userRepository = app.get((0, typeorm_1.getRepositoryToken)(entities_1.User));
    const roleRepository = app.get((0, typeorm_1.getRepositoryToken)(entities_1.Role));
    console.log('🚀 Initialisation des rôles et utilisateur admin...');
    try {
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
        const existingAdmin = await userRepository.findOne({
            where: { email: 'admin@visio.com' },
        });
        if (!existingAdmin) {
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
        }
        else {
            console.log('ℹ️ L\'utilisateur admin existe déjà');
        }
    }
    catch (error) {
        console.error('❌ Erreur lors de l\'initialisation:', error);
    }
    finally {
        await app.close();
    }
}
bootstrap();
//# sourceMappingURL=init-roles.js.map