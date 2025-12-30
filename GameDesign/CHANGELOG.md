# Changelog - Top Down Shooter Multiplayer

## [2024-12-29] - Sistema Multiplayer + Hat Machines

### ✅ Implementado

#### Sistema de Multiplayer Básico
- **NetworkManager**: Sistema de host/join funcional com ENet
- **MultiplayerSpawner**: Gerenciamento automático de spawn de jogadores
- **PlayerEntity**: Sincronização de posição e rotação entre todos os clientes
- **Autoridade**: Sistema de autoridade configurado em `_enter_tree()`
- **SceneReplicationConfig**: Otimizado com `replication_mode = 1` (on_change)

#### Sistema de Classes (Hat Machines)
- **HatMachine.gd**: Área de interação para trocar de classe
- **RPC de Troca de Classe**: `change_class_rpc()` sincroniza mudança em todos os clientes
- **5 Classes Criadas**:
  - 🔴 **Guerreiro**: 200 HP, 4.0 Speed, 25 Damage (Vermelho)
  - 🔵 **Mago**: 100 HP, 4.5 Speed, 30 Damage (Azul)
  - 🟢 **Arqueiro**: 120 HP, 5.0 Speed, 20 Damage (Verde)
  - 🟡 **Sacerdote**: 120 HP, 4.2 Speed, 15 Damage (Amarelo)
  - ⚪ **Aldeão**: 100 HP, 4.5 Speed, 10 Damage (Cinza)
- **Feedback Visual**: Sistema de cores para identificar classe de cada jogador
- **Stats Sincronizados**: HP, velocidade e dano aplicados corretamente

### 🔧 Correções Aplicadas
1. Mudança de `global_position` para `position` no SceneReplicationConfig
2. Autoridade definida em `_enter_tree()` em vez de `_ready()`
3. Uso de `call_deferred()` para adicionar players à árvore
4. RPC com `"call_local"` para garantir execução em todos os clientes
5. Logs detalhados para debug de sincronização

### 📁 Arquivos Modificados
- `networking/NetworkManager.gd`
- `networking/MultiplayerMenu.gd`
- `scenes/game_manager.gd`
- `scenes/main.tscn` (adicionado MultiplayerSpawner)
- `characters/player/PlayerEntity.gd`
- `characters/player/PlayerEntity.tscn`
- `assets/objects/hat_machines/HatMachine.gd`

### 📁 Arquivos Criados
- `characters/classes/resources/priest.tres`
- `characters/classes/resources/ranger.tres`
- `characters/classes/resources/villager.tres`
- `.gitignore` (adicionado high_level_example/)

### 🎮 Como Testar
1. Execute 2 instâncias do jogo
2. Instância 1: Clique em "Host"
3. Instância 2: Digite "127.0.0.1" e clique em "Join"
4. Mova os personagens - deve sincronizar
5. Entre nas Hat Machines (caixas azuis) para trocar de classe
6. Observe a mudança de cor do personagem em ambas as instâncias

### 🐛 Problemas Conhecidos
- [ ] Hat Machines não têm cooldown (pode trocar infinitamente)
- [ ] Não há modelos 3D de chapéus (apenas cores)
- [ ] Sistema de combate ainda não implementado

### 📋 Próximos Passos
Ver `Roadmap.md` - Phase 3.2: Persistência de Dados

---

## [2024-12-29] - Sistema de Login, Cadastro e Autenticação

### ✅ Implementado

#### Sistema de Autenticação Completo
- **DatabaseManager**: Gerenciamento de dados em JSON
  - CRUD de jogadores (Create, Read, Update, Delete)
  - Sistema de sessões ativas
  - Persistência em `user://players_database.json`
  - Controle de sessões em `user://active_sessions.json`
  
- **AuthManager**: Gerenciador de autenticação
  - Hash de senhas com SHA256
  - Validação de username (3-20 caracteres, apenas letras/números/_)
  - Validação de senha (6-50 caracteres)
  - Validação de email (opcional)
  - Controle de login duplo (previne mesmo usuário em múltiplas sessões)
  - Logout automático ao desconectar

- **LoginScreen**: Tela de Login/Cadastro
  - Interface com tabs (Login / Cadastro)
  - Feedback visual de status (✅❌🔄)
  - Validação em tempo real
  - Suporte a Enter para submit
  - Auto-login após registro

- **MainWithLogin**: Gerenciador de fluxo
  - Inicia no login
  - Redireciona para multiplayer após autenticação
  - Integração completa com NetworkManager

#### Integração com Multiplayer
- Username automaticamente usado como nome no jogo
- Botão de logout no menu multiplayer
- Logout automático ao desconectar
- Informações do usuário persistidas

#### Sistema de Stats (Base implementada)
- Tracking de kills, deaths, wins, losses
- Sistema de XP e níveis
- Ranking de jogadores
- Função `add_match_stats()` pronta para uso

### 📁 Arquivos Criados
- `database/DatabaseManager.gd` - Gerenciador de banco de dados
- `database/AuthManager.gd` - Gerenciador de autenticação
- `ui/LoginScreen.gd` - Script da tela de login
- `ui/LoginScreen.tscn` - Cena da tela de login
- `scenes/MainWithLogin.gd` - Gerenciador de fluxo
- `scenes/MainWithLogin.tscn` - Cena principal com login

### 📁 Arquivos Modificados
- `project.godot` - Adicionados autoloads DatabaseManager e AuthManager
- `project.godot` - MainScene alterado para MainWithLogin.tscn
- `networking/MultiplayerMenu.gd` - Integração com sistema de auth
- `networking/MultiplayerMenu.tscn` - Adicionado label de usuário e botão de logout
- `networking/NetworkManager.gd` - Logout automático ao desconectar

### 🔐 Recursos de Segurança
- ✅ Hash de senhas (SHA256)
- ✅ Prevenção de login duplo
- ✅ Validação de dados de entrada
- ✅ Sessões rastreáveis
- ✅ Limpeza automática de sessões

### 🎮 Como Usar

1. **Primeiro Acesso:**
   - Execute o jogo
   - Clique na aba "Cadastro"
   - Preencha: Username, Email (opcional), Senha
   - Clique em "✨ CRIAR CONTA"
   - Faça login com as credenciais criadas

2. **Login:**
   - Digite seu username e senha
   - Clique em "🔐 ENTRAR"
   - Você será redirecionado para o menu multiplayer

3. **Multiplayer:**
   - Seu username aparece no topo do menu
   - Use "Host" ou "Join" normalmente
   - Use "Logout" para sair

### 📊 Estrutura de Dados

**players_database.json:**
```json
{
  "username": {
    "username": "player1",
    "password_hash": "sha256_hash",
    "email": "player1@example.com",
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

**active_sessions.json:**
```json
{
  "username": peer_id
}
```

### 🐛 Problemas Conhecidos
- [ ] SHA256 não é ideal para produção (considerar bcrypt)
- [ ] JSON não é ideal para produção (migrar para SQLite)
- [ ] Sem recuperação de senha
- [ ] Sem verificação de email

### 📋 Próximos Passos
Ver `Roadmap.md` - Phase 3.2: Persistência de Dados

