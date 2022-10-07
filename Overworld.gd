extends Node2D

var locations = [
	{
		'pos': Vector2(-17, -5),
		'text': 'You have discovered a town',
		'goto': preload("res://Town.tscn"),
		'texture': preload("res://assets/town.png")
	}
]

var noise = OpenSimplexNoise.new()
var forest_noise = OpenSimplexNoise.new()
export var water_line = 0.0
export var sand_amount= 0.2
export var mountain_level = 0.4
export var snow_level = 0.6

export var main_menu = false

var tile_size = 8
var map_size = 128

var portal = null


var move = Vector2.ZERO
var move_time = 0.1
var move_timer = 0
var offset = Vector2(Party.world_pos.x, Party.world_pos.y)
var draw_offset = Vector2(Party.world_pos.x, Party.world_pos.y)
var p_pos = Vector2(62,50)

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	
	noise.seed = 4
	noise.octaves = 6
	noise.period = 80
	noise.persistence = 0.5
	
	forest_noise.seed = 5
	forest_noise.octaves = 15
	forest_noise.period = 25
	forest_noise.persistence = 0.6
	$Label.text = "Position\nx: %d,  y: %d" % [offset.x, offset.y]




func _process(delta):
	if main_menu:
		offset += Vector2(-1,-1)
		update()
		return
		
	if move_timer < move_time:
		move_timer += delta
		return
	else:
		move_timer = 0
	
	
	if Input.is_action_pressed("ui_right"):
		move.x = 1
	elif Input.is_action_pressed("ui_left"):
		move.x = -1
	elif Input.is_action_pressed("ui_down"):
		move.y = 1
	elif Input.is_action_pressed("ui_up"):
		move.y = -1
	else:
		move = Vector2.ZERO


	if move != Vector2.ZERO:
		var tile = get_tile(offset.x+move.x+p_pos.x, offset.y+move.y+p_pos.y)
		
		#Player is trying to move to a Inaccessable tile - DONT MOVE
		if (tile == Color.mediumturquoise or tile == Color.gray):
			pass
		#Move the player
		else:
			offset += move
			draw_offset -= move
			update()

		moved()

		
	move = Vector2.ZERO




func _draw():
	
	for x in map_size:
		for y in map_size:
			var rect = Rect2(Vector2(x*tile_size,y*tile_size), Vector2(tile_size,tile_size))
			var draw_x = x + offset.x
			var draw_y = y + offset.y
			var tile = get_tile(floor(draw_x), floor(draw_y))
			draw_rect(rect, tile, true, 1.0, false)
	if !main_menu:
		draw_rect(Rect2(Vector2(tile_size*p_pos.x, tile_size*p_pos.y), Vector2(tile_size, tile_size)), Color.red)
		for l in locations:
			draw_texture(l.texture, ((l.pos+p_pos-offset)*tile_size)-Vector2(10,24))





func get_tile(x,y):
	var value = noise.get_noise_2d(x, y)
	if value < water_line-sand_amount:
		return Color.mediumturquoise
	elif value <= water_line:
		return Color.bisque
	elif value > snow_level:
		return Color.white
	elif value > mountain_level:
		return Color.gray
	
	elif value > water_line:
		var f_val = forest_noise.get_noise_2d(y,x)
		if f_val > 0.2:
			return Color.forestgreen
		return Color.mediumseagreen
	else:
		return Color.black




func moved():
	Party.world_pos = offset
	$Label.text = "Position\nx: %d,  y: %d" % [offset.x, offset.y]
	
	for l in locations:
		if l.pos == offset:
			if l.goto != null:
				get_tree().change_scene_to(l.goto)
	
	var enemy_encountered = rng.randi_range(1,100)
	if(enemy_encountered < Party.encounter_rate):
		get_tree().change_scene_to(preload("res://Battle.tscn"))
