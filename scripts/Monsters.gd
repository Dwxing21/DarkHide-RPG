extends RefCounted
class_name Monsters

# =========================================================
# DARKHIDE - Monster & Wave Data
# =========================================================

static func get_monster(monster_name: String) -> Dictionary:
	match monster_name:
		"Skeleton":
			return {"name": "Skeleton", "hp": 20, "damage": 4, "xp": 10, "gold": 5}
		"Archer Skeleton":
			return {"name": "Archer Skeleton", "hp": 18, "damage": 5, "xp": 15, "gold": 6}
		"Wild Wolf":
			return {"name": "Wild Wolf", "hp": 22, "damage": 5, "xp": 15, "gold": 6}
		"Orc":
			return {"name": "Orc", "hp": 25, "damage": 6, "xp": 10, "gold": 5}
		"Giant Orc":
			return {"name": "Giant Orc", "hp": 40, "damage": 8, "xp": 20, "gold": 10}
		_:
			return {"name": "Unknown", "hp": 10, "damage": 2, "xp": 5, "gold": 0}


# The Chapter 1 boss guarding the way deeper into the caves.
static func get_boss(boss_name: String) -> Dictionary:
	match boss_name:
		"Bone Warden":
			return {"name": "Bone Warden", "hp": 140, "damage": 10, "xp": 150, "gold": 120}
		_:
			return {"name": "Unknown Boss", "hp": 100, "damage": 8, "xp": 100, "gold": 50}


# Tutorial dungeon: wave 1 is two Skeletons, waves 2-10 mix
# Skeleton + Archer Skeleton, per the design doc.
static func get_tutorial_wave(wave_number: int) -> Array:
	if wave_number == 1:
		return ["Skeleton", "Skeleton"]
	else:
		return ["Skeleton", "Archer Skeleton"]
