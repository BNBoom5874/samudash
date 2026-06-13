#รับหน้าที่จัดการ Spawn ตามที่ waveM กำหนดเงื่อนไขให้

class_name SpawnController
extends Node

@export var wave_manager: WaveManager #ข้อมูลเงื่อนไข
@export var zone_group: Node2D #หัวหน้าโซน  คอยเก็บรายชื่อลูกโซนทั้งหมด

var zones: Array = [] #เก็บบันทึกทุกโซนไว้ เป็นเหมือนกระดาษลงชื่อการเข้าทำงาน
var current_wave: WaveData #สำหรับเงื่อนไข wave ปัจจุบัน
var spawn_token: int = 0 #ใบอนุญาตการ spawn ถ้าผิดขึ้นมา เกิดไม่ได้เลย

func _ready() -> void:
	zones = zone_group.get_children() #ลงชื่อเข้าทำงาน

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

			# รอจนต่ำกว่า limit และมี zone ว่าง
			while (get_tree().get_nodes_in_group("enemy").size() >= current_wave.limit_map
					or not _has_free_zone()):
				await get_tree().create_timer(current_wave.spawn_delay).timeout
				if token != spawn_token: return

			_spawn_one(e["scene"])
			await get_tree().create_timer(current_wave.spawn_delay).timeout
			if token != spawn_token: return

			

func _has_free_zone() -> bool:
	var allowed = current_wave.allowed_zones
	var free_count = 0
	for z in zones:
		var name_ok = allowed.is_empty() or z.name in allowed
		var free = z.is_free()
		
		if name_ok and free:
			free_count += 1
	
	return free_count > 0

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
