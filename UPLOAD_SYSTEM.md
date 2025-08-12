# Système de Gestion des Photos de Profil

## Vue d'ensemble

Ce système permet aux utilisateurs de gérer leurs photos de profil de deux manières :
1. **Lors de l'inscription** : Upload public sans authentification
2. **Après connexion** : Upload protégé avec authentification JWT

## Architecture Backend

### Structure des dossiers
```
backend/
├── uploads/
│   ├── avatars/          # Stockage des avatars
│   └── .gitignore        # Ignore les fichiers uploadés
├── src/
│   ├── upload/           # Module d'upload
│   │   ├── upload.module.ts
│   │   ├── upload.service.ts
│   │   └── upload.controller.ts
│   └── main.ts           # Configuration des fichiers statiques
```

### Endpoints API

#### 1. Upload Public (Inscription)
- **URL** : `POST /upload/avatar/public`
- **Authentification** : Aucune
- **Utilisation** : Lors de l'inscription d'un nouveau compte
- **Payload** : `multipart/form-data` avec champ `avatar`

#### 2. Upload Protégé (Profil)
- **URL** : `POST /upload/avatar`
- **Authentification** : JWT Bearer Token
- **Utilisation** : Modification du profil utilisateur connecté
- **Payload** : `multipart/form-data` avec champ `avatar`

### Configuration du stockage

- **Dossier de destination** : `uploads/avatars/`
- **Nommage des fichiers** : `avatar_{timestamp}_{uuid}.{extension}`
- **Types supportés** : JPEG, JPG, PNG, GIF, WebP
- **Taille maximale** : 5MB
- **URL générée** : `{BASE_URL}/uploads/avatars/{filename}`

## Architecture Frontend

### Services

#### UploadService
- `uploadAvatarPublic()` : Upload sans token (inscription)
- `uploadAvatar()` : Upload avec token (profil)
- `pickImage()` : Sélection depuis galerie/caméra

### Écrans

#### RegisterScreen
- Sélection d'image via galerie/caméra
- Upload automatique avant l'inscription
- Affichage de l'aperçu de l'image sélectionnée

#### ProfileScreen
- Modification de l'avatar existant
- Upload avec authentification
- Gestion des erreurs d'upload

#### AuthDropdown
- Affichage de l'avatar dans le menu utilisateur
- Fallback sur l'icône par défaut si pas d'avatar

## Flux d'utilisation

### 1. Inscription avec photo
```
1. Utilisateur sélectionne une image (galerie/caméra)
2. Image affichée en aperçu
3. Lors de l'inscription : upload automatique via /upload/avatar/public
4. URL de l'avatar stockée en base avec le compte
5. Redirection vers la connexion
```

### 2. Modification du profil
```
1. Utilisateur connecté va dans son profil
2. Mode édition activé
3. Sélection d'une nouvelle image
4. Upload via /upload/avatar (avec token)
5. Mise à jour du profil avec la nouvelle URL
6. Affichage immédiat de la nouvelle image
```

## Sécurité

- **Upload public** : Limité aux types d'images et taille
- **Upload protégé** : Authentification JWT requise
- **Validation** : Types MIME et extension des fichiers
- **Isolation** : Dossiers séparés pour chaque type de contenu

## Configuration

### Variables d'environnement
```env
BASE_URL=http://localhost:3000
PORT=3000
```

### Permissions de dossiers
- Le dossier `uploads/` est créé automatiquement
- Les fichiers sont accessibles publiquement via `/uploads/avatars/`
- Le dossier est ignoré par Git (sauf .gitignore)

## Déploiement

### Production
- Configurer `BASE_URL` avec l'URL de production
- S'assurer que le dossier `uploads/` est accessible en lecture
- Considérer l'utilisation d'un CDN pour les images

### Développement
- Démarrer le backend : `npm run start:dev`
- Les fichiers sont servis depuis `http://localhost:3000/uploads/avatars/`
- Hot reload activé pour les modifications

## Gestion des erreurs

### Côté Backend
- Validation des types de fichiers
- Gestion des erreurs de stockage
- Logs d'erreur détaillés

### Côté Frontend
- Affichage des erreurs d'upload
- Fallback sur l'icône par défaut
- Messages d'erreur utilisateur-friendly

## Maintenance

### Nettoyage des fichiers
- Les anciens avatars peuvent être supprimés manuellement
- Considérer une tâche cron pour nettoyer les fichiers orphelins
- Sauvegarde du dossier `uploads/` recommandée

### Monitoring
- Surveiller l'espace disque du dossier uploads
- Logs des uploads réussis/échoués
- Métriques de performance des uploads
