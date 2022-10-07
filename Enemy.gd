extends Node2D

export var health = 10
export var speed = 1
export var strength = 1


var title = "Enemy"
signal attack_finished
signal selected
signal dead

var selectable = false
var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	var data = EnemyTypes.types[rng.randi_range(0, EnemyTypes.types.size()-1)]
	title = data.name
	speed = data.speed
	strength = data.strength
	
	$EntityStats/VBoxContainer/ProgressBar.max_value = health
	$EntityStats/VBoxContainer/ProgressBar.value = health
	$EntityStats/VBoxContainer/Label.text = title
	$EntityStats/VBoxContainer/ProgressBar2.hide()
func turn_into_boss(data):
	title = data.name
	speed = data.speed
	strength = data.strength
	
	$EntityStats/VBoxContainer/ProgressBar.max_value = health
	$EntityStats/VBoxContainer/ProgressBar.value = health
	$EntityStats/VBoxContainer/Label.text = title
	$EntityStats/VBoxContainer/ProgressBar2.hide()
func take_damage(dmg):
	health -= dmg
	$EntityStats/VBoxContainer/ProgressBar.value = health
func attack():
	$AnimationPlayer.play("attack")

func selectable():
	if !selectable:
		selectable = true
	else:
		selectable = false
		$ColorRect.hide()
func die():
	$AnimationPlayer.play("die")
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "attack":
		var damage = floor(log(pow(3,strength)))
		emit_signal("attack_finished", damage)
	if anim_name == "die":
		emit_signal("dead", self)




func _on_TextureButton_pressed():
	if selectable:
		emit_signal("selected", self)


func _on_Select_mouse_entered():
	if selectable:
		$ColorRect.show()


func _on_Select_mouse_exited():
	$ColorRect.hide()
