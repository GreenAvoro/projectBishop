extends VBoxContainer

onready var exp_counter = 0
var counting = false

signal done_adding

func _ready():
	reset_bars()



func reset_bars():
	for mem in Party.members:
		for bar in get_tree().get_nodes_in_group('exp_bar'):
			bar.value = mem.exp
			bar.max_value = mem.exp_cap
			bar.get_parent().get_parent().get_parent().find_node("Level").text = "Level %d" % mem.level



func _process(delta):
	if exp_counter > 0:
		for bar in get_tree().get_nodes_in_group('exp_bar'):
			bar.value += 0.5
		exp_counter -= 0.5
		for mem in Party.members:
			mem.exp += 0.5
			if mem.exp >= mem.exp_cap:
				Party.level_up(mem)
				reset_bars()
	elif counting:
		$Stats/MarginContainer/VBoxContainer/Button.show()


func _on_Button_pressed():
	emit_signal("done_adding")
