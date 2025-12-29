# Especificação do Banco de Dados (SQLite)

## Tabelas

### 1. `players`
- `id`: INTEGER (Primary Key)
- `steam_id`: TEXT (Opcional, para futura integração)
- `username`: TEXT
- `level`: INTEGER
- `experience`: INTEGER

### 2. `match_history`
- `match_id`: INTEGER (Primary Key)
- `player_id`: INTEGER (Foreign Key)
- `class_used`: TEXT (Guerreiro, Mago, etc.)
- `kills`: INTEGER
- `deaths`: INTEGER
- `assists`: INTEGER
- `captured_artifacts`: INTEGER
- `result`: TEXT (Vitoria/Derrota)
- `match_date`: DATETIME

### 3. `player_skins`
- `player_id`: INTEGER
- `class_type`: TEXT
- `skin_id`: TEXT
- `is_unlocked`: BOOLEAN

## Implementação no Godot
Usaremos um Singleton `DatabaseManager.gd` para gerenciar as queries. Se não houver o plugin `godot-sqlite` instalado, utilizaremos uma solução via GDScript ou sugeriremos a instalação do addon via AssetLib.

