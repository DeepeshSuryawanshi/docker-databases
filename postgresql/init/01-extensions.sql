-- UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Cryptographic functions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Case-insensitive text
CREATE EXTENSION IF NOT EXISTS "citext";

-- Fast LIKE / ILIKE / fuzzy text searches
CREATE EXTENSION IF NOT EXISTS "pg_trgm";