-- PostgreSQL Script - Base complète eCommerce Flutter + 3D/AR + Photogrammétrie

-- ========== 1. RÔLES ET UTILISATEURS ==========
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    password_hash TEXT NOT NULL,
    avatar_url TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    active BOOLEAN DEFAULT TRUE,
    online BOOLEAN DEFAULT FALSE
);

CREATE TABLE user_roles (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role_id INT REFERENCES roles(id),
    PRIMARY KEY (user_id, role_id)
);

-- ========== 2. CATÉGORIES ET PRODUITS ==========
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL,
    stock INT DEFAULT 0,
    category_id INT REFERENCES categories(id),
    seller_id UUID REFERENCES users(id),
    thumbnail_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========== 3. IMAGES ET MODÈLES 3D ==========
CREATE TABLE product_images (
    id SERIAL PRIMARY KEY,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE
);

CREATE TABLE product_models (
    id SERIAL PRIMARY KEY,
    product_id UUID REFERENCES products(id),
    model_url TEXT,
    format VARCHAR(10), -- glb, obj, usdz
    generated_by TEXT, -- AI / manual / photogrammetry
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========== 4. COMMANDES & PAIEMENTS ==========
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'pending',
    total NUMERIC(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    quantity INT NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL
);

CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id UUID REFERENCES orders(id),
    payment_method VARCHAR(50),
    status VARCHAR(50),
    paid_at TIMESTAMP
);

-- ========== 5. NOTIFICATIONS ==========
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    title TEXT,
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========== 6. PHOTOGRAMMÉTRIE ==========
CREATE TABLE photogrammetry_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    product_id UUID REFERENCES products(id),
    device_model TEXT,
    burst_mode BOOLEAN,
    image_count INT,
    status VARCHAR(50) DEFAULT 'pending',
    model_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE photogrammetry_images (
    id SERIAL PRIMARY KEY,
    session_id UUID REFERENCES photogrammetry_sessions(id),
    image_url TEXT
);

-- ========== 7. MODÉRATION & LOGS ==========
CREATE TABLE moderation_reports (
    id SERIAL PRIMARY KEY,
    reported_by UUID REFERENCES users(id),
    product_id UUID REFERENCES products(id),
    reason TEXT,
    status VARCHAR(50) DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE activity_logs (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    action TEXT,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========== 8. SÉCURITÉ & TOKENS ==========
CREATE TABLE auth_tokens (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    token TEXT,
    type VARCHAR(50), -- access / refresh / recovery
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
