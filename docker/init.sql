-- ====================================================================
-- SCHÉMA SQL RESTRUCTURÉ POUR VISIO - PLATEFORME E-COMMERCE 3D
-- ====================================================================
-- Version: 1.0
-- Date: 2025-08-13
-- Description: Schéma complet pour la plateforme Visio avec photogrammétrie
-- ====================================================================

-- ==================== EXTENSIONS ET FONCTIONS ====================

-- Extension UUID pour PostgreSQL
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Fonctions UUID (si pas déjà présentes)
DROP FUNCTION IF EXISTS "uuid_generate_v1" CASCADE;
CREATE FUNCTION "uuid_generate_v1" () RETURNS uuid LANGUAGE c AS 'uuid_generate_v1';

DROP FUNCTION IF EXISTS "uuid_generate_v1mc" CASCADE;
CREATE FUNCTION "uuid_generate_v1mc" () RETURNS uuid LANGUAGE c AS 'uuid_generate_v1mc';

DROP FUNCTION IF EXISTS "uuid_generate_v3" CASCADE;
CREATE FUNCTION "uuid_generate_v3" (IN "namespace" uuid, IN "name" text) RETURNS uuid LANGUAGE c AS 'uuid_generate_v3';

DROP FUNCTION IF EXISTS "uuid_generate_v4" CASCADE;
CREATE FUNCTION "uuid_generate_v4" () RETURNS uuid LANGUAGE c AS 'uuid_generate_v4';

DROP FUNCTION IF EXISTS "uuid_generate_v5" CASCADE;
CREATE FUNCTION "uuid_generate_v5" (IN "namespace" uuid, IN "name" text) RETURNS uuid LANGUAGE c AS 'uuid_generate_v5';

DROP FUNCTION IF EXISTS "uuid_nil" CASCADE;
CREATE FUNCTION "uuid_nil" () RETURNS uuid LANGUAGE c AS 'uuid_nil';

DROP FUNCTION IF EXISTS "uuid_ns_dns" CASCADE;
CREATE FUNCTION "uuid_ns_dns" () RETURNS uuid LANGUAGE c AS 'uuid_ns_dns';

DROP FUNCTION IF EXISTS "uuid_ns_oid" CASCADE;
CREATE FUNCTION "uuid_ns_oid" () RETURNS uuid LANGUAGE c AS 'uuid_ns_oid';

DROP FUNCTION IF EXISTS "uuid_ns_url" CASCADE;
CREATE FUNCTION "uuid_ns_url" () RETURNS uuid LANGUAGE c AS 'uuid_ns_url';

DROP FUNCTION IF EXISTS "uuid_ns_x500" CASCADE;
CREATE FUNCTION "uuid_ns_x500" () RETURNS uuid LANGUAGE c AS 'uuid_ns_x500';

-- ==================== SÉQUENCES ====================

-- Séquences pour les tables avec auto-increment
CREATE SEQUENCE IF NOT EXISTS activity_logs_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;
CREATE SEQUENCE IF NOT EXISTS auth_tokens_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 39 CACHE 1;
CREATE SEQUENCE IF NOT EXISTS categories_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;
CREATE SEQUENCE IF NOT EXISTS moderation_reports_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;
CREATE SEQUENCE IF NOT EXISTS notifications_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;
CREATE SEQUENCE IF NOT EXISTS order_items_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;
CREATE SEQUENCE IF NOT EXISTS payments_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;
CREATE SEQUENCE IF NOT EXISTS photogrammetry_images_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;
CREATE SEQUENCE IF NOT EXISTS product_images_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;
CREATE SEQUENCE IF NOT EXISTS product_models_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1;
CREATE SEQUENCE IF NOT EXISTS roles_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 4 CACHE 1;

-- ==================== TABLES DE BASE (UTILISATEURS ET RÔLES) ====================

-- Table des rôles utilisateurs
CREATE TABLE IF NOT EXISTS "public"."roles" (
    "id" integer DEFAULT nextval('roles_id_seq') NOT NULL,
    "name" character varying(50) NOT NULL,
    "description" text,
    CONSTRAINT "roles_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

-- Table des utilisateurs
CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "full_name" character varying(100) NOT NULL,
    "email" character varying(100) NOT NULL,
    "phone_number" character varying(20),
    "is_verified" boolean DEFAULT false NOT NULL,
    "created_at" timestamp DEFAULT now() NOT NULL,
    "password_hash" character varying NOT NULL,
    "avatar_url" character varying,
    "last_login" timestamp,
    "active" boolean DEFAULT true NOT NULL,
    "online" boolean DEFAULT false NOT NULL,
    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

-- Table de liaison utilisateurs-rôles
CREATE TABLE IF NOT EXISTS "public"."user_roles" (
    "user_id" uuid NOT NULL,
    "role_id" integer NOT NULL,
    CONSTRAINT "user_roles_pkey" PRIMARY KEY ("user_id", "role_id")
) WITH (oids = false);

-- Table des tokens d'authentification
CREATE TABLE IF NOT EXISTS "public"."auth_tokens" (
    "id" integer DEFAULT nextval('auth_tokens_id_seq') NOT NULL,
    "user_id" uuid NOT NULL,
    "type" character varying(50) NOT NULL,
    "expires_at" timestamp NOT NULL,
    "created_at" timestamp DEFAULT now() NOT NULL,
    "token" character varying NOT NULL,
    CONSTRAINT "auth_tokens_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

-- ==================== TABLES CATALOGUE ET PRODUITS ====================

-- Table des catégories
CREATE TABLE IF NOT EXISTS "public"."categories" (
    "id" integer DEFAULT nextval('categories_id_seq') NOT NULL,
    "name" character varying(100) NOT NULL,
    "description" text,
    CONSTRAINT "categories_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

-- Table des produits
CREATE TABLE IF NOT EXISTS "public"."products" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "name" character varying(200) NOT NULL,
    "description" text,
    "price" numeric(10,2) NOT NULL,
    "stock" integer DEFAULT '0' NOT NULL,
    "category_id" integer,
    "seller_id" uuid,
    "created_at" timestamp DEFAULT now() NOT NULL,
    "thumbnail_url" character varying,
    CONSTRAINT "products_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

-- Table des images de produits
CREATE TABLE IF NOT EXISTS "public"."product_images" (
    "id" integer DEFAULT nextval('product_images_id_seq') NOT NULL,
    "product_id" uuid NOT NULL,
    "is_primary" boolean DEFAULT false NOT NULL,
    "image_url" character varying NOT NULL,
    CONSTRAINT "product_images_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

-- Table des modèles 3D de produits
CREATE TABLE IF NOT EXISTS "public"."product_models" (
    "id" integer DEFAULT nextval('product_models_id_seq') NOT NULL,
    "product_id" uuid NOT NULL,
    "format" character varying(10),
    "created_at" timestamp DEFAULT now() NOT NULL,
    "model_url" character varying,
    "generated_by" character varying,
    CONSTRAINT "product_models_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

-- ==================== TABLES PHOTOGRAMMÉTRIE ====================

-- Table des sessions de photogrammétrie
CREATE TABLE IF NOT EXISTS "public"."photogrammetry_sessions" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "user_id" uuid,
    "product_id" uuid,
    "device_model" text,
    "burst_mode" boolean,
    "image_count" integer,
    "status" character varying(50) DEFAULT 'pending',
    "model_url" text,
    "created_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "photogrammetry_sessions_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

-- Table des images de photogrammétrie
CREATE TABLE IF NOT EXISTS "public"."photogrammetry_images" (
    "id" integer DEFAULT nextval('photogrammetry_images_id_seq') NOT NULL,
    "session_id" uuid,
    "image_url" text,
    CONSTRAINT "photogrammetry_images_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

-- ==================== TABLES COMMANDES ET PAIEMENTS ====================

-- Table des commandes
CREATE TABLE IF NOT EXISTS "public"."orders" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "user_id" uuid NOT NULL,
    "total" numeric(10,2),
    "created_at" timestamp DEFAULT now() NOT NULL,
    "status" character varying DEFAULT 'pending' NOT NULL,
    CONSTRAINT "orders_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

-- Table des éléments de commande
CREATE TABLE IF NOT EXISTS "public"."order_items" (
    "id" integer DEFAULT nextval('order_items_id_seq') NOT NULL,
    "order_id" uuid NOT NULL,
    "product_id" uuid NOT NULL,
    "quantity" integer NOT NULL,
    "unit_price" numeric(10,2) NOT NULL,
    CONSTRAINT "order_items_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

-- Table des paiements
CREATE TABLE IF NOT EXISTS "public"."payments" (
    "id" integer DEFAULT nextval('payments_id_seq') NOT NULL,
    "order_id" uuid NOT NULL,
    "payment_method" character varying(50),
    "status" character varying(50),
    "paid_at" timestamp,
    CONSTRAINT "payments_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

-- ==================== TABLES COMMUNICATION ET NOTIFICATIONS ====================

-- Table des notifications
CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" integer DEFAULT nextval('notifications_id_seq') NOT NULL,
    "user_id" uuid,
    "title" text,
    "message" text,
    "is_read" boolean DEFAULT false,
    "created_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

-- Table des conversations de chat
CREATE TABLE IF NOT EXISTS "public"."chat_conversations" (
    "id" SERIAL PRIMARY KEY,
    "initiator_id" UUID NOT NULL,
    "receiver_id" UUID NOT NULL,
    "product_id" UUID NULL,
    "order_id" UUID NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des messages de chat
CREATE TABLE IF NOT EXISTS "public"."chat_messages" (
    "id" SERIAL PRIMARY KEY,
    "conversation_id" INT NOT NULL,
    "sender_id" UUID NOT NULL,
    "message" TEXT,
    "message_type" VARCHAR(20) DEFAULT 'text',
    "attachment_url" TEXT,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==================== TABLES ÉVALUATIONS ET AVIS ====================

-- Table des avis produits
CREATE TABLE IF NOT EXISTS "public"."product_reviews" (
    "id" SERIAL PRIMARY KEY,
    "product_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "rating" INT CHECK (rating BETWEEN 1 AND 5) NOT NULL,
    "comment" TEXT,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des avis vendeurs
CREATE TABLE IF NOT EXISTS "public"."seller_reviews" (
    "id" SERIAL PRIMARY KEY,
    "seller_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "rating" INT CHECK (rating BETWEEN 1 AND 5) NOT NULL,
    "comment" TEXT,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==================== TABLES FONCTIONNALITÉS E-COMMERCE ====================

-- Table des favoris utilisateurs
CREATE TABLE IF NOT EXISTS "public"."user_wishlist" (
    "id" SERIAL PRIMARY KEY,
    "user_id" UUID NOT NULL,
    "product_id" UUID NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id)
);

-- Table des retours produits
CREATE TABLE IF NOT EXISTS "public"."product_returns" (
    "id" SERIAL PRIMARY KEY,
    "order_id" UUID NOT NULL,
    "product_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "reason" TEXT,
    "status" VARCHAR(50) DEFAULT 'pending',
    "refund_amount" NUMERIC(10,2),
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des codes de réduction
CREATE TABLE IF NOT EXISTS "public"."discount_codes" (
    "id" SERIAL PRIMARY KEY,
    "code" VARCHAR(50) UNIQUE NOT NULL,
    "description" TEXT,
    "discount_percent" INT CHECK (discount_percent BETWEEN 1 AND 100),
    "valid_from" TIMESTAMP,
    "valid_to" TIMESTAMP,
    "usage_limit" INT,
    "times_used" INT DEFAULT 0,
    "active" BOOLEAN DEFAULT true
);

-- ==================== TABLES MODÉRATION ET SIGNALEMENTS ====================

-- Table des signalements de modération (ancienne)
CREATE TABLE IF NOT EXISTS "public"."moderation_reports" (
    "id" integer DEFAULT nextval('moderation_reports_id_seq') NOT NULL,
    "reported_by" uuid,
    "product_id" uuid,
    "reason" text,
    "status" character varying(50) DEFAULT 'open',
    "created_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "moderation_reports_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

-- Table des signalements étendus (nouvelle)
CREATE TABLE IF NOT EXISTS "public"."reports" (
    "id" SERIAL PRIMARY KEY,
    "reporter_id" UUID NOT NULL,
    "reported_user_id" UUID NULL,
    "reported_product_id" UUID NULL,
    "reported_review_id" INT NULL,
    "reported_message_id" INT NULL,
    "reason" TEXT NOT NULL,
    "status" VARCHAR(50) DEFAULT 'open',
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==================== TABLES ANALYTICS ET STATISTIQUES ====================

-- Table des logs d'activité
CREATE TABLE IF NOT EXISTS "public"."activity_logs" (
    "id" integer DEFAULT nextval('activity_logs_id_seq') NOT NULL,
    "user_id" uuid,
    "action" text,
    "metadata" jsonb,
    "created_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "activity_logs_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

-- Table des statistiques produits
CREATE TABLE IF NOT EXISTS "public"."product_stats" (
    "product_id" UUID PRIMARY KEY,
    "views" INT DEFAULT 0,
    "purchases" INT DEFAULT 0,
    "favorites" INT DEFAULT 0,
    "last_updated" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table de l'historique des stocks
CREATE TABLE IF NOT EXISTS "public"."stock_history" (
    "id" SERIAL PRIMARY KEY,
    "product_id" UUID NOT NULL,
    "change_amount" INT NOT NULL,
    "reason" TEXT,
    "changed_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==================== INDEX ET CONTRAINTES ====================

-- Index uniques
CREATE UNIQUE INDEX IF NOT EXISTS categories_name_key ON public.categories USING btree (name);
CREATE UNIQUE INDEX IF NOT EXISTS roles_name_key ON public.roles USING btree (name);
CREATE UNIQUE INDEX IF NOT EXISTS users_email_key ON public.users USING btree (email);

-- Index pour les performances
CREATE INDEX IF NOT EXISTS "IDX_87b8888186ca9769c960e92687" ON public.user_roles USING btree (user_id);
CREATE INDEX IF NOT EXISTS "IDX_b23c65e50a758245a33ee35fda" ON public.user_roles USING btree (role_id);

-- ==================== CONTRAINTES DE CLÉS ÉTRANGÈRES ====================

-- Contraintes pour les utilisateurs et rôles
ALTER TABLE ONLY "public"."user_roles" 
    ADD CONSTRAINT "FK_87b8888186ca9769c960e926870" 
    FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE;

ALTER TABLE ONLY "public"."user_roles" 
    ADD CONSTRAINT "FK_b23c65e50a758245a33ee35fda1" 
    FOREIGN KEY (role_id) REFERENCES roles(id) ON UPDATE CASCADE ON DELETE CASCADE NOT DEFERRABLE;

ALTER TABLE ONLY "public"."auth_tokens" 
    ADD CONSTRAINT "FK_9691367d446cd8b18f462c191b3" 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE NOT DEFERRABLE;

-- Contraintes pour les produits
ALTER TABLE ONLY "public"."products" 
    ADD CONSTRAINT "FK_425ee27c69d6b8adc5d6475dcfe" 
    FOREIGN KEY (seller_id) REFERENCES users(id) NOT DEFERRABLE;

ALTER TABLE ONLY "public"."products" 
    ADD CONSTRAINT "FK_9a5f6868c96e0069e699f33e124" 
    FOREIGN KEY (category_id) REFERENCES categories(id) NOT DEFERRABLE;

ALTER TABLE ONLY "public"."product_images" 
    ADD CONSTRAINT "FK_4f166bb8c2bfcef2498d97b4068" 
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE NOT DEFERRABLE;

ALTER TABLE ONLY "public"."product_models" 
    ADD CONSTRAINT "FK_1c4bf6bd8d616d58e15bee39b2a" 
    FOREIGN KEY (product_id) REFERENCES products(id) NOT DEFERRABLE;

-- Contraintes pour la photogrammétrie
ALTER TABLE ONLY "public"."photogrammetry_sessions" 
    ADD CONSTRAINT "photogrammetry_sessions_user_id_fkey" 
    FOREIGN KEY (user_id) REFERENCES users(id) NOT DEFERRABLE;

ALTER TABLE ONLY "public"."photogrammetry_sessions" 
    ADD CONSTRAINT "photogrammetry_sessions_product_id_fkey" 
    FOREIGN KEY (product_id) REFERENCES products(id) NOT DEFERRABLE;

ALTER TABLE ONLY "public"."photogrammetry_images" 
    ADD CONSTRAINT "photogrammetry_images_session_id_fkey" 
    FOREIGN KEY (session_id) REFERENCES photogrammetry_sessions(id) NOT DEFERRABLE;

-- Contraintes pour les commandes
ALTER TABLE ONLY "public"."orders" 
    ADD CONSTRAINT "FK_a922b820eeef29ac1c6800e826a" 
    FOREIGN KEY (user_id) REFERENCES users(id) NOT DEFERRABLE;

ALTER TABLE ONLY "public"."order_items" 
    ADD CONSTRAINT "FK_145532db85752b29c57d2b7b1f1" 
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE NOT DEFERRABLE;

ALTER TABLE ONLY "public"."order_items" 
    ADD CONSTRAINT "FK_9263386c35b6b242540f9493b00" 
    FOREIGN KEY (product_id) REFERENCES products(id) NOT DEFERRABLE;

ALTER TABLE ONLY "public"."payments" 
    ADD CONSTRAINT "FK_b2f7b823a21562eeca20e72b006" 
    FOREIGN KEY (order_id) REFERENCES orders(id) NOT DEFERRABLE;

-- Contraintes pour les notifications et logs
ALTER TABLE ONLY "public"."notifications" 
    ADD CONSTRAINT "notifications_user_id_fkey" 
    FOREIGN KEY (user_id) REFERENCES users(id) NOT DEFERRABLE;

ALTER TABLE ONLY "public"."activity_logs" 
    ADD CONSTRAINT "activity_logs_user_id_fkey" 
    FOREIGN KEY (user_id) REFERENCES users(id) NOT DEFERRABLE;

-- Contraintes pour les signalements
ALTER TABLE ONLY "public"."moderation_reports" 
    ADD CONSTRAINT "moderation_reports_reported_by_fkey" 
    FOREIGN KEY (reported_by) REFERENCES users(id) NOT DEFERRABLE;

ALTER TABLE ONLY "public"."moderation_reports" 
    ADD CONSTRAINT "moderation_reports_product_id_fkey" 
    FOREIGN KEY (product_id) REFERENCES products(id) NOT DEFERRABLE;

-- Contraintes pour les nouvelles tables e-commerce
ALTER TABLE ONLY "public"."product_reviews" 
    ADD CONSTRAINT "fk_product_reviews_product" 
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;

ALTER TABLE ONLY "public"."product_reviews" 
    ADD CONSTRAINT "fk_product_reviews_user" 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY "public"."seller_reviews" 
    ADD CONSTRAINT "fk_seller_reviews_seller" 
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY "public"."seller_reviews" 
    ADD CONSTRAINT "fk_seller_reviews_user" 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY "public"."user_wishlist" 
    ADD CONSTRAINT "fk_wishlist_user" 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY "public"."user_wishlist" 
    ADD CONSTRAINT "fk_wishlist_product" 
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;

ALTER TABLE ONLY "public"."product_returns" 
    ADD CONSTRAINT "fk_returns_order" 
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE;

ALTER TABLE ONLY "public"."product_returns" 
    ADD CONSTRAINT "fk_returns_product" 
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;

ALTER TABLE ONLY "public"."product_returns" 
    ADD CONSTRAINT "fk_returns_user" 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY "public"."chat_conversations" 
    ADD CONSTRAINT "fk_chat_initiator" 
    FOREIGN KEY (initiator_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY "public"."chat_conversations" 
    ADD CONSTRAINT "fk_chat_receiver" 
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY "public"."chat_conversations" 
    ADD CONSTRAINT "fk_chat_product" 
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL;

ALTER TABLE ONLY "public"."chat_conversations" 
    ADD CONSTRAINT "fk_chat_order" 
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL;

ALTER TABLE ONLY "public"."chat_messages" 
    ADD CONSTRAINT "fk_message_conversation" 
    FOREIGN KEY (conversation_id) REFERENCES chat_conversations(id) ON DELETE CASCADE;

ALTER TABLE ONLY "public"."chat_messages" 
    ADD CONSTRAINT "fk_message_sender" 
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY "public"."reports" 
    ADD CONSTRAINT "fk_report_reporter" 
    FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY "public"."reports" 
    ADD CONSTRAINT "fk_report_user" 
    FOREIGN KEY (reported_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY "public"."reports" 
    ADD CONSTRAINT "fk_report_product" 
    FOREIGN KEY (reported_product_id) REFERENCES products(id) ON DELETE SET NULL;

ALTER TABLE ONLY "public"."reports" 
    ADD CONSTRAINT "fk_report_review" 
    FOREIGN KEY (reported_review_id) REFERENCES product_reviews(id) ON DELETE SET NULL;

ALTER TABLE ONLY "public"."reports" 
    ADD CONSTRAINT "fk_report_message" 
    FOREIGN KEY (reported_message_id) REFERENCES chat_messages(id) ON DELETE SET NULL;

ALTER TABLE ONLY "public"."product_stats" 
    ADD CONSTRAINT "fk_stats_product" 
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;

ALTER TABLE ONLY "public"."stock_history" 
    ADD CONSTRAINT "fk_stock_history_product" 
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;

-- ==================== DONNÉES INITIALES ====================

-- Insertion des rôles par défaut
INSERT INTO "public"."roles" ("id", "name", "description") VALUES
(1, 'admin', 'Administrateur avec tous les droits'),
(2, 'user', 'Utilisateur standard'),
(3, 'seller', 'Vendeur de produits')
ON CONFLICT (id) DO NOTHING;

-- Insertion des utilisateurs par défaut
INSERT INTO "public"."users" ("id", "full_name", "email", "phone_number", "is_verified", "created_at", "password_hash", "avatar_url", "last_login", "active", "online") VALUES
('7997e0ce-9fed-46ee-943c-562268fa2696', 'Admin Visio', 'admin@visio.com', '+33123456789', '1', '2025-08-05 08:55:38.110152', '$2b$12$D1rhwfJWBO.mKKC9NdmJZOvBwzSHjZbHCGvKwqTgkJCEqmF90JYfm', 'https://pleasant-vaguely-drum.ngrok-free.app/uploads/avatars/avatar_1755083153844_cdc8c3f5.jpg', '2025-08-13 15:26:37.659', '1', '0'),
('cf41e0e9-3263-415f-b30c-aaba1af2cef6', 'Evrad', 'evrad@visio.com', '+237686531231', '0', '2025-08-12 16:24:29.605615', '$2b$12$xrt7gM8oduIU9Q44LUSh1OaumVX227BPUZX2hy3UdpAWBEviOxWta', NULL, NULL, '1', '0'),
('f97425a6-1494-4d28-81db-29ae80ffd408', 'Hush', 'hush@gmail.com', '655238645', '0', '2025-08-13 13:23:37.172915', '$2b$12$VweJii3cyCkKpXD13W3rXOZoMmqUy87IjLOiA1euMDpfUyOOvOpqO', 'https://pleasant-vaguely-drum.ngrok-free.app/uploads/avatars/avatar_1755091522702_39de3213.jpg', NULL, '1', '0')
ON CONFLICT (id) DO NOTHING;

-- Attribution des rôles aux utilisateurs
INSERT INTO "public"."user_roles" ("user_id", "role_id") VALUES
('7997e0ce-9fed-46ee-943c-562268fa2696', 1),
('cf41e0e9-3263-415f-b30c-aaba1af2cef6', 2),
('f97425a6-1494-4d28-81db-29ae80ffd408', 3)
ON CONFLICT (user_id, role_id) DO NOTHING;

-- Insertion d'un token d'authentification existant
INSERT INTO "public"."auth_tokens" ("id", "user_id", "type", "expires_at", "created_at", "token") VALUES
(28, 'cf41e0e9-3263-415f-b30c-aaba1af2cef6', 'refresh', '2025-08-19 17:24:29.657', '2025-08-12 16:24:29.661405', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjZjQxZTBlOS0zMjYzLTQxNWYtYjMwYy1hYWJhMWFmMmNlZjYiLCJlbWFpbCI6ImV2cmFkQHZpc2lvLmNvbSIsImlhdCI6MTc1NTAxNTg2OSwiZXhwIjoxNzU1NjIwNjY5fQ.rWwmRk_29T9yW1JqsG91ucHYJri8WniEJXx2qqHE-yQ')
ON CONFLICT (id) DO NOTHING;

-- ====================================================================
-- FIN DU SCHÉMA SQL RESTRUCTURÉ
-- ====================================================================
