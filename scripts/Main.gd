extends Control

# =========================================================
# DARKHIDE - Main Controller
# A simple screen-based state machine driving the tutorial
# slice of the game: Title -> Character Creation -> Town ->
# Guild -> Tutorial Dungeon (10 waves) -> Results.
# =========================================================

enum Screen { TITLE, CHAR_CREATE, TOWN, COMBAT, RESULTS, GAME_OVER }

var current_screen: int = Screen.TITLE

var root_vbox: VBoxContainer
var title_label: Label
var menu_art_frame: PanelContainer
var menu_art_rect: TextureRect
var log_label: RichTextLabel
var button_box: VBoxContainer
var status_label: Label

var enemies: Array = []
var battle_focus_active: bool = false
var in_boss_fight: bool = false


func _ready() -> void:
	_build_layout()
	_show_main_menu()


func _build_layout() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_child(center)

	root_vbox = VBoxContainer.new()
	root_vbox.custom_minimum_size = Vector2(640, 0)
	root_vbox.add_theme_constant_override("separation", 10)
	center.add_child(root_vbox)

	title_label = Label.new()
	title_label.text = "DARKHIDE"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 42)
	title_label.visible = false
	root_vbox.add_child(title_label)

	menu_art_frame = PanelContainer.new()
	var frame_style := StyleBoxFlat.new()
	frame_style.border_width_left = 4
	frame_style.border_width_right = 4
	frame_style.border_width_top = 4
	frame_style.border_width_bottom = 4
	frame_style.border_color = Color(0.55, 0.45, 0.2)
	frame_style.bg_color = Color(0, 0, 0, 0)
	frame_style.content_margin_left = 4
	frame_style.content_margin_right = 4
	frame_style.content_margin_top = 4
	frame_style.content_margin_bottom = 4
	menu_art_frame.add_theme_stylebox_override("panel", frame_style)
	menu_art_frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	menu_art_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	menu_art_frame.visible = false
	root_vbox.add_child(menu_art_frame)

	menu_art_rect = TextureRect.new()
	menu_art_rect.texture = load("res://menu_bg.png")
	menu_art_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	menu_art_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	menu_art_rect.custom_minimum_size = Vector2(200, 200)
	menu_art_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	menu_art_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	menu_art_frame.add_child(menu_art_rect)

	status_label = Label.new()
	status_label.text = ""
	root_vbox.add_child(status_label)

	log_label = RichTextLabel.new()
	log_label.custom_minimum_size = Vector2(0, 220)
	log_label.bbcode_enabled = true
	log_label.fit_content = false
	log_label.scroll_active = true
	log_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(log_label)

	button_box = VBoxContainer.new()
	button_box.add_theme_constant_override("separation", 8)
	root_vbox.add_child(button_box)


func _clear_buttons() -> void:
	for child in button_box.get_children():
		button_box.remove_child(child)
		child.queue_free()


func _add_button(text: String, callback: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.pressed.connect(callback)
	button_box.add_child(btn)
	return btn


func _log(text: String) -> void:
	log_label.append_text(text + "\n")


func _clear_log() -> void:
	log_label.clear()


func _update_status() -> void:
	var gs := GameState
	status_label.text = "%s the %s | Lv.%d | HP %d/%d | MP %d/%d | XP %d/%d | Gold %d" % [
		gs.player_name, gs.profession, gs.level,
		gs.hp, gs.max_hp, gs.mp, gs.max_mp,
		gs.xp, gs.xp_to_next, gs.gold
	]


# ---------------- MAIN MENU ----------------

func _show_main_menu() -> void:
	current_screen = Screen.TITLE
	title_label.visible = true
	menu_art_frame.visible = true
	status_label.text = ""
	_clear_log()
	_log("A hidden city in the mountains near ancient Athens, cut off from the world by a curse.")
	_log("Caves beneath the mountains hide gates torn open by godly conflict — and the power")
	_log("of Vessel Swap, which lets you take on the bodies and abilities of fallen gods.")
	_clear_buttons()
	_add_button("New Game", _show_char_create)
	_add_button("Quit", _quit_game)


func _quit_game() -> void:
	get_tree().quit()


# ---------------- CHARACTER CREATION ----------------

func _show_char_create() -> void:
	current_screen = Screen.CHAR_CREATE
	title_label.visible = false
	menu_art_frame.visible = false
	_clear_log()
	_log("Choose your profession:")
	_log("[b]Warrior[/b] - swords, shields, axes, spears. Tanky and strong.")
	_log("[b]Archer[/b] - bows and daggers. Precise, high crit chance.")
	_log("[b]Sorcerer[/b] - staffs and magic. Fragile, but hits hardest with magic.")
	_clear_buttons()
	_add_button("Warrior", func(): _finish_char_create("Warrior"))
	_add_button("Archer", func(): _finish_char_create("Archer"))
	_add_button("Sorcerer", func(): _finish_char_create("Sorcerer"))


func _finish_char_create(profession: String) -> void:
	GameState.reset_game(profession)
	_show_town(true)


# ---------------- TOWN ----------------

func _show_town(first_time: bool = false) -> void:
	current_screen = Screen.TOWN
	_update_status()
	_clear_log()
	if first_time:
		_log("You arrive in the town of Darkhide, your first vessel — [b]%s[/b] — settling into your bones." % GameState.vessel_name)
		_log("The guild, blacksmith, brewer, tavern, training grounds, and store surround you.")
	elif GameState.first_boss_defeated:
		_log("Word of your triumph over the Bone Warden spreads through Darkhide.")
	elif GameState.tutorial_dungeon_cleared:
		_log("You are back in town. Something dangerous stirs deeper in the caves...")
	else:
		_log("You are back in town.")
	_clear_buttons()

	if not GameState.skills.has("Battle Focus"):
		_add_button("Visit the Guild", _visit_guild)
	elif not GameState.tutorial_dungeon_cleared:
		_add_button("Enter the Tutorial Dungeon", _start_dungeon)
	elif not GameState.first_boss_defeated:
		_add_button("Enter the Boss Chamber", _start_boss_fight)
	else:
		_add_button("Rest (Chapter 1 prototype complete)", func(): _show_town(false))

	_add_button("Visit the Store", _visit_store)


func _visit_guild() -> void:
	_clear_log()
	_log("The guildmaster nods. \"Every adventurer needs a first skill.\"")
	_log("You learn [b]Battle Focus[/b] — a self-buff that empowers your attacks for one round.")
	_log("You also pick up your first bounty: clear the tutorial dungeon.")
	GameState.skills.append("Battle Focus")
	_clear_buttons()
	_add_button("Continue", func(): _show_town(false))


const POTION_COST := 20
const FLASK_COST := 15


func _visit_store() -> void:
	current_screen = Screen.TOWN
	_clear_log()
	_log("The shopkeeper spreads out their wares.")
	_log("[b]Healing Potion[/b] — restores 20 HP (%d gold)" % POTION_COST)
	_log("[b]Magic Flask[/b] — restores 15 MP (%d gold)" % FLASK_COST)
	_update_status()
	_show_store_actions()


func _show_store_actions() -> void:
	_clear_buttons()
	_add_button("Buy Healing Potion (%dg)" % POTION_COST, _buy_potion)
	_add_button("Buy Magic Flask (%dg)" % FLASK_COST, _buy_flask)
	_add_button("Back", func(): _show_town(false))


func _buy_potion() -> void:
	if GameState.spend_gold(POTION_COST):
		GameState.inventory.append("Healing Potion")
		_log("You buy a Healing Potion.")
	else:
		_log("You don't have enough gold for that.")
	_update_status()
	_show_store_actions()


func _buy_flask() -> void:
	if GameState.spend_gold(FLASK_COST):
		GameState.inventory.append("Magic Flask")
		_log("You buy a Magic Flask.")
	else:
		_log("You don't have enough gold for that.")
	_update_status()
	_show_store_actions()


# ---------------- TUTORIAL DUNGEON / COMBAT ----------------

func _start_dungeon() -> void:
	GameState.current_wave = 0
	_next_wave()


func _next_wave() -> void:
	GameState.current_wave += 1
	if GameState.current_wave > GameState.total_waves:
		_dungeon_cleared()
		return

	var wave_monsters: Array = Monsters.get_tutorial_wave(GameState.current_wave)
	enemies.clear()
	for m_name in wave_monsters:
		var data: Dictionary = Monsters.get_monster(m_name)
		enemies.append({
			"name": data["name"],
			"hp": data["hp"],
			"max_hp": data["hp"],
			"damage": data["damage"],
			"xp": data["xp"],
			"gold": data["gold"]
		})

	battle_focus_active = false
	in_boss_fight = false
	_show_combat_intro()


func _show_combat_intro() -> void:
	current_screen = Screen.COMBAT
	_update_status()
	_clear_log()
	_log("[b]Wave %d/%d[/b]" % [GameState.current_wave, GameState.total_waves])
	for e in enemies:
		_log("A %s appears! (HP: %d)" % [e["name"], e["hp"]])
	_show_combat_actions()


func _show_combat_actions() -> void:
	_clear_buttons()
	_add_button("Attack", _do_attack)

	if GameState.skills.has("Battle Focus") and GameState.mp >= 5:
		_add_button("Battle Focus (5 MP)", _use_battle_focus)

	if GameState.inventory.has("Healing Potion"):
		_add_button("Use Healing Potion", _use_potion)

	if GameState.inventory.has("Magic Flask"):
		_add_button("Use Magic Flask", _use_flask)


func _use_battle_focus() -> void:
	GameState.mp -= 5
	battle_focus_active = true
	_log("You focus your mind and body. Your next attack will be empowered!")
	_update_status()
	_enemy_turn()


func _use_potion() -> void:
	GameState.inventory.erase("Healing Potion")
	var heal := 20
	GameState.hp = min(GameState.hp + heal, GameState.max_hp)
	_log("You drink a Healing Potion, recovering %d HP." % heal)
	_update_status()
	_enemy_turn()


func _use_flask() -> void:
	GameState.inventory.erase("Magic Flask")
	var restore := 15
	GameState.mp = min(GameState.mp + restore, GameState.max_mp)
	_log("You drink a Magic Flask, recovering %d MP." % restore)
	_update_status()
	_enemy_turn()


func _do_attack() -> void:
	var target = null
	for e in enemies:
		if e["hp"] > 0:
			target = e
			break
	if target == null:
		return

	var dmg: int = GameState.get_attack_damage(battle_focus_active)
	battle_focus_active = false
	target["hp"] = max(0, target["hp"] - dmg)
	_log("You strike the %s for %d damage!" % [target["name"], dmg])

	if target["hp"] == 0:
		_log("The %s falls!" % target["name"])
		GameState.add_xp(target["xp"])
		GameState.add_gold(target.get("gold", 0))

	_update_status()

	if _all_enemies_dead():
		if in_boss_fight:
			_boss_defeated()
		else:
			_wave_cleared()
	else:
		_enemy_turn()


func _all_enemies_dead() -> bool:
	for e in enemies:
		if e["hp"] > 0:
			return false
	return true


func _enemy_turn() -> void:
	for e in enemies:
		if e["hp"] > 0:
			GameState.hp -= e["damage"]
			_log("The %s hits you for %d damage." % [e["name"], e["damage"]])

	_update_status()

	if GameState.hp <= 0:
		GameState.hp = 0
		_game_over()
		return

	_show_combat_actions()


func _wave_cleared() -> void:
	_log("Wave %d cleared!" % GameState.current_wave)
	_clear_buttons()
	_add_button("Continue", _next_wave)


func _dungeon_cleared() -> void:
	current_screen = Screen.RESULTS
	GameState.tutorial_dungeon_cleared = true
	_clear_log()
	_log("[b]You have cleared the tutorial dungeon![/b]")
	_log("Deeper in the caves, something far more dangerous is stirring.")
	_update_status()
	_clear_buttons()
	_add_button("Return to Town", func(): _show_town(false))


# ---------------- BOSS FIGHT ----------------

func _start_boss_fight() -> void:
	var data: Dictionary = Monsters.get_boss("Bone Warden")
	enemies.clear()
	enemies.append({
		"name": data["name"],
		"hp": data["hp"],
		"max_hp": data["hp"],
		"damage": data["damage"],
		"xp": data["xp"],
		"gold": data["gold"]
	})
	battle_focus_active = false
	in_boss_fight = true
	_show_boss_intro()


func _show_boss_intro() -> void:
	current_screen = Screen.COMBAT
	_update_status()
	_clear_log()
	var boss: Dictionary = enemies[0]
	_log("[b]BOSS: %s[/b]" % boss["name"])
	_log("A massive shape rises from the dark, blocking the way deeper into the caves.")
	_log("(HP: %d)" % boss["hp"])
	_show_combat_actions()


func _boss_defeated() -> void:
	GameState.first_boss_defeated = true
	in_boss_fight = false
	current_screen = Screen.RESULTS
	_clear_log()
	_log("[b]The Bone Warden collapses into dust![/b]")
	_log("A Soul Box materializes where it fell. As you open it, a surge of divine power floods through you...")

	GameState.apply_first_vessel_upgrade()
	var new_skill: String = GameState.skills[GameState.skills.size() - 1]

	_log("Your vessel shifts and reforms. Strength and Crit surge within you.")
	_log("You have learned a new skill: [b]%s[/b]!" % new_skill)
	_update_status()
	_clear_buttons()
	_add_button("Continue", func(): _show_town(false))


func _game_over() -> void:
	current_screen = Screen.GAME_OVER
	_clear_log()
	_log("[b]You have fallen...[/b]")
	_log("Darkness takes you.")
	_clear_buttons()
	_add_button("Restart", _show_char_create)
