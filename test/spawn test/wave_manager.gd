class_name WaveManager
extends Node

signal score_change(new_score: int)
var score : int = 0

@export var spawn_controller : Node  

var waves : Array = []
var current_index :int = 0
var current_kills :int = 0


func _ready() -> void:
	setup_waves()
	spawn_controller.receive_wave(waves[current_index])
	




func _next_wave() -> void:
	current_kills = 0
	current_index += 1
	
	
	if current_index >= waves.size():
		print("จบ")
		return
	
	spawn_controller.receive_wave(waves[current_index])





func setup_waves() -> void:
	var wave1 = WaveData.new()
	wave1.enemies = [{"scene":preload("uid://dr1qvvlklshwt"), "count":0}]
	
	wave1.simultaneous_max = 1
	wave1.simultaneous_chance = 0.7
	wave1.limit_map = 10
	wave1.spawn_delay = 0.5
	wave1.allowed_zones = ["Zone","Zone2","Zone3"] as Array[StringName]
	
	waves = [wave1]


#Signal

func on_enemy_died() -> void:
	current_kills += 1

	score += 1
	
	

	if current_kills >= waves[current_index].total_count():
		score_change.emit("End")
		spawn_controller.stop_spawning()
		_next_wave()
	else:
		score_change.emit(score)
