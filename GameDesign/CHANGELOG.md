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
Ver `Roadmap.md` - Phase 2.2: Aprimorar Sistema de Classes

