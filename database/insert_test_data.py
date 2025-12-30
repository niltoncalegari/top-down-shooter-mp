#!/usr/bin/env python3
"""Insere dados de teste no banco SQLite"""

import sqlite3
from pathlib import Path

DB_PATH = Path(__file__).parent / "db" / "game.db"

def insert_test_data():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Usuarios de teste (senha: password)
    test_users = [
        ("admin", "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8", "admin@test.com", 10, 4500, 150, 45, 20, 5),
        ("jogador1", "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8", "jogador1@test.com", 5, 2100, 80, 30, 10, 3),
        ("jogador2", "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8", "jogador2@test.com", 3, 1200, 45, 20, 5, 2),
        ("teste", "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8", "teste@test.com", 1, 0, 0, 0, 0, 0),
    ]
    
    print("Inserindo usuarios de teste...")
    for username, password_hash, email, level, xp, kills, deaths, wins, matches in test_users:
        try:
            cursor.execute("""
                INSERT INTO players (username, password_hash, email, created_at, level, xp, kills, deaths, wins, matches_played)
                VALUES (?, ?, ?, datetime('now'), ?, ?, ?, ?, ?, ?)
            """, (username, password_hash, email, level, xp, kills, deaths, wins, matches))
            print(f"[OK] {username} - Level {level} - {xp} XP")
        except sqlite3.IntegrityError:
            print(f"[SKIP] {username} (ja existe)")
    
    conn.commit()
    
    # Mostrar resultado
    cursor.execute("SELECT username, level, xp, kills, deaths FROM players ORDER BY xp DESC")
    print("\nJogadores no banco:")
    print("-" * 60)
    for username, level, xp, kills, deaths in cursor.fetchall():
        kd = f"{kills}/{deaths}" if deaths > 0 else f"{kills}/0"
        print(f"{username:15} Level {level:2}  |  {xp:5} XP  |  K/D: {kd}")
    print("-" * 60)
    print(f"\nTotal: {len(cursor.fetchall()) + len(test_users)} jogadores")
    
    conn.close()
    print("\n[OK] Dados inseridos!")
    print("\nLogin de teste:")
    print("  Usuario: admin")
    print("  Senha: password")

if __name__ == "__main__":
    insert_test_data()

