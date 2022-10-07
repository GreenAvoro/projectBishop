extends Node


var members = [
	{
		'name': 'Player',
		'level': 1,
		'max_hp': 20,
		'hp': 20,
		'exp': 0,
		'exp_cap': 100,
		'strength': 6,
	},
	{
		'name': 'Abigail',
		'level': 1,
		'max_hp': 15,
		'hp': 15,
		'exp': 0,
		'exp_cap': 100,
		'strength': 3,
	},
	{
		'name': 'Serena',
		'level': 1,
		'max_hp': 20,
		'hp': 20,
		'exp': 0,
		'exp_cap': 100,
		'strength': 1,
	},
	{
		'name': 'Gold',
		'level': 1,
		'max_hp': 30,
		'hp': 30,
		'exp': 0,
		'exp_cap': 100,
		'strength': 5,
	}
]
var world_pos = Vector2(0,0)
var encounter_rate = 2
var boss_battle = "Omega"

func level_up(member):
	for mem in members:
		if mem.name == member.name:
			mem.exp = 0 
			mem.level += 1
			mem.exp_cap = mem.level * 75
			mem.strength += 1
			
	
