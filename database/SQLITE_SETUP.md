# 🔧 Setup SQLite para Godot

## 📥 Opção 1: Download Manual do Plugin (Recomendado)

1. **Baixe o plugin:**
   - Acesse: https://github.com/2shady4u/godot-sqlite/releases
   - Baixe a última versão para **Godot 4.x**

2. **Extraia o plugin:**
   ```
   Extraia o conteúdo para:
   C:\Users\nilto\REPO\top-down-shooter-mp\addons\godot-sqlite\
   ```

3. **Ative o plugin no Godot:**
   - Abra o projeto no Godot
   - Vá em: `Project → Project Settings → Plugins`
   - Ative **"godot-sqlite"**

## 📥 Opção 2: Asset Library (Mais Fácil)

1. **No Godot:**
   - Clique em **AssetLib** (topo da tela)
   - Pesquise por **"SQLite"**
   - Baixe **"godot-sqlite" by 2shady4u**
   - Clique em **Install**

2. **Ative o plugin:**
   - `Project → Project Settings → Plugins`
   - Ative **"godot-sqlite"**

## ✅ Verificar Instalação

Execute no console do Godot:
```gdscript
var db = SQLite.new()
print("SQLite version: ", db.get_library_version())
```

Se aparecer a versão do SQLite, está funcionando!

## 🔄 Aplicar Migrations

As migrations serão aplicadas automaticamente quando o `DatabaseManager` iniciar pela primeira vez.

## 📍 Localização do Banco

**Durante desenvolvimento:**
```
C:\Users\nilto\REPO\top-down-shooter-mp\database\db\game.db
```

**Após compilar:**
```
C:\Users\nilto\AppData\Roaming\Godot\app_userdata\Twin Shooter Starting Kit\game.db
```

## 🔗 DBeaver Connection

**Path:** `C:\Users\nilto\REPO\top-down-shooter-mp\database\db\game.db`

1. Abra DBeaver
2. Nova Conexão → SQLite
3. Cole o path acima
4. Test Connection → Finish

