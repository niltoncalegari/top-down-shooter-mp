# Próximos Passos - Sistema de Classes e Combate

## ✅ Concluído

### Organização de Assets
- [x] Estrutura de pastas criada (`assets/classes/`)
- [x] Assets KayKit organizados por classe
- [x] READMEs criados para cada classe
- [x] Mapeamento completo de assets documentado

### Documentação
- [x] GDD atualizado com sistema de times e cores
- [x] Roadmap atualizado com novas tarefas
- [x] CLASS_ABILITIES.md criado com todas as habilidades
- [x] ASSETS_MAPPING.md com detalhes técnicos

## 📋 Próximas Tarefas

### 1. Integração de Modelos 3D (Prioridade Alta)
**Objetivo:** Substituir placeholders por modelos reais do KayKit

#### Passos:
1. Abrir Godot e verificar importação dos assets
2. Criar cenas base para cada classe:
   - `characters/classes/warrior.tscn`
   - `characters/classes/ranger.tscn`
   - `characters/classes/mage.tscn`
   - `characters/classes/priest.tscn`
   - `characters/classes/worker.tscn`

3. Para cada cena:
   - Adicionar modelo .glb como filho
   - Configurar CollisionShape3D
   - Adicionar AnimationPlayer
   - Configurar AnimationTree
   - Testar animações (idle, walk, run)

### 2. Sistema de Times e Cores (Prioridade Alta)
**Objetivo:** Implementar seleção de cores e times

#### Criar TeamManager.gd (Autoload)
```gdscript
extends Node

enum Team { RED, BLUE, NEUTRAL }

# Cores disponíveis
const AVAILABLE_COLORS = {
    "red": Color(0.8, 0.2, 0.2),
    "blue": Color(0.2, 0.4, 0.8),
    "orange": Color(1.0, 0.5, 0.0),
    "cyan": Color(0.2, 0.8, 0.8),
    "purple": Color(0.6, 0.2, 0.8),
    "pink": Color(1.0, 0.4, 0.6),
}

var team_colors: Dictionary = {
    Team.RED: Color(0.8, 0.2, 0.2),
    Team.BLUE: Color(0.2, 0.4, 0.8)
}

var player_teams: Dictionary = {} # peer_id -> Team

func assign_team(peer_id: int, team: Team):
    player_teams[peer_id] = team

func get_player_team(peer_id: int) -> Team:
    return player_teams.get(peer_id, Team.NEUTRAL)

func set_team_color(team: Team, color: Color):
    team_colors[team] = color

func get_team_color(team: Team) -> Color:
    return team_colors.get(team, Color.WHITE)

@rpc("authority", "call_local", "reliable")
func sync_team_colors(red_color: Color, blue_color: Color):
    team_colors[Team.RED] = red_color
    team_colors[Team.BLUE] = blue_color
```

#### Atualizar PlayerEntity.gd
- Adicionar variável `@export var team: TeamManager.Team`
- Aplicar cor do time ao material do personagem
- Sincronizar cor via RPC

### 3. Sistema de Saúde (Prioridade Alta)
**Objetivo:** HP, dano, morte e respawn

#### Criar HealthManager.gd (Component)
```gdscript
extends Node
class_name HealthManager

signal health_changed(new_health: float, max_health: float)
signal died()
signal respawned()

@export var max_health: float = 100.0
var current_health: float = max_health

func _ready():
    current_health = max_health

@rpc("any_peer", "call_local", "reliable")
func take_damage(amount: float, attacker_id: int = -1):
    if current_health <= 0:
        return
    
    current_health = max(0, current_health - amount)
    health_changed.emit(current_health, max_health)
    
    if current_health <= 0:
        die(attacker_id)

func die(killer_id: int = -1):
    died.emit()
    # Registrar kill/death
    if killer_id != -1:
        PlayerStatsManager.record_kill(killer_id)
    PlayerStatsManager.record_death(multiplayer.get_unique_id())

func heal(amount: float):
    current_health = min(max_health, current_health + amount)
    health_changed.emit(current_health, max_health)

@rpc("authority", "call_local", "reliable")
func respawn():
    current_health = max_health
    respawned.emit()
```

### 4. Sistema de Respawn
**Objetivo:** Jogador volta à vida após morte

#### Atualizar GameManager
- Detectar morte do jogador
- Aguardar 5 segundos
- Reposicionar na base do time
- Resetar classe para Villager
- Restaurar HP

### 5. Sistema de Ataque Base (Prioridade Média)

#### Melee (Warrior, Worker)
```gdscript
func _melee_attack():
    var area = Area3D.new()
    # Detectar inimigos em cone frontal
    # Aplicar dano
    # Reproduzir animação
```

#### Projéteis (Ranger, Mage, Priest)
```gdscript
# Criar cena projectile.tscn
# Script com movimento e detecção de colisão
# Spawnar via RPC
```

### 6. Lobby com Seleção de Times (Prioridade Baixa)
**Objetivo:** Tela antes da partida para escolher time e cor

#### Criar LobbyScene.tscn
- Lista de jogadores
- Botões para escolher time (Red/Blue)
- Seleção de cor (apenas líder)
- Botão "Ready"
- Botão "Start Match" (apenas host)

## 📊 Ordem de Implementação Sugerida

### Sprint 1: Modelos e Animações (1-2 dias)
1. Importar e configurar modelos 3D
2. Configurar AnimationTree
3. Testar animações básicas

### Sprint 2: Sistema de Times (1 dia)
1. Criar TeamManager
2. Aplicar cores aos personagens
3. Sincronizar no multiplayer

### Sprint 3: Combate Base (2-3 dias)
1. HealthManager
2. Sistema de dano
3. Morte e respawn
4. Feedback visual

### Sprint 4: Ataques (2-3 dias)
1. Melee para Warrior/Worker
2. Projéteis para Ranger/Mage/Priest
3. Cooldowns
4. Animações de ataque

### Sprint 5: Habilidades Secundárias (3-4 dias)
1. Dash do Warrior
2. AoE do Ranger
3. Teleporte do Mage
4. Cura do Priest
5. Coleta de recursos do Worker

### Sprint 6: Lobby e Polish (2-3 dias)
1. Tela de lobby
2. Seleção de times e cores
3. UI de HP e cooldowns
4. Efeitos visuais

## 🎯 Foco Imediato

**Começar por:**
1. ✅ Assets organizados
2. ⏭️ Importar modelos no Godot
3. ⏭️ Criar cena de personagem base
4. ⏭️ Implementar TeamManager
5. ⏭️ Implementar HealthManager

**Não implementar ainda:**
- Lobby (deixar para depois)
- Habilidades avançadas
- Sistema de recursos (Worker)
- Torres e construções

## 📚 Arquivos Criados

### Documentação
- `GameDesign/CLASS_ABILITIES.md` - Habilidades detalhadas
- `assets/classes/ASSETS_MAPPING.md` - Mapeamento técnico
- `assets/classes/*/README.md` - Info por classe

### Assets
- `assets/classes/warrior/` - Assets do Warrior
- `assets/classes/ranger/` - Assets do Ranger
- `assets/classes/mage/` - Assets do Mage
- `assets/classes/priest/` - Assets do Priest
- `assets/classes/worker/` - Assets do Worker

### Scripts
- `tools/organize_assets.py` - Script de organização

## ✅ Checklist Rápido

Antes de começar a implementar:
- [x] Assets organizados
- [x] Documentação completa
- [ ] Godot aberto e assets reimportados
- [ ] Estrutura de cenas planejada
- [ ] TeamManager criado
- [ ] HealthManager criado

