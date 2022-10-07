extends KinematicBody2D

var velocity = Vector2.ZERO
export var SPEED = 100
onready var anim = $AnimationPlayer

func _ready():
	pass
	
func _physics_process(delta):
	
	if Input.is_action_pressed("ui_left"):
		velocity.x = -1
	elif Input.is_action_pressed("ui_right"):
		velocity.x = 1
	else:
		velocity.x = 0
		
		
	if Input.is_action_pressed("ui_up"):
		velocity.y = -1
	elif Input.is_action_pressed("ui_down"):
		velocity.y = 1
	else:
		
		velocity.y = 0
		
	if (velocity.x >= 0 and velocity.y > 0) or (velocity.x <= 0 and velocity.y > 0):
		anim.play("walk_down")
	elif (velocity.x >= 0 and velocity.y < 0) or (velocity.x <= 0 and velocity.y < 0):
		anim.play("walk_up")
	elif velocity.y == 0 and velocity.x < 0:
		anim.play("walk_left")
	elif velocity.y == 0 and velocity.x > 0:
		anim.play("walk_right")
	else:
		anim.play("idle")
		
	
	
	move_and_slide(velocity * SPEED * delta)


func _on_Door_door_entered(body, change_to):
	if body.name == "WalkingPlayer":
		get_tree().change_scene_to(change_to)
