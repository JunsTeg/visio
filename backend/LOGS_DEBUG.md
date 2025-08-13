# Logs de Débogage - Module d'Authentification

## Vue d'ensemble

Ce document décrit les logs de débogage ajoutés dans le module d'authentification du backend Visio. Ces logs permettent de tracer toutes les opérations d'authentification et d'identifier rapidement les problèmes.

## Configuration des Logs

### Variables d'environnement

```bash
# Niveau de log (error, warn, log, debug, verbose)
LOG_LEVEL=debug

# Activer/désactiver les logs spécifiques
ENABLE_AUTH_LOGS=true
ENABLE_DATABASE_LOGS=true
ENABLE_REQUEST_LOGS=true
```

### Niveaux de Log

- **ERROR** : Erreurs critiques nécessitant une attention immédiate
- **WARN** : Avertissements sur des situations anormales
- **LOG** : Informations générales sur le fonctionnement
- **DEBUG** : Informations détaillées pour le débogage
- **VERBOSE** : Informations très détaillées

## Composants avec Logs

### 1. AuthService (`auth.service.ts`)

#### Méthodes avec logs détaillés :

- **register()** : Inscription d'un nouvel utilisateur
  - Vérification de l'existence de l'utilisateur
  - Hachage du mot de passe
  - Création et sauvegarde de l'utilisateur
  - Génération des tokens

- **login()** : Connexion d'un utilisateur
  - Recherche de l'utilisateur
  - Vérification du mot de passe
  - Génération des tokens

- **logout()** : Déconnexion d'un utilisateur
  - Suppression des tokens

- **refreshToken()** : Rafraîchissement des tokens
  - Vérification du refresh token
  - Validation de l'expiration
  - Génération de nouveaux tokens

- **validateUser()** : Validation d'un utilisateur par ID
- **validateUserByCredentials()** : Validation par email/mot de passe

#### Exemples de logs :

```
[DEBUG] Vérification de l'existence de l'utilisateur avec l'email: user@example.com
[LOG] Utilisateur créé avec succès, ID: 123e4567-e89b-12d3-a456-426614174000
[DEBUG] Génération des tokens d'authentification
[WARN] Tentative de connexion avec un email inexistant: unknown@example.com
```

### 2. AuthController (`auth.controller.ts`)

#### Endpoints avec logs :

- **POST /auth/register** : Inscription
- **POST /auth/login** : Connexion
- **POST /auth/logout** : Déconnexion
- **POST /auth/refresh** : Rafraîchissement de token
- **GET /auth/profile** : Profil utilisateur

#### Exemples de logs :

```
[LOG] Requête d'inscription reçue pour l'email: user@example.com
[DEBUG] Données d'inscription: {"email":"user@example.com","password":"[MASKED]","fullName":"John Doe"}
[LOG] Inscription réussie pour l'email: user@example.com
```

### 3. Stratégies d'Authentification

#### JwtStrategy (`jwt.strategy.ts`)
- Validation des tokens JWT
- Extraction du payload
- Vérification de l'utilisateur

#### LocalStrategy (`local.strategy.ts`)
- Validation des credentials (email/mot de passe)
- Authentification locale

#### Exemples de logs :

```
[DEBUG] Validation JWT - Payload reçu: {"sub":"123e4567-e89b-12d3-a456-426614174000","email":"user@example.com"}
[DEBUG] Validation JWT réussie pour l'utilisateur: user@example.com (ID: 123e4567-e89b-12d3-a456-426614174000)
```

### 4. Guards d'Authentification

#### JwtAuthGuard (`jwt-auth.guard.ts`)
- Protection des routes avec JWT
- Gestion des erreurs d'authentification

#### LocalAuthGuard (`local-auth.guard.ts`)
- Protection des routes de connexion
- Validation locale

#### RolesGuard (`roles.guard.ts`)
- Vérification des rôles et permissions
- Contrôle d'accès basé sur les rôles

#### Exemples de logs :

```
[DEBUG] JwtAuthGuard - Utilisateur authentifié: user@example.com (ID: 123e4567-e89b-12d3-a456-426614174000)
[DEBUG] Vérification des rôles - Rôles requis: ["admin","user"]
[DEBUG] Rôles de l'utilisateur: ["user"]
[DEBUG] Accès autorisé pour l'utilisateur: user@example.com avec les rôles: ["user"]
```

## Utilisation des Logs

### 1. Démarrage de l'application

```bash
npm run start:dev
```

Les logs d'initialisation apparaîtront :

```
[LOG] Démarrage de l'application Visio Backend
[LOG] AuthModule initialisé avec tous les composants d'authentification
[LOG] AuthService initialisé
[LOG] JwtStrategy initialisée
[LOG] LocalStrategy initialisée
[LOG] JwtAuthGuard initialisé
[LOG] LocalAuthGuard initialisé
[LOG] RolesGuard initialisé
[LOG] AuthController initialisé
[LOG] Application démarrée sur le port 3000
```

### 2. Test d'une inscription

```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","fullName":"Test User"}'
```

Logs attendus :

```
[LOG] Requête d'inscription reçue pour l'email: test@example.com
[DEBUG] Vérification de l'existence de l'utilisateur avec l'email: test@example.com
[DEBUG] Aucun utilisateur existant trouvé, procédure d'inscription en cours
[DEBUG] Hachage du mot de passe en cours...
[DEBUG] Mot de passe haché avec succès
[DEBUG] Création de l'entité utilisateur
[DEBUG] Sauvegarde de l'utilisateur en base de données
[LOG] Utilisateur créé avec succès, ID: 123e4567-e89b-12d3-a456-426614174000
[DEBUG] Génération des tokens d'authentification
[DEBUG] Génération de tokens pour l'utilisateur: test@example.com (ID: 123e4567-e89b-12d3-a456-426614174000)
[DEBUG] Payload JWT créé: {"sub":"123e4567-e89b-12d3-a456-426614174000","email":"test@example.com"}
[DEBUG] Génération du access token (15 minutes)
[DEBUG] Génération du refresh token (7 jours)
[DEBUG] Calcul de la date d'expiration du refresh token
[DEBUG] Sauvegarde du refresh token en base de données
[DEBUG] Refresh token sauvegardé, ID: 456e7890-e89b-12d3-a456-426614174000
[DEBUG] Génération des tokens terminée avec succès
[DEBUG] Tokens générés avec succès
[LOG] Inscription réussie pour l'utilisateur: test@example.com (ID: 123e4567-e89b-12d3-a456-426614174000)
[LOG] Inscription réussie pour l'email: test@example.com
```

### 3. Test d'une connexion

```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

Logs attendus :

```
[LOG] Requête de connexion reçue pour l'email: test@example.com
[DEBUG] Validation locale - Tentative de connexion pour l'email: test@example.com
[DEBUG] Validation locale - Vérification des credentials
[DEBUG] Validation des credentials pour l'email: test@example.com
[DEBUG] Utilisateur trouvé, vérification du mot de passe pour: test@example.com
[DEBUG] Credentials validés pour l'utilisateur: test@example.com (ID: 123e4567-e89b-12d3-a456-426614174000)
[DEBUG] Validation locale réussie pour l'utilisateur: test@example.com (ID: 123e4567-e89b-12d3-a456-426614174000)
[DEBUG] LocalAuthGuard - Utilisateur authentifié: test@example.com (ID: 123e4567-e89b-12d3-a456-426614174000)
[LOG] Tentative de connexion pour l'email: test@example.com
[DEBUG] Recherche de l'utilisateur avec l'email: test@example.com
[DEBUG] Utilisateur trouvé, ID: 123e4567-e89b-12d3-a456-426614174000, vérification du mot de passe
[DEBUG] Mot de passe validé avec succès
[DEBUG] Génération des tokens d'authentification
[DEBUG] Tokens générés avec succès
[LOG] Connexion réussie pour l'utilisateur: test@example.com (ID: 123e4567-e89b-12d3-a456-426614174000)
[LOG] Connexion réussie pour l'email: test@example.com
```

## Dépannage

### Problèmes courants et leurs logs

1. **Email déjà existant** :
   ```
   [WARN] Tentative d'inscription avec un email déjà existant: user@example.com
   ```

2. **Credentials invalides** :
   ```
   [WARN] Tentative de connexion avec un email inexistant: unknown@example.com
   [WARN] Mot de passe incorrect pour l'utilisateur: user@example.com
   ```

3. **Token expiré** :
   ```
   [WARN] Refresh token expiré, ID: 456e7890-e89b-12d3-a456-426614174000
   ```

4. **Permissions insuffisantes** :
   ```
   [WARN] Permissions insuffisantes - Utilisateur: user@example.com, Rôles: ["user"], Requis: ["admin"]
   ```

### Activation/Désactivation des logs

Pour désactiver les logs de débogage en production :

```bash
LOG_LEVEL=warn
ENABLE_AUTH_LOGS=false
```

Pour activer tous les logs en développement :

```bash
LOG_LEVEL=verbose
ENABLE_AUTH_LOGS=true
ENABLE_DATABASE_LOGS=true
ENABLE_REQUEST_LOGS=true
```

## Sécurité

⚠️ **Important** : Les logs de débogage peuvent contenir des informations sensibles. En production :

1. Ne jamais logger les mots de passe (déjà masqués avec `[MASKED]`)
2. Limiter le niveau de log à `warn` ou `error`
3. Surveiller les logs pour détecter les tentatives d'attaque
4. Rotation des fichiers de logs

## Performance

Les logs de débogage peuvent impacter les performances. Recommandations :

1. Utiliser le niveau `debug` uniquement en développement
2. Désactiver les logs détaillés en production
3. Utiliser un système de logging asynchrone pour les environnements critiques
4. Surveiller l'utilisation de la mémoire due aux logs 