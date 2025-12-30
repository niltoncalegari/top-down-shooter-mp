# 🔄 Migração para SQLite - Guia Completo

## ✅ O Que Foi Criado

### 📁 Estrutura de Pastas
```
database/
├── db/                          # Banco de dados SQLite
│   ├── game.db                  # (será criado automaticamente)
│   └── README.md
├── migrations/                  # Migrations SQL
│   └── 001_initial_schema.sql  # Schema inicial
├── DatabaseManager.gd           # Versão antiga (JSON)
├── DatabaseManagerSQLite.gd     # Nova versão (SQLite)
├── AuthManager.gd
├── PlayerStatsManager.gd
└── SQLITE_SETUP.md             # Guia de setup
```

### 📊 Tabelas Criadas
- `players` - Dados dos jogadores
- `active_sessions` - Sessões ativas  
- `match_history` - Histórico de partidas
- `inventory` - Inventário (futuro)
- `schema_migrations` - Controle de migrations

## 🚀 Passos para Ativar o SQLite

### 1️⃣ Instalar Plugin SQLite

**Opção A: Via Asset Library (Mais Fácil)**
1. Abra o Godot
2. Clique em **"AssetLib"** (topo da tela)
3. Pesquise por **"SQLite"**
4. Baixe **"godot-sqlite" by 2shady4u**
5. Clique em **"Install"**
6. Vá em `Project → Project Settings → Plugins`
7. Ative **"godot-sqlite"** ✅

**Opção B: Download Manual**
1. Acesse: https://github.com/2shady4u/godot-sqlite/releases
2. Baixe a última versão para **Godot 4.x**
3. Extraia para: `C:\Users\nilto\REPO\top-down-shooter-mp\addons\godot-sqlite\`
4. No Godot: `Project → Project Settings → Plugins`
5. Ative **"godot-sqlite"** ✅

### 2️⃣ Atualizar o Autoload

Edite `project.godot` e substitua:

```ini
# ANTES
DatabaseManager="*res://database/DatabaseManager.gd"

# DEPOIS  
DatabaseManager="*res://database/DatabaseManagerSQLite.gd"
```

Ou faça manualmente no Godot:
1. `Project → Project Settings → Autoload`
2. Remova `DatabaseManager` antigo
3. Adicione `DatabaseManagerSQLite.gd` como `DatabaseManager`

### 3️⃣ Reiniciar o Godot

1. Feche o Godot completamente
2. Reabra o projeto
3. As migrations serão aplicadas automaticamente
4. O banco `game.db` será criado

### 4️⃣ Verificar Instalação

No console do Godot, execute:
```gdscript
print("DB Ready: ", DatabaseManager.db_ready)
print("Players table exists: ", DatabaseManager.player_exists("test"))
```

Se funcionar, está pronto! ✅

## 📍 Caminho do Banco de Dados

### Para DBeaver / Visualização

**Durante Desenvolvimento:**
```
C:\Users\nilto\REPO\top-down-shooter-mp\database\db\game.db
```

**Após Compilar o Jogo:**
```
C:\Users\nilto\AppData\Roaming\Godot\app_userdata\Twin Shooter Starting Kit\game.db
```

## 🔧 Conectar no DBeaver

1. **Abra o DBeaver**
2. **Database → New Database Connection**
3. Selecione **SQLite**
4. **Path:**
   ```
   C:\Users\nilto\REPO\top-down-shooter-mp\database\db\game.db
   ```
5. **Test Connection** ✅
6. **Finish**

## 📊 Queries Úteis no DBeaver

### Ver todos os jogadores
```sql
SELECT * FROM players ORDER BY xp DESC;
```

### Ver ranking
```sql
SELECT * FROM player_ranking;
```

### Ver sessões ativas
```sql
SELECT * FROM active_sessions;
```

### Ver histórico de partidas
```sql
SELECT * FROM match_history ORDER BY match_date DESC LIMIT 10;
```

### Ver stats de um jogador específico
```sql
SELECT * FROM player_stats WHERE username = 'seu_usuario';
```

## 🔄 Migrations

### Aplicar Nova Migration

1. Crie um arquivo em `database/migrations/`
2. Nomeie: `002_descricao.sql` (próximo número)
3. Escreva o SQL
4. Reinicie o jogo - será aplicada automaticamente

### Ver Migrations Aplicadas

```sql
SELECT * FROM schema_migrations ORDER BY applied_at DESC;
```

## 🗑️ Resetar Banco de Dados

Para limpar tudo e começar do zero:

**PowerShell:**
```powershell
Remove-Item C:\Users\nilto\REPO\top-down-shooter-mp\database\db\game.db
```

**CMD:**
```cmd
del C:\Users\nilto\REPO\top-down-shooter-mp\database\db\game.db
```

O banco será recriado automaticamente no próximo início.

## ⚠️ Migração de Dados (JSON → SQLite)

Se você já tem dados no sistema JSON antigo:

1. **Backup dos dados JSON:**
   ```
   %APPDATA%\Godot\app_userdata\Twin Shooter Starting Kit\
   ├── players_database.json
   └── active_sessions.json
   ```

2. **Os dados serão perdidos na migração**
3. **Jogadores precisarão criar novas contas**

(Se precisar migrar dados, posso criar um script para isso)

## ✅ Vantagens do SQLite

- ✅ **Performance:** Queries muito mais rápidas
- ✅ **Integridade:** Constraints e foreign keys
- ✅ **Histórico:** Tabela de match_history
- ✅ **Views:** Queries otimizadas prontas
- ✅ **Migrations:** Controle de versão do schema
- ✅ **Profissional:** Padrão da indústria
- ✅ **DBeaver:** Visualização e queries SQL
- ✅ **Escalável:** Suporta milhares de jogadores

## 🎯 Próximos Passos

Após ativar o SQLite:

1. ✅ Testar login/registro
2. ✅ Testar multiplayer
3. ✅ Ver dados no DBeaver
4. ✅ Continuar desenvolvimento

---

**Dúvidas? Verifique:**
- `database/SQLITE_SETUP.md`
- `database/db/README.md`
- Console do Godot para erros

