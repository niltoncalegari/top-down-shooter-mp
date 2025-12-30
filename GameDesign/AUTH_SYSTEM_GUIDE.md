# 🔐 Guia do Sistema de Autenticação

## Visão Geral

O sistema de autenticação gerencia login, cadastro e persistência de dados dos jogadores usando arquivos JSON.

## Arquivos de Dados

Os dados são salvos em `user://` (AppData no Windows):

### `players_database.json`
Contém todos os dados dos jogadores:
```json
{
  "username": {
    "username": "player1",
    "password_hash": "abc123...",
    "email": "optional@email.com",
    "created_at": "2024-12-29 10:30:00",
    "last_login": "2024-12-29 12:00:00",
    "level": 5,
    "xp": 2500,
    "kills": 50,
    "deaths": 30,
    "wins": 10,
    "losses": 5,
    "matches_played": 15
  }
}
```

### `active_sessions.json`
Rastreia sessões ativas para prevenir login duplo:
```json
{
  "username": peer_id
}
```

## Uso em GDScript

### DatabaseManager

```gdscript
# Criar jogador
DatabaseManager.create_player(username, password_hash, email)

# Verificar se existe
if DatabaseManager.player_exists(username):
    print("Usuário existe!")

# Obter dados
var player_data = DatabaseManager.get_player(username)
print("Level: ", player_data["level"])

# Atualizar dados
DatabaseManager.update_player(username, {"level": 10, "xp": 5000})

# Gerenciar sessões
DatabaseManager.create_session(username, peer_id)
DatabaseManager.is_user_logged_in(username)  # true/false
DatabaseManager.remove_session(username)

# Adicionar stats de partida
DatabaseManager.add_match_stats(username, won=true, kills=5, deaths=2)

# Obter ranking
var top_players = DatabaseManager.get_ranking(10)  # Top 10
for player in top_players:
    print(player["username"], " - Level ", player["level"])
```

### AuthManager

```gdscript
# Conectar sinais
AuthManager.login_success.connect(_on_login_success)
AuthManager.login_failed.connect(_on_login_failed)
AuthManager.register_success.connect(_on_register_success)
AuthManager.register_failed.connect(_on_register_failed)

# Registrar
AuthManager.register(username, password, email)

# Login
AuthManager.login(username, password, peer_id)

# Logout
AuthManager.logout()  # Logout do usuário atual
AuthManager.logout(username)  # Logout de usuário específico
AuthManager.logout_by_peer(peer_id)  # Logout por peer_id

# Verificações
if AuthManager.is_logged_in():
    var user = AuthManager.get_current_user()
    var peer = AuthManager.get_current_peer_id()
    print("Logado como: ", user)

# Obter dados do usuário
var data = AuthManager.get_user_data()  # Usuário atual
var data2 = AuthManager.get_user_data("outro_usuario")  # Outro usuário
```

## Validações

### Username
- ✅ 3-20 caracteres
- ✅ Apenas letras, números e underscore (_)
- ✅ Único no sistema

### Senha
- ✅ 6-50 caracteres
- ✅ Hash SHA256 (considerar bcrypt para produção)

### Email
- ✅ Formato válido (regex)
- ✅ Opcional

## Fluxo de Uso

### 1. Primeiro Acesso (Cadastro)
```
Jogador abre o jogo
  → LoginScreen aparece
  → Clica em "Cadastro"
  → Preenche dados
  → Clica "CRIAR CONTA"
  → AuthManager.register()
  → DatabaseManager.create_player()
  → Sucesso! Redirecionado para aba Login
```

### 2. Login
```
Jogador faz login
  → Preenche username/senha
  → Clica "ENTRAR"
  → AuthManager.login()
  → Verifica se usuário existe
  → Verifica se já está logado (previne login duplo)
  → Verifica senha
  → DatabaseManager.create_session()
  → Atualiza last_login
  → Emite login_success
  → Redireciona para multiplayer
```

### 3. Multiplayer
```
Jogador no menu multiplayer
  → Username aparece no topo
  → Clica "Host" ou "Join"
  → NetworkManager usa username como player_info["name"]
  → Joga normalmente
```

### 4. Logout
```
Jogador clica "Logout"
  → AuthManager.logout()
  → DatabaseManager.remove_session()
  → Volta para tela de login

OU

Jogador desconecta/fecha o jogo
  → NetworkManager._on_player_disconnected()
  → AuthManager.logout_by_peer(peer_id)
  → Sessão removida automaticamente
```

## Segurança

### ✅ Implementado
- Hash de senhas (SHA256)
- Prevenção de login duplo
- Validação de entrada
- Sessões rastreáveis
- Cleanup automático

### ⚠️ Para Produção
- Usar bcrypt/argon2 para hash de senha
- Migrar de JSON para SQLite
- Adicionar rate limiting
- Implementar recuperação de senha
- Verificação de email
- Tokens de sessão com expiração
- HTTPS para comunicação cliente-servidor

## Troubleshooting

### "Usuário já está logado"
**Causa:** Sessão anterior não foi limpa
**Solução:** 
```gdscript
# Limpar todas as sessões (servidor)
DatabaseManager.clear_all_sessions()
```

### Arquivo de banco corrompido
**Causa:** JSON inválido
**Solução:** Deletar `user://players_database.json` e reiniciar

### Localização dos arquivos no Windows
```
C:\Users\[SEU_USUARIO]\AppData\Roaming\Godot\app_userdata\[NOME_DO_PROJETO]\
```

## Migração Futura para SQLite

Para migrar de JSON para SQLite:

1. Instalar GDExtension de SQLite
2. Substituir `FileAccess` por queries SQL
3. Manter mesma interface pública
4. Código do jogo não precisa mudar!

Exemplo:
```gdscript
# JSON (atual)
players_data[username] = {...}

# SQLite (futuro)
db.query("INSERT INTO players ...")
```

## Exemplo Completo

```gdscript
# Em uma cena de combate
func on_player_killed(killer_username, victim_username):
    # Atualizar stats
    var killer_data = AuthManager.get_user_data(killer_username)
    var victim_data = AuthManager.get_user_data(victim_username)
    
    # Adicionar 1 kill para o killer
    DatabaseManager.update_player(killer_username, {
        "kills": killer_data["kills"] + 1
    })
    
    # Adicionar 1 death para a vítima
    DatabaseManager.update_player(victim_username, {
        "deaths": victim_data["deaths"] + 1
    })
    
    print(killer_username, " matou ", victim_username, "!")

# No fim da partida
func on_match_end(winners: Array, losers: Array):
    for username in winners:
        DatabaseManager.add_match_stats(username, true, 10, 3)
    
    for username in losers:
        DatabaseManager.add_match_stats(username, false, 5, 8)
    
    # Mostrar ranking
    var top_10 = DatabaseManager.get_ranking(10)
    show_ranking_ui(top_10)
```

## API Reference

### Sinais

```gdscript
# AuthManager
signal login_success(username: String)
signal login_failed(error_message: String)
signal register_success(username: String)
signal register_failed(error_message: String)

# DatabaseManager
signal data_loaded()
signal data_saved()
```

### Funções Principais

```gdscript
# DatabaseManager
create_player(username, password_hash, email) -> bool
get_player(username) -> Dictionary
player_exists(username) -> bool
update_player(username, data) -> bool
create_session(username, peer_id) -> bool
remove_session(username) -> void
is_user_logged_in(username) -> bool
add_match_stats(username, won, kills, deaths) -> void
get_ranking(limit) -> Array

# AuthManager
register(username, password, email) -> void
login(username, password, peer_id) -> void
logout(username) -> void
logout_by_peer(peer_id) -> void
is_logged_in() -> bool
get_current_user() -> String
get_user_data(username) -> Dictionary
```

