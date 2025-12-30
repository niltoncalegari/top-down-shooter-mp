# 🔄 Guia de Migração de Dados (JSON → SQLite)

## 📋 Visão Geral

Este guia explica como migrar seus dados existentes do sistema JSON para SQLite.

## ⚠️ IMPORTANTE - Leia Antes de Migrar

1. **Faça backup antes!** Os arquivos JSON não serão deletados, mas é sempre bom garantir.
2. **Feche o jogo** antes de migrar
3. **Ative o SQLite primeiro** (veja MIGRACAO_SQLITE.md)
4. **Jogadores não precisarão criar novas contas** - senhas são preservadas

## 🎯 Opção 1: Migração via Interface (Recomendado)

### Passo a Passo:

1. **Abra o Godot**

2. **Abra a cena de migração:**
   ```
   File → Open Scene → tools/MigrationScene.tscn
   ```

3. **Execute a cena (F5)**

4. **Siga os passos na interface:**
   - ✅ **Passo 1:** Clique em "Criar Backup dos JSON"
   - ✅ **Passo 2:** Clique em "Migrar Dados"
   - ✅ **Passo 3:** Clique em "Verificar Migração"

5. **Confira os resultados:**
   - Verde = Sucesso
   - Vermelho = Erro (verifique o log)

6. **Feche a ferramenta**

## 🖥️ Opção 2: Migração via Script (Avançado)

### Adicione o script temporariamente:

```gdscript
# Em qualquer cena temporaria
extends Node

var migration_tool

func _ready():
    migration_tool = preload("res://database/MigrationTool.gd").new()
    add_child(migration_tool)
    
    # Aguardar DatabaseManager estar pronto
    await get_tree().create_timer(1.0).timeout
    
    # Criar backup
    migration_tool.backup_json_files()
    
    # Migrar
    var result = migration_tool.start_migration()
    
    # Ver resultado
    if result.success:
        print("Migracao concluida!")
        print("Jogadores migrados: ", result.players)
    else:
        print("Erro: ", result.error)
    
    # Verificar
    migration_tool.verify_migration()
    
    # Ver log completo
    migration_tool.print_summary()
```

## 📊 O Que É Migrado

### ✅ Dados dos Jogadores
- Username
- Password hash (SHA256)
- Email
- Data de criação
- Último login
- Level
- XP
- Kills
- Deaths
- Wins
- Losses
- Partidas jogadas
- Classe atual
- Última posição

### ❌ Não Migrado
- Sessões ativas (são temporárias)
- Inventário (ainda não implementado)

## 📍 Localização dos Arquivos

### Arquivos JSON Originais:
```
C:\Users\nilto\AppData\Roaming\Godot\app_userdata\Twin Shooter Starting Kit\
├── players_database.json
└── active_sessions.json
```

### Novo Banco SQLite:
```
C:\Users\nilto\REPO\top-down-shooter-mp\database\db\game.db
```

### Backup (criado automaticamente):
```
C:\Users\nilto\AppData\Roaming\Godot\app_userdata\Twin Shooter Starting Kit\
└── backup_json_YYYY-MM-DD-HH-MM-SS\
    ├── players_database.json
    └── active_sessions.json
```

## 🔍 Verificar Migração

### No DBeaver:

```sql
-- Ver todos os jogadores migrados
SELECT username, level, xp, kills, deaths, created_at 
FROM players 
ORDER BY xp DESC;

-- Contar jogadores
SELECT COUNT(*) as total FROM players;

-- Ver jogadores com mais XP
SELECT * FROM player_ranking LIMIT 10;
```

### No Godot (Console):

```gdscript
# Verificar se DatabaseManager esta usando SQLite
print("DB Ready: ", DatabaseManager.db_ready)

# Contar jogadores
DatabaseManager.db.query("SELECT COUNT(*) as count FROM players")
print("Total players: ", DatabaseManager.db.query_result[0]["count"])

# Listar jogadores
DatabaseManager.db.query("SELECT username, level, xp FROM players ORDER BY xp DESC")
for player in DatabaseManager.db.query_result:
    print(player.username, " - Level ", player.level, " - XP ", player.xp)
```

## ⚠️ Troubleshooting

### Erro: "DatabaseManager not ready"
**Solução:** 
- Verifique se o plugin SQLite está ativo
- Verifique se o autoload está configurado corretamente
- Reinicie o Godot

### Erro: "JSON files not found"
**Solução:**
- Confirme o caminho: `%APPDATA%\Godot\app_userdata\Twin Shooter Starting Kit\`
- Verifique se há dados para migrar
- Se não houver dados, não precisa migrar

### Erro: "Player already exists"
**Solução:**
- Normal se rodar a migração mais de uma vez
- Jogadores duplicados são ignorados automaticamente
- Nenhum dado é perdido

### Número de jogadores diferente
**Solução:**
- Verifique o log para ver quais jogadores falharam
- Tente migrar novamente (duplicados são ignorados)
- Verifique o backup se necessário

## 🔄 Migrar Novamente

Se precisar rodar a migração novamente:

1. **Jogadores duplicados são ignorados** automaticamente
2. **Nenhum dado é sobrescrito** sem querer
3. **É seguro rodar múltiplas vezes**

Para resetar e migrar do zero:
```powershell
# 1. Deletar o SQLite
Remove-Item C:\Users\nilto\REPO\top-down-shooter-mp\database\db\game.db

# 2. Reiniciar Godot (recria o banco)

# 3. Rodar migração novamente
```

## 📝 Checklist Pós-Migração

- [ ] Backup criado com sucesso
- [ ] Migração concluída sem erros
- [ ] Verificação OK (números batem)
- [ ] Teste de login com conta migrada
- [ ] Dados corretos no DBeaver
- [ ] Jogo funcionando normalmente

## ✅ Sucesso!

Após a migração bem-sucedida:

1. **Os arquivos JSON ainda existem** (não são deletados)
2. **O jogo usará apenas SQLite** daqui pra frente
3. **Jogadores podem fazer login normalmente**
4. **Todos os stats foram preservados**
5. **Pode deletar os JSON se quiser** (após confirmar que tudo funciona)

## 🆘 Suporte

Se algo der errado:

1. **Veja o log completo** na interface ou console
2. **Verifique o backup** criado automaticamente
3. **Restaure os JSON** se necessário (copie do backup)
4. **Tente novamente** seguindo este guia

---

**Dúvidas?** Verifique também:
- `MIGRACAO_SQLITE.md` - Setup do SQLite
- `database/db/README.md` - Informações do banco
- `database/SQLITE_SETUP.md` - Configuração do plugin

