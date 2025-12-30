# Mapeamento de Assets por Classe

## Estrutura de Pastas
```
assets/classes/
├── warrior/    # Knight/Barbarian
├── ranger/     # Ranger/Rogue
├── mage/       # Mage
├── priest/     # Druid
└── worker/     # Engineer
```

## Mapeamento de Modelos e Assets

### 🗡️ Warrior (Guerreiro)
**Modelos Base:**
- `Knight.glb` - Modelo principal
- `Barbarian.glb` ou `Barbarian_Large.glb` - Variação alternativa

**Armas e Equipamentos:**
- `sword_1handed.gltf` - Espada de uma mão
- `sword_2handed.gltf` - Espada de duas mãos
- `axe_1handed.gltf` - Machado de uma mão
- `axe_2handed.gltf` - Machado de duas mãos
- `shield_round.gltf` - Escudo redondo
- `shield_square.gltf` - Escudo quadrado
- `shield_spikes.gltf` - Escudo com espinhos

**Texturas:**
- `knight_texture.png`
- `barbarian_texture.png`

**Animações:**
- Rig_Medium (para Knight)
- Rig_Large (para Barbarian)

---

### 🏹 Ranger (Arqueiro)
**Modelos Base:**
- `Ranger.glb` - Modelo principal
- `Rogue.glb` ou `Rogue_Hooded.glb` - Variação stealth

**Armas e Equipamentos:**
- `bow.gltf` ou `bow_withString.gltf` - Arco
- `crossbow_1handed.gltf` - Besta de uma mão
- `crossbow_2handed.gltf` - Besta de duas mãos
- `arrow_bow.gltf` - Flechas para arco
- `arrow_crossbow.gltf` - Virotes para besta
- `quiver.gltf` - Aljava
- `dagger.gltf` - Adaga (arma secundária)

**Texturas:**
- `ranger_texture.png`
- `rogue_texture.png`

**Animações:**
- Rig_Medium

---

### 🔮 Mage (Mago)
**Modelos Base:**
- `Mage.glb` - Modelo principal

**Armas e Equipamentos:**
- `staff.gltf` - Cajado
- `wand.gltf` - Varinha
- `spellbook_open.gltf` - Grimório aberto
- `spellbook_closed.gltf` - Grimório fechado
- Poções (vários tamanhos e cores para VFX):
  - `potion_*_blue.gltf` - Poções de mana
  - `potion_*_red.gltf` - Poções de vida
  - `potion_*_green.gltf` - Poções de veneno
  - `potion_*_orange.gltf` - Poções de fogo

**Texturas:**
- `mage_texture.png`

**Animações:**
- Rig_Medium

---

### ✨ Priest (Sacerdote/Druida)
**Modelos Base:**
- `Druid.glb` - Modelo principal

**Armas e Equipamentos:**
- `druid_staff.gltf` - Cajado druida
- `staff.gltf` - Cajado alternativo
- Poções de cura:
  - `potion_*_green.gltf` - Cura/natureza
  - `potion_*_blue.gltf` - Mana/proteção

**Texturas:**
- `druid_texture.png`

**Animações:**
- Rig_Medium

---

### 🔧 Worker (Trabalhador/Engenheiro)
**Modelos Base:**
- `Engineer.glb` - Modelo principal

**Armas e Equipamentos:**
- `engineer_Wrench.gltf` - Chave inglesa
- `axe_1handed.gltf` - Machado para coletar madeira
- `turret_base.gltf` - Base de torre (construção)
- `ammo_crate.gltf` - Caixa de munição
- `ammo_crate_withLid.gltf` - Caixa fechada

**Texturas:**
- `engineer_texture.png`

**Animações:**
- Rig_Medium

---

## Animações Disponíveis

### Rig_Medium (Knight, Ranger, Mage, Druid, Engineer)
**MovementBasic:**
- Idle
- Walk
- Run

**General:**
- Attack
- Death
- Hit/Damage
- Jump (se aplicável)

### Rig_Large (Barbarian)
**MovementBasic:**
- Idle
- Walk
- Run

**General:**
- Attack (heavy)
- Death
- Hit/Damage

---

## Sistema de Cores por Time

### Aplicação de Cores
Cada personagem receberá a cor do seu time aplicada ao material base:
- **Método**: `set_surface_override_material()` com `StandardMaterial3D`
- **Propriedade**: `albedo_color`

### Paleta de Cores Sugeridas
**Time 1 (Padrão Red):**
- Vermelho: `Color(0.8, 0.2, 0.2)`
- Laranja: `Color(1.0, 0.5, 0.0)`
- Rosa: `Color(1.0, 0.4, 0.6)`

**Time 2 (Padrão Blue):**
- Azul: `Color(0.2, 0.4, 0.8)`
- Ciano: `Color(0.2, 0.8, 0.8)`
- Roxo: `Color(0.6, 0.2, 0.8)`

**Cores Neutras (Não permitidas):**
- Branco
- Cinza
- Preto

### Regras de Seleção
1. Líder do Time 1 escolhe primeiro
2. Líder do Time 2 escolhe (não pode ser igual ao Time 1)
3. Cores devem ter contraste suficiente para identificação
4. Cor é aplicada quando jogador pega um chapéu de classe

---

## Próximos Passos

### Fase 1: Organização
- [x] Criar estrutura de pastas por classe
- [ ] Copiar/linkar assets relevantes para cada pasta
- [ ] Criar README em cada pasta com lista de assets

### Fase 2: Integração
- [ ] Importar modelos .glb no Godot
- [ ] Configurar AnimationTree para cada classe
- [ ] Criar cenas de personagem por classe (warrior.tscn, ranger.tscn, etc.)
- [ ] Aplicar texturas corretas

### Fase 3: Sistema de Times
- [ ] Criar TeamManager (autoload)
- [ ] Implementar seleção de cor no lobby
- [ ] Aplicar cor do time ao material do personagem
- [ ] Sincronizar cores no multiplayer

### Fase 4: Habilidades
- [ ] Definir habilidades por classe
- [ ] Implementar sistema de ataque base
- [ ] Criar projéteis (Ranger/Mage)
- [ ] Implementar cura em área (Priest)
- [ ] Sistema de coleta de recursos (Worker)

