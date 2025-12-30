# Habilidades por Classe

## 🗡️ Warrior (Guerreiro)

### Stats Base
- **HP**: 150
- **Velocidade**: 5.0
- **Dano Base**: 25

### Habilidades

#### 1. Ataque Corpo a Corpo (Primário)
- **Tipo**: Melee
- **Alcance**: 2.5 unidades
- **Cooldown**: 0.8s
- **Dano**: 25
- **Descrição**: Ataque rápido com espada/machado em cone frontal

#### 2. Investida (Secundário)
- **Tipo**: Dash + Dano
- **Alcance**: 8 unidades
- **Cooldown**: 5s
- **Dano**: 15
- **Descrição**: Avança rapidamente causando dano ao primeiro inimigo atingido

#### 3. Bloqueio (Defensivo)
- **Tipo**: Buff defensivo
- **Duração**: 2s
- **Cooldown**: 8s
- **Efeito**: Reduz 50% do dano recebido enquanto ativo

---

## 🏹 Ranger (Arqueiro)

### Stats Base
- **HP**: 100
- **Velocidade**: 6.0
- **Dano Base**: 20

### Habilidades

#### 1. Disparo de Flecha (Primário)
- **Tipo**: Projétil
- **Alcance**: 20 unidades
- **Cooldown**: 1.0s
- **Dano**: 20
- **Velocidade Projétil**: 30 unidades/s
- **Descrição**: Dispara uma flecha em linha reta

#### 2. Chuva de Flechas (Secundário)
- **Tipo**: AoE
- **Alcance**: 15 unidades
- **Raio**: 5 unidades
- **Cooldown**: 10s
- **Dano**: 10 (por tick, 3 ticks)
- **Descrição**: Dispara flechas que caem em área marcada

#### 3. Armadilha (Utilitário)
- **Tipo**: Trap
- **Duração**: 30s
- **Cooldown**: 15s
- **Dano**: 30
- **Efeito**: Imobiliza inimigo por 2s
- **Descrição**: Coloca armadilha invisível no chão

---

## 🔮 Mage (Mago)

### Stats Base
- **HP**: 80
- **Velocidade**: 5.5
- **Dano Base**: 30

### Habilidades

#### 1. Bola de Fogo (Primário)
- **Tipo**: Projétil explosivo
- **Alcance**: 18 unidades
- **Cooldown**: 1.5s
- **Dano**: 30 (direto) + 10 (splash)
- **Raio Splash**: 2 unidades
- **Velocidade Projétil**: 25 unidades/s
- **Descrição**: Lança bola de fogo que explode ao impacto

#### 2. Teleporte (Mobilidade)
- **Tipo**: Blink
- **Alcance**: 10 unidades
- **Cooldown**: 8s
- **Descrição**: Teleporta instantaneamente para local visado

#### 3. Escudo Arcano (Defensivo)
- **Tipo**: Escudo
- **Duração**: 3s
- **Cooldown**: 12s
- **Absorção**: 50 HP
- **Descrição**: Cria escudo que absorve dano

---

## ✨ Priest (Sacerdote/Druida)

### Stats Base
- **HP**: 110
- **Velocidade**: 5.0
- **Dano Base**: 15

### Habilidades

#### 1. Raio Sagrado (Primário)
- **Tipo**: Projétil
- **Alcance**: 15 unidades
- **Cooldown**: 1.2s
- **Dano**: 15
- **Velocidade Projétil**: 20 unidades/s
- **Descrição**: Dispara raio de luz que causa dano

#### 2. Cura em Área (Suporte)
- **Tipo**: AoE Heal
- **Alcance**: 12 unidades
- **Raio**: 6 unidades
- **Cooldown**: 8s
- **Cura**: 40 HP
- **Descrição**: Cura todos os aliados na área (incluindo si mesmo)

#### 3. Bênção (Buff)
- **Tipo**: Buff de equipe
- **Duração**: 5s
- **Cooldown**: 15s
- **Efeito**: +20% velocidade de movimento para aliados próximos
- **Raio**: 8 unidades
- **Descrição**: Aumenta velocidade de aliados próximos

---

## 🔧 Worker (Trabalhador/Engenheiro)

### Stats Base
- **HP**: 120
- **Velocidade**: 5.5
- **Dano Base**: 10

### Habilidades

#### 1. Golpe de Chave (Primário)
- **Tipo**: Melee
- **Alcance**: 2.0 unidades
- **Cooldown**: 1.0s
- **Dano**: 10 (jogadores) / 20 (recursos)
- **Descrição**: Ataque corpo a corpo com chave inglesa

#### 2. Coletar Recursos (Utilitário)
- **Tipo**: Coleta
- **Alcance**: 2.5 unidades
- **Tempo**: 3s (madeira) / 5s (metal)
- **Recursos**: +10 madeira ou +5 metal
- **Descrição**: Coleta recursos de árvores ou pedras

#### 3. Construir Torre (Construção)
- **Tipo**: Estrutura
- **Custo**: 20 madeira + 10 metal
- **Cooldown**: 30s
- **HP Torre**: 100
- **Dano Torre**: 15/s
- **Alcance Torre**: 12 unidades
- **Descrição**: Constrói torre defensiva que ataca inimigos

---

## Sistema de Combate

### Mecânicas Gerais

#### Dano e Morte
- Quando HP chega a 0, jogador morre
- Respawn após 5 segundos na base do time
- Jogador que matou recebe +100 XP
- Jogador morto perde classe atual (volta para Villager)

#### Projéteis
- Viajam em linha reta
- Colidem com terreno e jogadores
- Podem ser bloqueados por obstáculos
- Sincronizados via RPC

#### Área de Efeito (AoE)
- Indicador visual no chão antes de ativar
- Afeta todos dentro do raio
- Diferencia aliados e inimigos
- Sincronizado via RPC

#### Cooldowns
- Exibidos na UI do jogador
- Sincronizados localmente (não precisa RPC)
- Bloqueiam uso da habilidade até terminar

---

## Balanceamento

### Princípios
1. **Warrior**: Tank corpo a corpo, alto HP, baixa mobilidade
2. **Ranger**: DPS à distância, médio HP, alta mobilidade
3. **Mage**: Burst damage, baixo HP, habilidades de escape
4. **Priest**: Suporte, médio HP, cura e buffs
5. **Worker**: Utilidade, coleta recursos, constrói defesas

### Counters
- **Warrior** > **Ranger** (fecha distância rapidamente)
- **Ranger** > **Mage** (ataque constante vs burst)
- **Mage** > **Warrior** (kite com teleporte)
- **Priest** sustenta qualquer composição
- **Worker** é vulnerável mas essencial para vitória

---

## Implementação Técnica

### Prioridade de Desenvolvimento

#### Fase 1: Sistema Base
1. HealthManager (HP, dano, morte)
2. Respawn system
3. Feedback visual (flash ao tomar dano)

#### Fase 2: Ataques Básicos
1. Melee detection (Warrior, Worker)
2. Projéteis básicos (Ranger, Mage, Priest)
3. Cooldown system

#### Fase 3: Habilidades Secundárias
1. Dash do Warrior
2. AoE do Ranger
3. Teleporte do Mage
4. Cura do Priest
5. Coleta de recursos do Worker

#### Fase 4: Habilidades Avançadas
1. Bloqueio do Warrior
2. Armadilha do Ranger
3. Escudo do Mage
4. Buff do Priest
5. Torre do Worker

---

## Sincronização Multiplayer

### O Que Sincronizar via RPC

#### Obrigatório
- Uso de habilidade (animação)
- Criação de projéteis
- Aplicação de dano
- Morte e respawn
- Construção de estruturas

#### Opcional (pode ser local)
- Cooldowns
- Indicadores visuais
- Efeitos de partículas
- Sons

### Exemplo de Estrutura
```gdscript
@rpc("any_peer", "call_local", "reliable")
func use_ability_primary():
    if not can_use_ability("primary"):
        return
    
    start_cooldown("primary")
    play_animation("attack")
    
    match current_class:
        "warrior":
            _melee_attack()
        "ranger":
            _shoot_arrow()
        "mage":
            _cast_fireball()
        "priest":
            _cast_holy_ray()
        "worker":
            _wrench_attack()
```

