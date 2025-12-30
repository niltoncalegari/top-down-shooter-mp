# 📁 Guia do Sistema de Persistência

## 📍 Onde os Dados São Salvos

Os dados do jogo são salvos em **arquivos JSON** no diretório do usuário do Godot:

```
📂 C:\Users\[SEU_USUARIO]\AppData\Roaming\Godot\app_userdata\Twin Shooter Starting Kit\
   ├── players_database.json  (dados dos jogadores)
   └── active_sessions.json   (sessões ativas)
```

### Como Acessar os Arquivos

1. **Via Windows Explorer:**
   - Pressione `Win + R`
   - Digite: `%APPDATA%\Godot\app_userdata\Twin Shooter Starting Kit`
   - Pressione Enter

2. **Via PowerShell:**
   ```powershell
   cd "$env:APPDATA\Godot\app_userdata\Twin Shooter Starting Kit"
   ```

## 📊 Estrutura dos Dados

### `players_database.json`

```json
{
	"username": {
		"username": "player1",
		"password_hash": "...",
		"email": "player@example.com",
		"created_at": "2025-12-29T10:30:00",
		"last_login": "2025-12-29T15:45:00",
		"level": 5,
		"xp": 2350,
		"kills": 42,
		"deaths": 18,
		"wins": 12,
		"losses": 8,
		"matches_played": 20,
		"current_class": "warrior",
		"last_position": {"x": 10.5, "y": 0.0, "z": -5.2},
		"inventory": [],
		"equipped_items": {}
	}
}
```

### `active_sessions.json`

```json
{
	"player1": 1,
	"player2": 2
}
```

## 🎮 Como Funciona

### 1. **Login/Registro**

Quando um jogador faz login:
1. `AuthManager` valida as credenciais
2. `DatabaseManager` cria uma sessão ativa
3. Dados do jogador são carregados (classe, stats, etc.)

### 2. **Durante a Partida**

O `PlayerStatsManager` rastreia em tempo real:
- ✅ Kills
- ✅ Deaths
- ✅ Classe atual
- ✅ Dano causado/recebido

### 3. **Ao Trocar de Classe**

Quando o jogador troca de classe:
1. `PlayerEntity._set_player_class()` é chamado
2. `PlayerStatsManager.update_player_class()` atualiza em memória
3. Ao final da partida, a classe é salva no banco

### 4. **Ao Final da Partida**

Quando a partida termina:
1. `PlayerStatsManager.end_match()` é chamado
2. Stats são salvos no `DatabaseManager`
3. XP e nível são atualizados
4. Classe atual é persistida

### 5. **Logout**

Quando o jogador faz logout:
1. Sessão é removida
2. Dados finais são salvos
3. Volta para a tela de login

## 🔧 Autoloads Criados

### `DatabaseManager`
- **Caminho:** `res://database/DatabaseManager.gd`
- **Função:** Gerencia persistência em JSON
- **Métodos Principais:**
  - `create_player(username, password_hash, email)`
  - `get_player(username)`
  - `update_player(username, data)`
  - `save_player_class(username, class_name)`
  - `get_player_class(username)`
  - `add_match_stats(username, won, kills, deaths)`
  - `get_ranking(limit)`

### `AuthManager`
- **Caminho:** `res://database/AuthManager.gd`
- **Função:** Gerencia autenticação e sessões
- **Métodos Principais:**
  - `register(username, password, email)`
  - `login(username, password, peer_id)`
  - `logout()`
  - `is_logged_in()`
  - `get_current_user()`

### `PlayerStatsManager`
- **Caminho:** `res://database/PlayerStatsManager.gd`
- **Função:** Rastreia stats da partida atual
- **Métodos Principais:**
  - `start_match()`
  - `end_match()`
  - `register_player(peer_id, username, class_name)`
  - `record_kill(killer_id, victim_id)`
  - `record_death(player_id)`
  - `get_player_stats(peer_id)`
  - `get_leaderboard()`

## 📈 Sistema de XP e Níveis

### Como Funciona

- **Vitória:** +100 XP
- **Derrota:** +25 XP
- **Nível:** XP / 500 + 1

Exemplo:
- 0-499 XP = Nível 1
- 500-999 XP = Nível 2
- 1000-1499 XP = Nível 3
- etc.

## 🎯 HUD de Stats

O `PlayerStatsHUD` mostra em tempo real:
- 👤 Nome do jogador
- ⚔️ Classe atual
- 💀 Kills
- ☠️ Deaths
- 📊 K/D Ratio

### Como Adicionar ao Jogo

1. Instancie `PlayerStatsHUD.tscn` na cena principal
2. O HUD se atualiza automaticamente

## 🧪 Como Testar

### 1. **Criar Conta e Fazer Login**
```
1. Inicie o jogo
2. Clique em "Cadastro"
3. Preencha os dados
4. Faça login
```

### 2. **Verificar Persistência**
```
1. Entre em uma partida
2. Troque de classe usando uma Hat Machine
3. Saia do jogo
4. Verifique o arquivo players_database.json
5. Faça login novamente
6. A classe deve estar salva
```

### 3. **Testar Stats**
```
1. Entre em uma partida com 2+ jogadores
2. Use o comando de debug para ver stats:
   PlayerStatsManager.print_stats()
3. Ao final da partida, verifique o JSON
```

## 🐛 Debug

### Ver Stats em Tempo Real

No console do Godot:
```gdscript
PlayerStatsManager.print_stats()
```

### Ver Dados de um Jogador

```gdscript
var data = DatabaseManager.get_player_full_data("username")
print(data)
```

### Ver Ranking

```gdscript
var ranking = DatabaseManager.get_ranking(10)
for player in ranking:
    print(player.username, " - Level ", player.level, " - XP ", player.xp)
```

### Limpar Todas as Sessões

```gdscript
DatabaseManager.clear_all_sessions()
```

## ⚠️ Importante

1. **Não use SQLite do outro projeto:** O caminho `C:\Users\nilto\REPO\gd-mp\database\data\game_stats.db` é de OUTRO projeto.

2. **Backup dos Dados:** Os arquivos JSON estão em `%APPDATA%\Godot\app_userdata\`. Faça backup se necessário.

3. **Migração para SQLite:** O sistema atual usa JSON para simplicidade. Pode ser migrado para SQLite no futuro (Phase 3.3).

4. **Stats de Combate:** O sistema está pronto, mas a integração com combate real será feita na Phase 4.

## 📝 Próximos Passos

- [ ] Implementar Ranking UI
- [ ] Tela de perfil do jogador
- [ ] Histórico de partidas
- [ ] Migrar para SQLite (opcional)
- [ ] Sistema de combate real (Phase 4)

