# Documento de Design de Jogo (GDD) - Nome do Projeto (A definir)

## 1. Visão Geral
Jogo de ação e estratégia multiplayer em equipe, inspirado em Fat Princess. Estilo Top-down, focado em combate de classes dinâmico e captura de objetivos.

## 2. Mecânicas Principais
- **Troca de Classes (Sistema de Chapéus)**: O jogador muda de papel ao coletar chapéus no mapa ou na base.
- **Classes Iniciais**: Guerreiro (Warrior/Knight), Arqueiro (Ranger), Mago (Mage), Sacerdote (Priest/Druid) e Trabalhador (Worker/Engineer).
- **Coleta de Recursos**: Madeira e Metal coletados pelo Trabalhador para dar upgrade nas máquinas de chapéus.
- **Objetivo**: Capturar e manter o "Artefato" (substituindo a Princesa) na base aliada.
- **Sistema de Times**: Dois times competem (Red Team vs Blue Team).
- **Cores Personalizáveis**: Líder de cada time escolhe a cor do time no lobby antes da partida (cores não podem ser iguais entre times).

## 3. Aspectos Técnicos
- **Engine**: Godot 4.5.1
- **Câmera**: Top-down (ortogonal ou perspectiva inclinada).
- **Multiplayer**: Baseado no sistema ENet nativo do Godot (com possível suporte a Steam futuramente).
- **Persistência**: SQLite para estatísticas de jogadores.

## 4. Estrutura de Dados (Player Stats)
- ID, Nome, Ranking, Vitórias, Derrotas, Kills, Deaths, Assists, Tempo de Jogo por Classe.

## 5. Sistema de Times e Cores
- **Times**: Red Team vs Blue Team (ou cores personalizadas).
- **Seleção de Cor**: Na tela de lobby, o líder de cada time seleciona a cor desejada.
- **Regra**: Times opostos não podem ter a mesma cor.
- **Aplicação Visual**: Cor do time é aplicada ao modelo do personagem quando o jogador coleta um chapéu de classe.
- **Assets Modulares**: Uso do KayKit Adventurers 2.0 para modelos de personagens por classe.

