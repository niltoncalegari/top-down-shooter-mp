# 📁 Database Directory

Este diretório contém o banco de dados SQLite do jogo.

## 📍 Localização do Banco de Dados

### Durante Desenvolvimento (Editor Godot)
```
C:\Users\nilto\REPO\top-down-shooter-mp\database\db\game.db
```

### Durante Execução (Jogo Compilado)
```
C:\Users\nilto\AppData\Roaming\Godot\app_userdata\Twin Shooter Starting Kit\game.db
```

## 🔧 Como Conectar no DBeaver

1. **Abra o DBeaver**
2. **Nova Conexão** → **SQLite**
3. **Path do Database:**
   - **DEV:** `C:\Users\nilto\REPO\top-down-shooter-mp\database\db\game.db`
   - **PROD:** `C:\Users\nilto\AppData\Roaming\Godot\app_userdata\Twin Shooter Starting Kit\game.db`
4. **Test Connection** → **Finish**

## 📊 Estrutura das Tabelas

### `players`
Armazena dados dos jogadores (usuário, senha, stats, etc.)

### `active_sessions`
Controla sessões ativas (previne login duplo)

### `match_history`
Histórico de todas as partidas jogadas

### `inventory`
Inventário dos jogadores (para futuro)

## 🔄 Migrations

As migrations estão em: `database/migrations/`

### Aplicar Migrations

As migrations são aplicadas automaticamente quando o jogo inicia pela primeira vez.

Para aplicar manualmente:
```sql
-- No DBeaver ou SQLite CLI
.read database/migrations/001_initial_schema.sql
```

## 🧪 Queries Úteis

### Ver Ranking
```sql
SELECT * FROM player_ranking;
```

### Ver Stats de um Jogador
```sql
SELECT * FROM player_stats WHERE username = 'seu_usuario';
```

### Ver Sessões Ativas
```sql
SELECT * FROM active_sessions;
```

### Ver Histórico de Partidas
```sql
SELECT * FROM match_history WHERE username = 'seu_usuario' ORDER BY match_date DESC LIMIT 10;
```

## 🗑️ Limpar Banco de Dados

Para resetar o banco de dados:
```bash
# Apagar o arquivo
rm database/db/game.db

# Ou no PowerShell
Remove-Item database\db\game.db
```

O banco será recriado automaticamente no próximo início do jogo.

