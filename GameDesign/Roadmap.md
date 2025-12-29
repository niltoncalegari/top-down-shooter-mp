# Development Roadmap - Multiplayer Strategy Game

## Phase 1: Infrastructure & Core Movement [COMPLETED]
- [x] Project organization and Cursor Rules.
- [x] Top-down camera implementation and fixed Z-axis movement.
- [ ] Docker + SQLite setup with migrations and backups.
- [ ] Basic Class Resource system and Initial Villager class.

## Phase 2: Player Persistence & Stats [IN PROGRESS]
- [ ] DatabaseManager implementation (Save/Load player data).
- [ ] Player registration logic on first connect.
- [ ] Tracking match stats (Kills, Deaths, Wins).
- [ ] Ranking UI (fetching data from SQLite).

## Phase 3: Dynamic Class System (The Hats) [IN PROGRESS]
- [ ] Create 3D Models/Placeholders for hats (Warrior, Ranger, Mage, Priest, Worker).
- [ ] Implement "Hat Machine" (Interacting to change class).
- [ ] Class-specific stats application (HP, Speed, Damage).
- [ ] Visual update of the player model (Hat attachment).

## Phase 4: Combat & Abilities
- [ ] Melee combat logic (Warrior).
- [ ] Ranged combat logic (Ranger/Mage).
- [ ] Healing/Support logic (Priest).
- [ ] Worker mechanics (Gathering wood/ore).

## Phase 5: Objectives & Game Loop
- [ ] The "Artifact" (The Princess replacement) - Capture and Carry.
- [ ] Base/Castle structures and defenses.
- [ ] Resource-based upgrades for Hat Machines.
- [ ] Match start/end logic and rewards.

## Phase 6: Polish & Customization
- [ ] Skin system persistence in DB.
- [ ] Map selection system.
- [ ] Audio/SFX and UI juice.
- [ ] Steam integration (Optional).

