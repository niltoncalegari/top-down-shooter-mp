# Sistema de Classes (Chapéus)

Este documento define as estatísticas básicas para cada classe. A troca de classe ocorre ao interagir com uma "Máquina de Chapéus" ou coletar um chapéu de um jogador derrotado.

## Atributos Base
- **Vida (HP)**
- **Velocidade de Movimento**
- **Dano**
- **Alcance**

## Classes

| Classe | HP | Velocidade | Arma Principal | Habilidade Especial (Upgrade) |
| :--- | :--- | :--- | :--- | :--- |
| **Aldeão** (Base) | 100 | Rápida | Soco (Curto) | Nenhuma |
| **Guerreiro** | 200 | Média | Espada e Escudo | Investida / Bloqueio |
| **Arqueiro** | 120 | Rápida | Arco / Mosquete | Flecha de Fogo |
| **Mago** | 100 | Média | Fogo (Área) | Gelo (Congelamento) |
| **Sacerdote** | 120 | Média | Cura (Aliado) | Dreno de Vida (Inimigo) |
| **Trabalhador** | 140 | Média | Machado (Recurso) | Bombas / Construção |

## Mecânica de Troca
1. O jogador aproxima-se de um chapéu.
2. Pressiona o botão de interação.
3. O `Player.gd` recebe um novo `Resource` de classe.
4. O modelo visual (CharacterSkin) é atualizado para exibir o chapéu correspondente.
5. As estatísticas de movimento e HP são atualizadas via RPC para todos os clientes.

