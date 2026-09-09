extends Node

# =========================================================
# DARKHIDE - GameState (Autoload Singleton)
# Holds the player's persistent state for the current vessel.
# =========================================================

var player_name: String = "Adventurer"
var profession: String = "Warrior"  # "Warrior", "Archer", "Sorcerer"

var level: int = 1
var xp: int = 0
var xp_to_next: int = 150

var max_hp: int = 50
var hp: int = 50
var max_mp: int = 20
var mp: int = 20

var strength: int = 5
var defence: int = 5
var magic: int = 5
var crit: int = 5

var gold: int = 100

var inventory: Array = []   # e.g. ["Healing Potion", "Magic Flask"]
var skills: Array = []      # e.g. ["Battle Focus", "Slaughter"]

var weapon: String = "Rusty Sword"
var weapon_base_damage: int = 8

var current_wave: int = 0
var total_waves: int = 10

var vessel_name: String = "Polimichanous"
var tutorial_dungeon_cleared: bool = false
var first_boss_defeated: bool = false


func reset_game(chosen_profession: String = "Warrior") -> void:
	profession = chosen_profession
	level = 1
	xp = 0
	xp_to_next = 150
	gold = 100
	inventory = ["Healing Potion", "Healing Potion"]
	skills = []
	current_wave = 0
	vessel_name = "Polimichanous"
	tutorial_dungeon_cleared = false
	first_boss_defeated = false
	_apply_profession_defaults()


func _apply_profession_defaults() -> void:
	match profession:
		"Warrior":
			max_hp = 60
			max_mp = 15
			strength = 7
			defence = 6
			magic = 2
			crit = 5
			weapon = "Rusty Sword"
			weapon_base_damage = 9
		"Archer":
			max_hp = 45
			max_mp = 20
			strength = 4
			defence = 4
			magic = 3
			crit = 8
			weapon = "Worn Bow"
			weapon_base_damage = 7
		"Sorcerer":
			max_hp = 40
			max_mp = 30
			strength = 2
			defence = 3
			magic = 8
			crit = 4
			weapon = "Cracked Staff"
			weapon_base_damage = 6
	hp = max_hp
	mp = max_mp


func add_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_to_next:
		xp -= xp_to_next
		_level_up()


func _level_up() -> void:
	level += 1
	max_hp += 8
	max_mp += 4
	hp = max_hp
	mp = max_mp
	strength += 1
	defence += 1
	magic += 1
	crit += 1
	xp_to_next = int(round(xp_to_next * 1.2))


func add_gold(amount: int) -> void:
	gold += amount


func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		return true
	return false


# Called when the first chapter boss is defeated and the Soul Box is opened.
# Per the design doc: boosts Strength and Crit, grants a profession-specific
# skill (Slaughter / Multi-Pierce / Magic Vines), and this new vessel is a
# strict upgrade over the last one — old stats aren't kept, but weapons are.
func apply_first_vessel_upgrade() -> void:
	vessel_name = "First Vessel"
	strength += 4
	crit += 4
	max_hp += 15
	max_mp += 10
	hp = max_hp
	mp = max_mp

	var new_skill := ""
	match profession:
		"Warrior":
			new_skill = "Slaughter"
		"Archer":
			new_skill = "Multi-Pierce"
		"Sorcerer":
			new_skill = "Magic Vines"

	if new_skill != "" and not skills.has(new_skill):
		skills.append(new_skill)


# Flat % per-level damage scaling, per the DARKHIDE design doc:
# damage = base_weapon_damage * (1 + 0.05 * level) * stat_modifier
func get_attack_damage(is_skill_boosted: bool = false) -> int:
	var stat_mod: float = 1.0 + (float(strength) * 0.02)
	var level_mod: float = 1.0 + (0.05 * float(level - 1))
	var dmg: float = float(weapon_base_damage) * level_mod * stat_mod

	if is_skill_boosted:
		dmg *= 1.2  # Battle Focus: +20% damage this round

	var crit_chance: float = float(crit) * 0.01
	if randf() < crit_chance:
		dmg *= 1.5

	return int(round(dmg))
