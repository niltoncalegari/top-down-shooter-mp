-- Migration: 001_initial_schema.sql
-- Descricao: Estrutura inicial do banco de dados
-- Data: 2025-12-30

-- Tabela de jogadores
CREATE TABLE IF NOT EXISTS players (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    email TEXT,
    created_at TEXT NOT NULL,
    last_login TEXT,
    level INTEGER DEFAULT 1,
    xp INTEGER DEFAULT 0,
    kills INTEGER DEFAULT 0,
    deaths INTEGER DEFAULT 0,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    matches_played INTEGER DEFAULT 0,
    current_class TEXT DEFAULT 'villager',
    last_position_x REAL DEFAULT 0,
    last_position_y REAL DEFAULT 0,
    last_position_z REAL DEFAULT 0
);

-- Tabela de sessoes ativas
CREATE TABLE IF NOT EXISTS active_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    peer_id INTEGER NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (username) REFERENCES players(username) ON DELETE CASCADE
);

-- Tabela de historico de partidas
CREATE TABLE IF NOT EXISTS match_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    match_date TEXT NOT NULL,
    duration REAL NOT NULL,
    won INTEGER NOT NULL,
    kills INTEGER NOT NULL,
    deaths INTEGER NOT NULL,
    damage_dealt REAL NOT NULL,
    damage_taken REAL NOT NULL,
    class_used TEXT NOT NULL,
    FOREIGN KEY (username) REFERENCES players(username) ON DELETE CASCADE
);

-- Tabela de inventario (para futuro)
CREATE TABLE IF NOT EXISTS inventory (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    item_id TEXT NOT NULL,
    quantity INTEGER DEFAULT 1,
    acquired_at TEXT NOT NULL,
    FOREIGN KEY (username) REFERENCES players(username) ON DELETE CASCADE
);

-- Indices para performance
CREATE INDEX IF NOT EXISTS idx_players_username ON players(username);
CREATE INDEX IF NOT EXISTS idx_players_level ON players(level DESC);
CREATE INDEX IF NOT EXISTS idx_players_xp ON players(xp DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_username ON active_sessions(username);
CREATE INDEX IF NOT EXISTS idx_match_history_username ON match_history(username);
CREATE INDEX IF NOT EXISTS idx_match_history_date ON match_history(match_date DESC);

-- Views para facilitar queries
CREATE VIEW IF NOT EXISTS player_stats AS
SELECT 
    username,
    level,
    xp,
    kills,
    deaths,
    CASE WHEN deaths > 0 THEN CAST(kills AS REAL) / deaths ELSE kills END as kd_ratio,
    wins,
    losses,
    matches_played,
    CASE WHEN matches_played > 0 THEN CAST(wins AS REAL) / matches_played * 100 ELSE 0 END as win_rate
FROM players;

CREATE VIEW IF NOT EXISTS player_ranking AS
SELECT 
    username,
    level,
    xp,
    kills,
    deaths,
    CASE WHEN deaths > 0 THEN CAST(kills AS REAL) / deaths ELSE kills END as kd_ratio,
    wins,
    matches_played
FROM players
ORDER BY xp DESC, level DESC, kills DESC
LIMIT 100;

