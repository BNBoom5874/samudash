class_name SpawnController
extends Node

@export var wave_manager: WaveManager
@export var zone_group: Node2D

var zones: Array = []
var current_wave: WaveData
var spawn_token: int = 0

func _ready() -> void:
	zones = zone_group.get_children()

func receive_wave(wave: WaveData) -> void: #อัปเดตระดับ wave 
	current_wave = wave
	spawn_token += 1
	_spawn_wave(spawn_token)

func stop_spawning() -> void:
	spawn_token += 1

func _spawn_wave(token: int) -> void:
	for e in current_wave.enemies:
		var count := int(e["count"])
		for i in range(count):
			if token != spawn_token: return

			while get_tree().get_nodes_in_group("enemy").size() >= current_wave.limit_map:
				await get_tree().create_timer(0.2).timeout
				if token != spawn_token: return

			await get_tree().create_timer(current_wave.spawn_delay).timeout
			if token != spawn_token: return

			_spawn_one(e["scene"])

func _spawn_one(scene: PackedScene) -> void:
	var allowed = current_wave.allowed_zones
	var pool = zones.filter(func(z):
		var name_ok = allowed.is_empty() or z.name in allowed
		return name_ok and z.is_free()
	)
	if pool.is_empty():
		return

	var chosen = pool.pick_random()
	var enemy = chosen.spawn(scene)
	enemy.die.connect(wave_manager.on_enemy_died)
