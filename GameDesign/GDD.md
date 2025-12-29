# Documento de Design de Jogo (GDD) - Nome do Projeto (A definir)

## 1. Visão Geral
Jogo de ação e estratégia multiplayer em equipe, inspirado em Fat Princess. Estilo Top-down, focado em combate de classes dinâmico e captura de objetivos.

## 2. Mecânicas Principais
- **Troca de Classes (Sistema de Chapéus)**: O jogador muda de papel ao coletar chapéus no mapa ou na base.
- **Classes Iniciais**: Guerreiro, Arqueiro, Mago, Sacerdote e Trabalhador.
- **Coleta de Recursos**: Madeira e Metal coletados pelo Trabalhador para dar upgrade nas máquinas de chapéus.
- **Objetivo**: Capturar e manter o "Artefato" (substituindo a Princesa) na base aliada.

## 3. Aspectos Técnicos
- **Engine**: Godot 4.5.1
- **Câmera**: Top-down (ortogonal ou perspectiva inclinada).
- **Multiplayer**: Baseado no sistema ENet nativo do Godot (com possível suporte a Steam futuramente).
- **Persistência**: SQLite para estatísticas de jogadores.

## 4. Estrutura de Dados (Player Stats)
- ID, Nome, Ranking, Vitórias, Derrotas, Kills, Deaths, Assists, Tempo de Jogo por Classe.

