# Development Roadmap - Multiplayer Strategy Game

## Phase 1: Infrastructure & Core Movement [✅ COMPLETED]
- [x] Project organization and Cursor Rules.
- [x] Top-down camera implementation and fixed Z-axis movement.
- [x] **Multiplayer básico funcionando (Host/Join/Sincronização de movimento)**
- [x] NetworkManager com ENet
- [x] MultiplayerSpawner configurado
- [x] PlayerEntity com sincronização de posição/rotação
- [ ] Docker + SQLite setup with migrations and backups.
- [ ] Basic Class Resource system and Initial Villager class.

## Phase 2: Dynamic Class System (Hat Machines) [🔄 IN PROGRESS]
**Objetivo:** Garantir que o sistema de troca de classes funcione perfeitamente no multiplayer

### 2.1 - Testar e Corrigir Hat Machines no Multiplayer [✅ COMPLETED]
- [x] Verificar funcionamento atual das Hat Machines
- [x] Implementar sincronização de troca de classe via RPC
- [x] Garantir que todos os jogadores vejam mudança visual de classe
- [x] Testar interação com Hat Machine no multiplayer
- [x] Validar que stats são atualizados corretamente em todos os clientes
- [x] Criar recursos de classe: Warrior, Mage, Priest, Ranger, Villager
- [x] Sistema de cores por classe (visual feedback)

### 2.2 - Aprimorar Sistema de Classes [⏳ NEXT]
- [ ] Create 3D Models/Placeholders for hats (Warrior, Ranger, Mage, Priest, Worker)
- [x] Class-specific stats application (HP, Speed, Damage)
- [x] Visual update of the player model (Color coding)
- [ ] Hat attachment to player model (3D mesh)
- [ ] Sistema de cooldown para troca de classe (evitar spam)
- [ ] Adicionar mais Hat Machines na cena de teste

## Phase 3: Player Persistence & Database [📋 PLANNED]
- [ ] DatabaseManager implementation (Save/Load player data).
- [ ] Player registration logic on first connect.
- [ ] Tracking match stats (Kills, Deaths, Wins).
- [ ] Ranking UI (fetching data from SQLite).
- [ ] Docker + SQLite setup with migrations and backups.

## Phase 4: Combat & Abilities System [📋 PLANNED]
**Objetivo:** Implementar combate multiplayer com diferentes tipos de ataque por classe

### 4.1 - Sistema de Dano Base
- [ ] HealthManager sincronizado no multiplayer
- [ ] Sistema de dano entre jogadores via RPC
- [ ] Feedback visual ao receber dano (flash, shake)
- [ ] Sistema de morte e respawn

### 4.2 - Combat por Classe
- [ ] Melee combat logic (Warrior) - ataque corpo a corpo
- [ ] Ranged combat logic (Ranger/Mage) - projéteis
- [ ] Healing/Support logic (Priest) - cura em área
- [ ] Worker mechanics (Gathering wood/ore) - coleta de recursos

### 4.3 - Balanceamento
- [ ] Ajustar dano/HP/velocidade de cada classe
- [ ] Sistema de cooldown de habilidades
- [ ] Indicadores visuais de alcance de ataque

## Phase 5: Objectives & Game Loop [📋 PLANNED]
**Objetivo:** Implementar mecânicas de objetivo e vitória

### 5.1 - Sistema de Objetivos
- [ ] The "Artifact" (substituição da princesa) - objeto capturável
- [ ] Lógica de captura e transporte
- [ ] Base/Castle structures para cada time
- [ ] Sistema de pontuação e vitória

### 5.2 - Game Loop
- [ ] Match start/end logic
- [ ] Sistema de times (Red vs Blue)
- [ ] Tela de resultados com stats
- [ ] Sistema de recompensas
- [ ] Resource-based upgrades for Hat Machines

## Phase 6: Polish & Customization [📋 PLANNED]
- [ ] Skin system persistence in DB
- [ ] Map selection system
- [ ] Audio/SFX and UI juice
- [ ] Efeitos de partículas
- [ ] Camera shake
- [ ] Steam integration (Optional)

---

## 📝 Notes & Decisions
- **Multiplayer Architecture:** Usando ENet com autoridade no servidor
- **Sincronização:** MultiplayerSynchronizer com replication_mode = 1 (on_change)
- **Database:** SQLite planejado para persistência
- **Classes Iniciais:** Warrior, Ranger, Mage, Priest, Worker

