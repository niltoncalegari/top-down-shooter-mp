# Sistema de Debug Logs para Multiplayer

## Como Usar

1. **Execute o jogo normalmente** (Host ou Client)
2. O arquivo de log será criado automaticamente em:

### Windows:
```
%APPDATA%\Godot\app_userdata\top-down-shooter-mp\multiplayer_debug.log
```

Caminho completo típico:
```
C:\Users\[SEU_USUARIO]\AppData\Roaming\Godot\app_userdata\top-down-shooter-mp\multiplayer_debug.log
```

### Linux:
```
~/.local/share/godot/app_userdata/top-down-shooter-mp/multiplayer_debug.log
```

### macOS:
```
~/Library/Application Support/Godot/app_userdata/top-down-shooter-mp/multiplayer_debug.log
```

## Como Acessar

### Opção 1: Pelo Explorer/Finder
1. Pressione `Win + R` (Windows) ou `Cmd + Shift + G` (Mac)
2. Cole o caminho acima
3. Abra o arquivo `multiplayer_debug.log` com qualquer editor de texto

### Opção 2: Pelo console do Godot
Quando o jogo iniciar, você verá uma mensagem no console:
```
📝 Log sendo salvo em: [CAMINHO_COMPLETO]
```
Copie esse caminho e abra o arquivo.

## O que está sendo logado

- ✅ Inicialização do GameManager
- ✅ Conexões e desconexões de players
- ✅ Spawn de players (posições, autoridades)
- ✅ Criação de instâncias via RPC
- ✅ Configuração de MultiplayerSynchronizer
- ✅ Estado da árvore de nós após cada operação
- ✅ Informações de autoridade de rede

## Como Analisar

1. Abra **dois arquivos de log** (um do Host, outro do Client)
2. Compare os timestamps para ver a sequência de eventos
3. Procure por mensagens de **AVISO** ou **ERRO**
4. Verifique se os IDs e autoridades estão corretos
5. Confirme se o número de players na árvore está correto

## Exemplo de Log Saudável

```
================================================================================
MULTIPLAYER DEBUG LOG - 2025-12-29 12:34:56
================================================================================
Arquivo de log: C:\Users\...\multiplayer_debug.log
Sistema inicializado

================================================================================
GAMEMANAGER INICIALIZADO
================================================================================
Peer ID: 1
Is Server: true

================================================================================
PLAYER CONNECTED - ID: 1
================================================================================
Player Info: {...}
Is server: true
Local peer ID: 1
Total players in NetworkManager: 1

--- Players existentes na árvore ANTES do spawn ---
  (Nenhum player na árvore ainda)

>>> SERVIDOR: Spawnando novo jogador: 1

--- _spawn_player chamado ---
  ID do player: 1
  Índice de spawn atual: 0
  Procurando por: SpawnPoint1
  ✓ SpawnPoint1 encontrado! Posição: (x, y, z)
  Chamando _create_player.rpc(1, (x, y, z))

--- _create_player chamado via RPC ---
  ID do player: 1
  Posição: (x, y, z)
  ...
  ✓ Player adicionado à árvore!
  >>> Este é o PLAYER LOCAL
```

## Troubleshooting

Se o arquivo não for criado:
1. Verifique se tem permissão de escrita na pasta `AppData`
2. Execute o Godot como administrador
3. Verifique o console do Godot por erros

Se o log parar de atualizar:
- O arquivo é fechado quando o jogo encerra
- Use `DebugLogger.log_file.flush()` para forçar escrita imediata

