"""
Script para organizar assets do KayKit Adventurers por classe
Cria links simbólicos para evitar duplicação de arquivos
"""
import os
import shutil
from pathlib import Path

# Caminhos base
PROJECT_ROOT = Path(__file__).parent.parent
KAYKIT_PATH = PROJECT_ROOT / "assets" / "KayKit_Adventurers_2.0_EXTRA"
CLASSES_PATH = PROJECT_ROOT / "assets" / "classes"

# Mapeamento de assets por classe
ASSET_MAPPING = {
    "warrior": {
        "characters": ["Knight.glb", "knight_texture.png", "Barbarian.glb", "barbarian_texture.png"],
        "weapons": [
            "sword_1handed.gltf", "sword_1handed.bin",
            "sword_2handed.gltf", "sword_2handed.bin",
            "axe_1handed.gltf", "axe_1handed.bin",
            "axe_2handed.gltf", "axe_2handed.bin",
            "shield_round.gltf", "shield_round.bin",
            "shield_square.gltf", "shield_square.bin",
            "shield_spikes.gltf", "shield_spikes.bin",
        ],
        "animations": ["Rig_Medium", "Rig_Large"]
    },
    "ranger": {
        "characters": ["Ranger.glb", "ranger_texture.png", "Rogue.glb", "rogue_texture.png"],
        "weapons": [
            "bow.gltf", "bow.bin",
            "bow_withString.gltf", "bow_withString.bin",
            "arrow_bow.gltf", "arrow_bow.bin",
            "quiver.gltf", "quiver.bin",
            "dagger.gltf", "dagger.bin",
            "crossbow_1handed.gltf", "crossbow_1handed.bin",
        ],
        "animations": ["Rig_Medium"]
    },
    "mage": {
        "characters": ["Mage.glb", "mage_texture.png"],
        "weapons": [
            "staff.gltf", "staff.bin",
            "wand.gltf", "wand.bin",
            "spellbook_open.gltf", "spellbook_open.bin",
            "spellbook_closed.gltf", "spellbook_closed.bin",
        ],
        "props": [
            "potion_large_blue.gltf", "potion_large_blue.bin",
            "potion_large_red.gltf", "potion_large_red.bin",
            "potion_large_orange.gltf", "potion_large_orange.bin",
        ],
        "animations": ["Rig_Medium"]
    },
    "priest": {
        "characters": ["Druid.glb", "druid_texture.png"],
        "weapons": [
            "druid_staff.gltf", "druid_staff.bin",
            "staff.gltf", "staff.bin",
        ],
        "props": [
            "potion_large_green.gltf", "potion_large_green.bin",
            "potion_large_blue.gltf", "potion_large_blue.bin",
        ],
        "animations": ["Rig_Medium"]
    },
    "worker": {
        "characters": ["Engineer.glb", "engineer_texture.png"],
        "weapons": [
            "engineer_Wrench.gltf", "engineer_Wrench.bin",
            "axe_1handed.gltf", "axe_1handed.bin",
        ],
        "props": [
            "turret_base.gltf", "turret_base.bin",
            "ammo_crate.gltf", "ammo_crate.bin",
            "ammo_crate_withLid.gltf", "ammo_crate_withLid.bin",
        ],
        "animations": ["Rig_Medium"]
    }
}

def copy_file(src, dst):
    """Copia arquivo se não existir no destino"""
    dst.parent.mkdir(parents=True, exist_ok=True)
    if not dst.exists():
        shutil.copy2(src, dst)
        print(f"  + Copiado: {dst.name}")
    else:
        print(f"  - Já existe: {dst.name}")

def organize_assets():
    """Organiza todos os assets por classe"""
    print("=" * 60)
    print("ORGANIZANDO ASSETS POR CLASSE")
    print("=" * 60)
    
    if not KAYKIT_PATH.exists():
        print(f"[ERRO] Pasta KayKit nao encontrada: {KAYKIT_PATH}")
        return
    
    for class_name, categories in ASSET_MAPPING.items():
        print(f"\n[{class_name.upper()}]")
        class_path = CLASSES_PATH / class_name
        class_path.mkdir(parents=True, exist_ok=True)
        
        # Copiar personagens
        if "characters" in categories:
            print("  Characters:")
            char_dest = class_path / "characters"
            for char_file in categories["characters"]:
                src = KAYKIT_PATH / "Characters" / "gltf" / char_file
                if src.exists():
                    copy_file(src, char_dest / char_file)
        
        # Copiar armas
        if "weapons" in categories:
            print("  Weapons:")
            weapons_dest = class_path / "weapons"
            for weapon_file in categories["weapons"]:
                src = KAYKIT_PATH / "Assets" / "gltf" / weapon_file
                if src.exists():
                    copy_file(src, weapons_dest / weapon_file)
        
        # Copiar props
        if "props" in categories:
            print("  Props:")
            props_dest = class_path / "props"
            for prop_file in categories["props"]:
                src = KAYKIT_PATH / "Assets" / "gltf" / prop_file
                if src.exists():
                    copy_file(src, props_dest / prop_file)
        
        # Copiar animações
        if "animations" in categories:
            print("  Animations:")
            anims_dest = class_path / "animations"
            for rig_name in categories["animations"]:
                rig_path = KAYKIT_PATH / "Animations" / "gltf" / rig_name
                if rig_path.exists():
                    for anim_file in rig_path.glob("*.glb"):
                        copy_file(anim_file, anims_dest / anim_file.name)
    
    print("\n" + "=" * 60)
    print("[OK] ORGANIZACAO COMPLETA!")
    print("=" * 60)
    print(f"\nAssets organizados em: {CLASSES_PATH}")
    print("\nPróximos passos:")
    print("1. Abrir Godot e reimportar assets")
    print("2. Criar cenas de personagem (.tscn) para cada classe")
    print("3. Configurar AnimationTree")

if __name__ == "__main__":
    organize_assets()

