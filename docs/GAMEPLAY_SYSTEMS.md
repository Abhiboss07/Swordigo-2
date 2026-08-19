# GAMEPLAY SYSTEMS ARCHITECTURE

**Project:** Swordigo V2 / Ironvale  
**Target:** Godot 4.4 (CharacterBody3D, 2.5D Configuration)

---

## 1. Character & Controller Systems

### 1.1 Player Physics & State Machine
The player controller is implemented as a `CharacterBody3D` with velocity constrained strictly to the X and Y axes (`velocity.z = 0`).

```
                ┌──────────────┐
                │     IDLE     │◄─────────┐
                └──────┬───────┘          │
                   ▲   │                  │
         Input Move│   │No Input          │
                   │   ▼                  │
                ┌──────────────┐          │
                │     RUN      │          │
                └──────┬───────┘          │
                   ▲   │                  │
         On Ground │   │Jump / Fall       │
                   │   ▼                  │
                ┌──────────────┐          │
     ┌─────────►│     AIR      │          │
     │          └──────┬───────┘          │
     │                 │                  │
Jump 2 (Mid-air)       │Wall Contact      │
     │                 ▼                  │
     │          ┌──────────────┐          │
     └──────────┤  WALL SLIDE  │          │
                └──────────────┘          │
                       ▲                  │
                       │                  │
              Damage   │Attack Complete   │
                       │                  │
┌──────────────┐◄──────┴───────►┌─────────┴────┐
│     HURT     │   Any State    │    ATTACK    │
└──────┬───────┘                └──────────────┘
       │
Health <= 0
       ▼
┌──────────────┐
│     DEAD     │
└──────────────┘
```

#### State Definitions & Transitions:
1. **IDLE:** Velocity approaches zero. Listens for horizontal movement, jump, attack, or spell casts.
2. **RUN:** Accelerates towards `target_direction * max_speed`. Plays running animation with footstep audio triggers.
3. **AIR (Jump / Fall):** Applies gravity. Handles variable jump dampening on release, coyote timer expiration, and double jump triggers.
4. **WALL SLIDE:** Engaged when airborne, pushing into a wall, and moving downward. Clamps downward velocity to `wall_slide_speed`. Allows wall jumping.
5. **ATTACK:** Disables movement overrides; enables active weapon `Hitbox3D`; executes combo chaining window (combo stage 1 -> 2 -> 3).
6. **CAST:** Instantiates selected spell projectile/ability, consumes mana, applies brief cast recovery.
7. **HURT:** Applies knockback impulse; triggers invulnerability flashing; blocks input for `hurt_duration` (0.25s).
8. **DEAD:** Freezes inputs; plays death animation; triggers death screen and respawn sequence.

---

## 2. Combat, Hit Detection, and Damage Model

### 2.1 Area3D Hitbox / Hurtbox Paradigm
Combat interactions utilize decoupled `Area3D` nodes on dedicated collision layers:
- **Layer 3 (PlayerHurtbox):** Receives enemy attacks.
- **Layer 4 (EnemyHurtbox):** Receives player weapon/spell attacks.
- **Layer 5 (PlayerHitbox):** Weapon swings, player projectiles.
- **Layer 6 (EnemyHitbox):** Enemy claws, bites, hazard colliders, enemy projectiles.

### 2.2 Damage Calculation
```
Damage Received = max(1, (Attacker.BaseAttack + Attacker.WeaponAttack) * AttackMultiplier - Target.Defense)
```
- **Critical Strike Chance:** Checked on hit (base 5% + equipment bonuses). Deals `1.5x` critical damage.
- **Damage Numbers:** Floating 3D label spawned at hit coordinate, color-coded:
  - White: Normal physical damage.
  - Red / Orange: Critical strike.
  - Cyan / Blue: Magical damage.
  - Green: Health recovery.

### 2.3 Knockback & Poise
Every attack carries a `knockback_vector: Vector2` and `poise_damage: float`.
- Light enemies are interrupted immediately and propelled backward.
- Heavy enemies and bosses have a poise threshold; poise regenerates after 2.0s without damage. Breaking poise triggers a brief stagger state (1.5s).

---

## 3. Magic & Ability Framework

### 3.1 Mana Economy
- Max Mana: Scales with player level and equipment (Base: 50, +10 per Magic level).
- Mana Regeneration: 2.0 mana per second passive regeneration; +5 mana restored per slain enemy or soul crystal collected.

### 3.2 Implemented Spells
1. **Magic Bolt:**
   - Mana Cost: 12
   - Cast: Fires a high-velocity projectile forward (`velocity = Vector3(dir * 18, 0, 0)`).
   - Effect: Deals `15 + 1.2 * MagicPower` damage. Pierces destructible pots and activates distance crystal switches.
2. **Nova Burst (AoE Shockwave):**
   - Mana Cost: 25
   - Cast: Player slams ground, emitting a radial energy ring (`radius = 4.5m`).
   - Effect: Deals `30 + 1.8 * MagicPower` damage, breaks enemy shields, destroys surrounding incoming projectiles, and knocks back all nearby entities.
3. **Phase Dash:**
   - Mana Cost: 15
   - Cast: Instantly dashes 6 meters horizontally, passing through enemies and hazards without taking damage.

---

## 4. Enemy AI & Boss State Machines

### 4.1 Archetypes
1. **Ground Patroller (e.g. Goblin / Skeleton):**
   - States: `Patrol` (walks back and forth on ledge, turns at edge/wall) -> `Detect` (aggro radius 7m) -> `Chase` -> `MeleeAttack` (windup 0.3s, active 0.2s, cooldown 1.0s).
2. **Flying Stalker (e.g. Shadow Bat / Wraith):**
   - States: `Hover` (idle float with sine-wave bob) -> `Swoop` (dives down in an elliptical curve toward player) -> `Retreat` (flies upward after hit or miss).
3. **Charger (e.g. Armored Boar / Golem):**
   - States: `Idle` -> `Windup` (scrapes ground, flashes red for 0.6s) -> `Charge` (rushes at 14 m/s in straight line until colliding with wall) -> `Stunned` (dazed for 1.5s if hitting a wall).
4. **Ranged Caster:**
   - States: `Flee` (maintains minimum 5m distance from player) -> `Aim` -> `CastHomingBolt`.

### 4.2 Multi-Phase Boss Architecture
Bosses inherit from `BossBase3D` providing:
- Boss Health Bar UI integration.
- Intro cinematic roar / arena lock (doors slide shut).
- Health thresholds (`100% -> 66% -> 33% -> 0%`) triggering phase shifts, arena hazard activations, and attack pattern shifts.
- Defeat sequence: Slow-motion camera zoom, death particle burst, arena unlocks, and loot chest spawn.

---

## 5. Inventory, Equipment, & Persistence

### 5.1 Item Categories
- **Weapons:** Modifies Attack stat, attack speed, and swing visual (Sword, Greatsword, Daggers, Spear).
- **Armor:** Modifies Defense and Max Health (Light Tunic, Chainmail, Plate Armor).
- **Baubles (3 Slots):**
  - Slot 1 (Amulet): Major passive trait (e.g., Tidefoot Amulet: No fall damage / Water breathing).
  - Slot 2 (Ring 1): Stat amplifier (e.g., Ember Ring: +15% Fire damage on hit).
  - Slot 3 (Ring 2): Utility amplifier (e.g., Chrono Ring: -20% Spell cooldowns).
  - Slot 4 (Trinket): Special effect (e.g., Magnet Stone: Collect coins from 8m away).

### 5.2 Save & Load Architecture
Save data is serialized to JSON (`user://saves/save_slot_{N}.json`) containing:
```json
{
  "profile_name": "Hero",
  "playtime_seconds": 1240,
  "level": 5,
  "stats": {"max_health": 120, "max_mana": 70, "attack": 18, "defense": 6, "magic": 14},
  "coins": 350,
  "current_zone": "res://scenes/world/zone_01_valley.tscn",
  "spawn_point_name": "checkpoint_ancient_gate",
  "equipment": {
    "weapon": "iron_broadsword",
    "armor": "leather_brigandine",
    "amulet": "tidefoot_amulet",
    "ring_1": "ember_ring",
    "ring_2": null,
    "trinket": "magnet_stone"
  },
  "inventory": ["healing_potion", "mana_elixir", "old_dungeon_key"],
  "quest_flags": {"met_village_elder": true, "crypt_gate_unlocked": true},
  "opened_chests": ["chest_valley_01", "chest_valley_secret_02"],
  "defeated_bosses": ["the_wickframe"]
}
```
Auto-save triggers whenever the player touches a Checkpoint or enters a new zone.
