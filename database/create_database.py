#!/usr/bin/env python3
"""
Script para criar o banco de dados SQLite e aplicar migrations
Uso: python database/create_database.py
"""

import sqlite3
import os
from pathlib import Path

# Caminhos
BASE_DIR = Path(__file__).parent
DB_PATH = BASE_DIR / "db" / "game.db"
MIGRATION_FILE = BASE_DIR / "migrations" / "001_initial_schema.sql"

def create_database():
    """Cria o banco de dados e aplica a migration inicial"""
    print("="*60)
    print("CRIANDO BANCO DE DADOS SQLite")
    print("="*60)
    
    # Criar diretorio se nao existir
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    
    # Verificar se ja existe
    if DB_PATH.exists():
        print(f"\n[AVISO] Banco ja existe: {DB_PATH}")
        response = input("Deseja recriar? (s/N): ").lower()
        if response != 's':
            print("[INFO] Operacao cancelada")
            return False
        
        # Fazer backup
        backup_path = DB_PATH.with_suffix('.db.backup')
        import shutil
        shutil.copy(DB_PATH, backup_path)
        print(f"[OK] Backup criado: {backup_path}")
        
        # Deletar banco existente
        DB_PATH.unlink()
        print("[OK] Banco antigo removido")
    
    # Conectar ao banco (cria automaticamente)
    print(f"\n[1/3] Criando banco de dados...")
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    print(f"[OK] Banco criado: {DB_PATH}")
    
    # Ler e aplicar migration
    print(f"\n[2/3] Aplicando migration inicial...")
    if not MIGRATION_FILE.exists():
        print(f"[ERRO] Migration nao encontrada: {MIGRATION_FILE}")
        return False
    
    with open(MIGRATION_FILE, 'r', encoding='utf-8') as f:
        migration_sql = f.read()
    
    # Executar comandos SQL
    try:
        cursor.executescript(migration_sql)
        conn.commit()
        print("[OK] Migration aplicada com sucesso!")
    except sqlite3.Error as e:
        print(f"[ERRO] Falha ao aplicar migration: {e}")
        return False
    
    # Verificar estrutura
    print(f"\n[3/3] Verificando estrutura...")
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")
    tables = cursor.fetchall()
    
    print(f"\n[OK] Tabelas criadas ({len(tables)}):")
    for table in tables:
        print(f"  - {table[0]}")
        
        # Contar colunas
        cursor.execute(f"PRAGMA table_info({table[0]})")
        columns = cursor.fetchall()
        print(f"    ({len(columns)} colunas)")
    
    # Verificar views
    cursor.execute("SELECT name FROM sqlite_master WHERE type='view' ORDER BY name")
    views = cursor.fetchall()
    
    if views:
        print(f"\n[OK] Views criadas ({len(views)}):")
        for view in views:
            print(f"  - {view[0]}")
    
    # Verificar indices
    cursor.execute("SELECT name FROM sqlite_master WHERE type='index' ORDER BY name")
    indices = cursor.fetchall()
    
    if indices:
        print(f"\n[OK] Indices criados ({len(indices)}):")
        for index in indices:
            if not index[0].startswith('sqlite_'):
                print(f"  - {index[0]}")
    
    conn.close()
    
    # Informacoes finais
    print("\n" + "="*60)
    print("BANCO CRIADO COM SUCESSO!")
    print("="*60)
    print(f"\nCaminho do banco:")
    print(f"  {DB_PATH.absolute()}")
    print(f"\nTamanho: {DB_PATH.stat().st_size} bytes")
    print(f"\n[DBeaver] Use este caminho para conectar:")
    print(f"  {DB_PATH.absolute()}")
    print("\n" + "="*60)
    
    return True

def insert_test_data():
    """Insere dados de teste (opcional)"""
    print("\n[OPCIONAL] Deseja inserir dados de teste? (s/N): ", end='')
    response = input().lower()
    
    if response != 's':
        return
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Usuario de teste
    test_users = [
        ("admin", "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8", "admin@test.com"),  # senha: password
        ("jogador1", "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8", "jogador1@test.com"),
        ("jogador2", "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8", "jogador2@test.com"),
    ]
    
    print("\n[TEST] Inserindo usuarios de teste...")
    for username, password_hash, email in test_users:
        try:
            cursor.execute("""
                INSERT INTO players (username, password_hash, email, created_at, level, xp, kills, deaths)
                VALUES (?, ?, ?, datetime('now'), ?, ?, ?, ?)
            """, (username, password_hash, email, 1, 0, 0, 0))
            print(f"[OK] Usuario criado: {username} (senha: password)")
        except sqlite3.IntegrityError:
            print(f"[SKIP] Usuario ja existe: {username}")
    
    conn.commit()
    conn.close()
    
    print("[OK] Dados de teste inseridos!")

def show_stats():
    """Mostra estatisticas do banco"""
    if not DB_PATH.exists():
        print("[ERRO] Banco nao existe!")
        return
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    print("\n" + "="*60)
    print("ESTATISTICAS DO BANCO")
    print("="*60)
    
    # Contar jogadores
    cursor.execute("SELECT COUNT(*) FROM players")
    players_count = cursor.fetchone()[0]
    print(f"\nJogadores: {players_count}")
    
    # Contar sessoes
    cursor.execute("SELECT COUNT(*) FROM active_sessions")
    sessions_count = cursor.fetchone()[0]
    print(f"Sessoes ativas: {sessions_count}")
    
    # Contar partidas
    cursor.execute("SELECT COUNT(*) FROM match_history")
    matches_count = cursor.fetchone()[0]
    print(f"Partidas registradas: {matches_count}")
    
    if players_count > 0:
        print("\nTop 5 jogadores:")
        cursor.execute("SELECT username, level, xp FROM players ORDER BY xp DESC LIMIT 5")
        for i, (username, level, xp) in enumerate(cursor.fetchall(), 1):
            print(f"  {i}. {username} - Level {level} - {xp} XP")
    
    conn.close()
    print("="*60)

if __name__ == "__main__":
    try:
        if create_database():
            insert_test_data()
            show_stats()
            print("\n[SUCCESS] Pronto para usar!")
            print("\nProximos passos:")
            print("1. Abra o DBeaver")
            print("2. Nova Conexao > SQLite")
            print(f"3. Path: {DB_PATH.absolute()}")
            print("4. Test Connection > Finish")
    except Exception as e:
        print(f"\n[ERRO] {e}")
        import traceback
        traceback.print_exc()

