extends Node2D

export var speed = 3
export var health = 20
onready var max_hp = 20
export var mp = 20
export var strength = 2
export var magic = Spells.list
export(StreamTexture) var main_sprite = load("res://icon.png")

var selectable = false
var defending = false

signal selected
signal attack_finished
signal heal_finished
# Called when the node enters the scene tree for the first time.
func _ready():
	#Setup stats
	for mem in Party.members:
		if mem.name == name:
			health = mem.hp
			max_hp = mem.max_hp
			strength = mem.strength
	
	
	$Sprite.texture = main_sprite
	$EntityStats/VBoxContainer/ProgressBar.max_value = max_hp
	$EntityStats/VBoxContainer/ProgressBar.value = health
	$EntityStats/VBoxContainer/ProgressBar/HP.text = str(health)
	$EntityStats/VBoxContainer/ProgressBar2.max_value = mp
	$EntityStats/VBoxContainer/ProgressBar2.value = mp
	$EntityStats/VBoxContainer/Label.text = name
func attack():
	$AnimationPlayer.play("attack")
func raise_shield():
	defending = true
	$Shield.visible = true
func drop_shield():
	defending = false
	$Shield.visible = false
func take_damage(dmg):
	if defending:
		health -= dmg * 0.5
	else:
		health -= dmg
	$EntityStats/VBoxContainer/ProgressBar.value = health
func heal(amount):
	health += amount
	$EntityStats/VBoxContainer/ProgressBar.value = health
func cast_spell(spell):
	$AnimationPlayer.play(spell.to_lower())



func reduce_mp(cmd):
	var cost = Spells.spells[cmd].cost
	mp -= cost
	$EntityStats/VBoxContainer/ProgressBar2.value = mp



func selectable():
	if !selectable:
		selectable = true
	else:
		selectable = false
		$ColorRect.hide()
		
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "attack":
		var damage = floor(log(pow(3,strength)))
		emit_signal("attack_finished", damage)
	if Spells.spells.has(anim_name.capitalize()):
		if Spells.spells[anim_name.capitalize()]['offensive']:
			emit_signal("attack_finished", Spells.spells[anim_name.capitalize()]['power'])
		else:
			emit_signal("heal_finished", Spells.spells[anim_name.capitalize()]['power'])


func _on_TextureButton_mouse_entered():
	if selectable:
		$ColorRect.show()



func _on_TextureButton_mouse_exited():
	$ColorRect.hide()


func _on_TextureButton_pressed():
	if selectable:
		emit_signal("selected", self)
