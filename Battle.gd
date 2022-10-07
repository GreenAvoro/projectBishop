extends Node2D

var turn_order = []
onready var enemies = []
onready var party = get_tree().get_nodes_in_group('party')
onready var active_turn = $Player
onready var selected = null
onready var healthy = []
var command = "attack"
var rng = RandomNumberGenerator.new()
var active_offset = 40
var enemy_scene = preload("res://Enemy.tscn")

func _ready():
	rng.randomize()
	enemies = spawn_enemies()
	for mem in party:
		mem.connect("attack_finished", self, "player_attack")
		mem.connect("selected", self, "player_selected")
		mem.connect("heal_finished", self, "player_heal")
	for enemy in enemies:
		enemy.connect("attack_finished", self, "enemy_attack")
		enemy.connect("selected", self, "enemy_selected")
		enemy.connect("dead", self, "enemy_dead")
	$Victory.connect("done_adding", self, "close_battle")
	turn_order = sort(enemies+party, 'speed')
	
	active_turn = turn_order[0]
	setup_turn()
	
	
	
	
func spawn_enemies():
	if Party.boss_battle != "":
		var enemy = enemy_scene.instance()
		add_child(enemy)
		enemy.position = $Position2D2.position
		
		#Get the boss data from the global script and reupdate the instanced enemy to a boss 
		enemy.turn_into_boss(EnemyTypes.bosses[Party.boss_battle])
		return [enemy]
	else:
		var spawns = get_tree().get_nodes_in_group('spawn_point')
		var num_enemies = rng.randi_range(1, spawns.size()-1)
		enemies = []
		for i in num_enemies:
			var enemy = enemy_scene.instance()
			enemies.push_back(enemy)
			add_child(enemy)
			var spawn = rng.randi_range(0, spawns.size()-1)
			enemy.position = spawns[spawn].position
			spawns.remove(spawn)
		return enemies #Return the enemies array so that we don't need to search for them with groups
	



func sort(arr, stat):
	if stat == 'speed':
		for i in arr.size():
			for j in arr.size() - i -1:
				if arr[j].speed < arr[j+1].speed:
					var temp = arr[j]
					arr[j] = arr[j+1]
					arr[j+1] = temp
	return arr




func setup_turn():
	if active_turn.is_in_group('party'):
		$CanvasLayer/BattleControl/Panel/Controls.show()
		$CanvasLayer/BattleControl/Panel/Back.hide()
		setup_magic()
		player_active()
		
		active_turn.drop_shield()
	else:
		$CanvasLayer/BattleControl/Panel/Controls.hide()
		$CanvasLayer/BattleControl/Panel/Back.hide()
		active_turn.attack()
		
		
		
func player_active():
	active_turn.position.x -= active_offset
	
	
	
	
func reset_player():
	active_turn.position.x += active_offset
	
	
	
func setup_magic():
	for n in $CanvasLayer/BattleControl/Panel/MagicControls.get_children():
		n.queue_free()
	if active_turn.magic.size() == 0:
		$CanvasLayer/BattleControl/Panel/Controls/Magic.disabled = true
		return
	else:
		$CanvasLayer/BattleControl/Panel/Controls/Magic.disabled = false
	
	for spell in active_turn.magic:
		var button = Button.new()
		button.text = spell
		button.connect("pressed", self, "MagicPressed", [spell])
		$CanvasLayer/BattleControl/Panel/MagicControls.add_child(button)
		
		
		
		
func new_turn():
	for entity in turn_order:
		if entity.health <= 0:
			if entity.is_in_group("enemy"):
				turn_order.erase(entity)
				enemies.erase(entity)
				entity.die()
			else:
				turn_order.erase(entity)
	
	turn_order.push_back(turn_order.pop_front())
	if active_turn.is_in_group('party'):
		reset_player()
	active_turn = turn_order[0]
	setup_turn()
	
	
	
func MagicPressed(mag):
	command = mag
	if active_turn.mp >= Spells.spells[mag].cost:
		disable_controls()
		$CanvasLayer/BattleControl/Panel/MagicControls.hide()
		$CanvasLayer/BattleControl/Panel/Controls.hide()
		$CanvasLayer/BattleControl/Panel/Back.show()
		if Spells.spells[mag]['offensive']:
			$Camera2D/AnimationPlayer.play("select_enemy")
			for enemy in enemies:
				enemy.selectable()
		else:
			$Camera2D/AnimationPlayer.play("select_player")
			for mem in party:
				mem.selectable()
	else:
		update_log("Not enough MP")




func enemy_attack(damage):
	
	for mem in party:
		if mem.health > 0:
			healthy.push_back(mem)
	var x = rng.randi_range(0, healthy.size()-1)
	if healthy.size() != 0:
		healthy[x].take_damage(damage)
		update_log(active_turn.title+" Attacked "+healthy[x].name+" for "+str(damage)+ " damage.")
		
	
	new_turn()
	



func enemy_dead(enemy):	
	if enemies.size() == 0:
		wrap_up()
		return
		
		
		
		
func player_attack(dmg):
	selected.take_damage(dmg)
	#if it was a spell, then subtract MP
	if Spells.spells.has(command):
		active_turn.reduce_mp(command)
	update_log("%s attacked %s for %d damage." % [active_turn.name, selected.title, dmg])
	enable_controls()
	new_turn()
	

func player_heal(amount):
	active_turn.reduce_mp(command)
	selected.heal(amount)
	update_log("%s healed %s for %dhp." % [active_turn.name, "themself" if active_turn == selected else selected.name, amount])
	enable_controls()
	new_turn()
	
	
	
	
func enable_controls():
	$CanvasLayer/BattleControl/Panel/Controls/Attack.disabled = false
	$CanvasLayer/BattleControl/Panel/Controls/Defend.disabled = false
	$CanvasLayer/BattleControl/Panel/Controls/Magic.disabled = false
	$CanvasLayer/BattleControl/Panel/MagicControls.hide()
	
	
func disable_controls():
	$CanvasLayer/BattleControl/Panel/Controls/Attack.disabled = true
	$CanvasLayer/BattleControl/Panel/Controls/Defend.disabled = true
	$CanvasLayer/BattleControl/Panel/Controls/Magic.disabled = true
	
	

	
	
	
	
func update_log(text):
	$CanvasLayer/BattleControl/Panel/Panel/RichTextLabel.text += "\n> "+text
	$CanvasLayer/BattleControl/Panel/Panel/RichTextLabel.scroll_following = true
	
	
	
	
func enemy_selected(enemy):
	$Camera2D/AnimationPlayer.play("RESET")
	selected = enemy
	for enemy in enemies:
		enemy.selectable()
	if command == "attack":
		active_turn.attack()
	elif Spells.spells.has(command):
		if Spells.spells[command]['offensive']:
			active_turn.cast_spell(command)
	
	
	
	
	
func player_selected(player):
	$Camera2D/AnimationPlayer.play("RESET")
	selected = player
	for mem in party:
		mem.selectable()
	if Spells.spells.has(command):
		if !Spells.spells[command]['offensive']:
			selected.cast_spell(command)





func _on_Attack_pressed():
	command = "attack"
	disable_controls()
	$CanvasLayer/BattleControl/Panel/Controls.hide()
	$CanvasLayer/BattleControl/Panel/Back.show()
	$Camera2D/AnimationPlayer.play("select_enemy")
	for enemy in enemies:
		enemy.selectable()




func _on_Defend_pressed():
	active_turn.raise_shield()
	update_log("%s defends." % active_turn.name)
	new_turn()




func _on_Magic_pressed():
	$CanvasLayer/BattleControl/Panel/MagicControls.show()
	


func _on_Button_pressed():
	get_tree().reload_current_scene()



func wrap_up():
	$Victory.visible = true
	$Victory.exp_counter = 75
	$Victory.counting = true
	$CanvasLayer/BattleControl/Panel/Controls.visible = false
	
func close_battle():
	#Apply all data to the Global varaibles
	for mem in Party.members:
		for p in party:
			if p.name == mem.name:
				mem.hp = p.health
	get_tree().change_scene_to(load("res://Overworld.tscn"))


func _on_Back_pressed():
	$CanvasLayer/BattleControl/Panel/Controls.show()
	$CanvasLayer/BattleControl/Panel/Back.hide()
	$Camera2D/AnimationPlayer.play("RESET")
	enable_controls()
	setup_magic()
	if command == "attack":
		for enemy in enemies:
			enemy.selectable()
	elif Spells.spells.has(command):
		if Spells.spells[command].offensive:
			for enemy in enemies:
				enemy.selectable()
		else:
			for mem in party:
				mem.selectable()
	else:
		for mem in party:
			mem.selectable()
	
