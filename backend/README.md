<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="120" alt="Nest Logo" /></a>
</p>

[circleci-image]: https://img.shields.io/circleci/build/github/nestjs/nest/master?token=abc123def456
[circleci-url]: https://circleci.com/gh/nestjs/nest

  <p align="center">A progressive <a href="http://nodejs.org" target="_blank">Node.js</a> framework for building efficient and scalable server-side applications.</p>
    <p align="center">
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/v/@nestjs/core.svg" alt="NPM Version" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/l/@nestjs/core.svg" alt="Package License" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/dm/@nestjs/common.svg" alt="NPM Downloads" /></a>
<a href="https://circleci.com/gh/nestjs/nest" target="_blank"><img src="https://img.shields.io/circleci/build/github/nestjs/nest/master" alt="CircleCI" /></a>
<a href="https://discord.gg/G7Qnnhy" target="_blank"><img src="https://img.shields.io/badge/discord-online-brightgreen.svg" alt="Discord"/></a>
<a href="https://opencollective.com/nest#backer" target="_blank"><img src="https://opencollective.com/nest/backers/badge.svg" alt="Backers on Open Collective" /></a>
<a href="https://opencollective.com/nest#sponsor" target="_blank"><img src="https://opencollective.com/nest/sponsors/badge.svg" alt="Sponsors on Open Collective" /></a>
  <a href="https://paypal.me/kamilmysliwiec" target="_blank"><img src="https://img.shields.io/badge/Donate-PayPal-ff3f59.svg" alt="Donate us"/></a>
    <a href="https://opencollective.com/nest#sponsor"  target="_blank"><img src="https://img.shields.io/badge/Support%20us-Open%20Collective-41B883.svg" alt="Support us"></a>
  <a href="https://twitter.com/nestframework" target="_blank"><img src="https://img.shields.io/twitter/follow/nestframework.svg?style=social&label=Follow" alt="Follow us on Twitter"></a>
</p>
  <!--[![Backers on Open Collective](https://opencollective.com/nest/backers/badge.svg)](https://opencollective.com/nest#backer)
  [![Sponsors on Open Collective](https://opencollective.com/nest/sponsors/badge.svg)](https://opencollective.com/nest#sponsor)-->


URL ngrok ngrok http --url=pleasant-vaguely-drum.ngrok-free.app 80



---

Voici un **guide clair, prêt à être copié/collé** dans ta documentation ou README pour l'installation et le lancement de Ngrok avec un domaine statique pour ton backend NestJS dans un environnement Flutter + Docker :

---

## 🚀 Guide d'installation & lancement de Ngrok avec domaine statique

Ce guide te permet de rendre ton **backend accessible depuis un appareil externe** (mobile ou non connecté au réseau local), via une **URL publique statique Ngrok**.

---

### ✅ 1. Créer un compte Ngrok

👉 [https://dashboard.ngrok.com/signup](https://dashboard.ngrok.com/signup)

---

### ✅ 2. Télécharger & installer Ngrok

* Télécharge pour ton système : [https://ngrok.com/download](https://ngrok.com/download)
* Décompresse puis place le binaire :

  * **Linux/macOS** : `/usr/local/bin`
  * **Windows** : `C:\ngrok\`

---

### ✅ 3. Configurer ton token

Dans ton terminal :

```bash
ngrok config add-authtoken 30sGs1vLZzNmWq2Zz65gyBqNveL_2WX5u2ZHGwzzdFg2cdzo9
```

---

### ✅ 4. Réserver un domaine statique

* Va sur : [https://dashboard.ngrok.com/cloud-edge/domains](https://dashboard.ngrok.com/cloud-edge/domains)
* Clique sur **"Reserve a Domain"**
* Ex : `mon-backend.ngrok.app`

---

### ✅ 5. Lancer le tunnel Ngrok

⚠️ **Lance d'abord ton backend (ex: NestJS sur le port 3000)**

Puis dans ton terminal :

```bash
ngrok http --domain=pleasant-vaguely-drum.ngrok-free.app 3000
```

---

### ✅ 6. Configurer l’app Flutter

Dans tes services API Flutter :

```dart
const String baseUrl = 'https://pleasant-vaguely-drum.ngrok-free.app';
```

---

### 📌 Recommandations

* 🟢 Le **backend doit être lancé AVANT Ngrok**
* 🛑 Ne change pas de port après avoir lié le domaine
* 🔐 Pour un domaine **vraiment fixe**, prends un **plan payant** (sinon il peut expirer)
* 🌐 Active les **CORS** dans NestJS si tu utilises Flutter Web

---

### ✅ Automatisation (optionnel)

Crée un script shell (ex: `start_ngrok.sh`) :

```bash
#!/bin/bash

# Lancer le backend
npm run start &

# Attendre que le backend soit prêt (adapter selon ton setup)
sleep 5

# Lancer ngrok
ngrok http --domain=pleasant-vaguely-drum.ngrok-free.app 3000
```


## Description

[Nest](https://github.com/nestjs/nest) framework TypeScript starter repository.

## Project setup

```bash
$ npm install
```

## Compile and run the project

```bash
# development
$ npm run start

# watch mode
$ npm run start:dev

# production mode
$ npm run start:prod
```

## Run tests

```bash
# unit tests
$ npm run test

# e2e tests
$ npm run test:e2e

# test coverage
$ npm run test:cov
```

## Deployment

When you're ready to deploy your NestJS application to production, there are some key steps you can take to ensure it runs as efficiently as possible. Check out the [deployment documentation](https://docs.nestjs.com/deployment) for more information.

If you are looking for a cloud-based platform to deploy your NestJS application, check out [Mau](https://mau.nestjs.com), our official platform for deploying NestJS applications on AWS. Mau makes deployment straightforward and fast, requiring just a few simple steps:

```bash
$ npm install -g @nestjs/mau
$ mau deploy
```

With Mau, you can deploy your application in just a few clicks, allowing you to focus on building features rather than managing infrastructure.

## Resources

Check out a few resources that may come in handy when working with NestJS:

- Visit the [NestJS Documentation](https://docs.nestjs.com) to learn more about the framework.
- For questions and support, please visit our [Discord channel](https://discord.gg/G7Qnnhy).
- To dive deeper and get more hands-on experience, check out our official video [courses](https://courses.nestjs.com/).
- Deploy your application to AWS with the help of [NestJS Mau](https://mau.nestjs.com) in just a few clicks.
- Visualize your application graph and interact with the NestJS application in real-time using [NestJS Devtools](https://devtools.nestjs.com).
- Need help with your project (part-time to full-time)? Check out our official [enterprise support](https://enterprise.nestjs.com).
- To stay in the loop and get updates, follow us on [X](https://x.com/nestframework) and [LinkedIn](https://linkedin.com/company/nestjs).
- Looking for a job, or have a job to offer? Check out our official [Jobs board](https://jobs.nestjs.com).

## Support

Nest is an MIT-licensed open source project. It can grow thanks to the sponsors and support by the amazing backers. If you'd like to join them, please [read more here](https://docs.nestjs.com/support).

## Stay in touch

- Author - [Kamil Myśliwiec](https://twitter.com/kammysliwiec)
- Website - [https://nestjs.com](https://nestjs.com/)
- Twitter - [@nestframework](https://twitter.com/nestframework)

## License

Nest is [MIT licensed](https://github.com/nestjs/nest/blob/master/LICENSE).

# Backend Visio - API d'authentification

## Configuration

### Variables d'environnement

Créez un fichier `.env` à la racine du projet backend avec les variables suivantes :

```env
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=password
DB_DATABASE=visio_db

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-here
JWT_REFRESH_SECRET=your-super-secret-refresh-key-here

# Application Configuration
PORT=3000
NODE_ENV=development
```

## Installation

```bash
npm install
```

## Démarrage

```bash
# Développement
npm run start:dev

# Production
npm run start:prod
```

## API d'authentification

### Endpoints disponibles

#### POST /auth/register
Inscription d'un nouvel utilisateur

**Body:**
```json
{
  "fullName": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "phoneNumber": "+33123456789"
}
```

**Response:**
```json
{
  "user": {
    "id": "uuid",
    "email": "john@example.com",
    "fullName": "John Doe",
    "phoneNumber": "+33123456789",
    "isVerified": false
  },
  "accessToken": "jwt-token",
  "refreshToken": "refresh-token"
}
```

#### POST /auth/login
Connexion d'un utilisateur

**Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "user": {
    "id": "uuid",
    "email": "john@example.com",
    "fullName": "John Doe",
    "phoneNumber": "+33123456789",
    "isVerified": false
  },
  "accessToken": "jwt-token",
  "refreshToken": "refresh-token"
}
```

#### POST /auth/logout
Déconnexion (nécessite un token JWT valide)

**Headers:**
```
Authorization: Bearer <access-token>
```

**Response:**
```json
{
  "message": "Déconnexion réussie"
}
```

#### POST /auth/refresh
Rafraîchissement du token d'accès

**Body:**
```json
{
  "refreshToken": "refresh-token"
}
```

**Response:**
```json
{
  "accessToken": "new-jwt-token",
  "refreshToken": "new-refresh-token"
}
```

#### GET /auth/profile
Récupération du profil utilisateur (nécessite un token JWT valide)

**Headers:**
```
Authorization: Bearer <access-token>
```

**Response:**
```json
{
  "id": "uuid",
  "email": "john@example.com",
  "fullName": "John Doe"
}
```

## API de gestion des utilisateurs (Admin uniquement)

### Endpoints disponibles

#### GET /users
Liste de tous les utilisateurs (nécessite le rôle admin)

**Headers:**
```
Authorization: Bearer <access-token>
```

**Response:**
```json
[
  {
    "id": "uuid",
    "fullName": "John Doe",
    "email": "john@example.com",
    "phoneNumber": "+33123456789",
    "isVerified": true,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "roles": [
      {
        "id": 1,
        "name": "user",
        "description": "Utilisateur standard"
      }
    ]
  }
]
```

#### GET /users/:id
Détails d'un utilisateur spécifique (nécessite le rôle admin)

#### POST /users
Créer un nouvel utilisateur (nécessite le rôle admin)

**Body:**
```json
{
  "fullName": "Jane Doe",
  "email": "jane@example.com",
  "password": "password123",
  "phoneNumber": "+33123456789",
  "isVerified": true,
  "roleIds": [1, 2]
}
```

#### PUT /users/:id
Modifier un utilisateur (nécessite le rôle admin)

**Body:**
```json
{
  "fullName": "Jane Smith",
  "isVerified": true,
  "roleIds": [1]
}
```

#### DELETE /users/:id
Supprimer un utilisateur (nécessite le rôle admin)

**Response:**
```json
{
  "message": "Utilisateur supprimé avec succès"
}
```

#### PUT /users/:id/roles
Modifier les rôles d'un utilisateur (nécessite le rôle admin)

**Body:**
```json
{
  "roleIds": [1, 3]
}
```

## Initialisation

### Créer les rôles et l'utilisateur admin

```bash
npm run init:roles
```

Cela créera :
- Rôle `admin` : Administrateur avec tous les droits
- Rôle `user` : Utilisateur standard
- Rôle `seller` : Vendeur de produits
- Utilisateur admin : `admin@visio.com` / `admin123`

## Sécurité

- Les mots de passe sont hashés avec bcrypt (12 rounds)
- Les tokens JWT ont une durée de vie de 15 minutes pour l'access token
- Les refresh tokens ont une durée de vie de 7 jours
- Les tokens sont stockés en base de données pour permettre la révocation
- Validation des données avec class-validator
- Protection par rôles pour les endpoints sensibles
