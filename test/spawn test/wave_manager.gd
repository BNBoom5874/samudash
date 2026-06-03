class_name WaveManager
extends Node

var waves : Array = []
var current_index :int = 0
var current_kills :int = 0


func _ready() -> void:
	setup_waves()
	


func on_enemy_died() -> void:
	current_kills += 1
	
	if current_kills >= waves[current_index].total_count():
		_next_wave()



func _next_wave() -> void:
	current_kills = 0
	current_index += 1
	
	
	if current_index >= waves.size():
		print("จบ")
		return





func setup_waves() -> void:
	var wave1 = WaveData.new()
	wave1.enemies = [{"scene":preload("uid://bcyincdyu0h83"), "count":2}]
	
	wave1.simultaneous_max = 1
	wave1.limit_map = 2
	wave1.spawn_delay = 1.0
	
	waves = [wave1]
