class_name Zone
extends Area2D

enum SpawnType { FLOOR, WALL, AIR }

@export var spawn_half_size: Vector2 = Vector2(50, 50)  # แก้ต่อ instance ใน Inspector ได้เลย

const WALL_MARGIN: float = 12.0  # กันไม่ให้เกิดติดกำแพง/พื้น
const RAY_REACH: float = 48.0

var body_count: int = 0

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func is_free() -> bool:
	return body_count == 0


# --- detect ---

func _ray_hit(from: Vector2, to: Vector2) -> Dictionary:
	var space = get_world_2d().direct_space_state
	var q = PhysicsRayQueryParameters2D.create(from, to)
	q.collision_mask = 1
	return space.intersect_ray(q)

func detect_environment() -> SpawnType:
	var has_floor = not _ray_hit(
		global_position,
		global_position + Vector2(0, RAY_REACH)
	).is_empty()

	var has_wall = (
		not _ray_hit(global_position, global_position + Vector2(-RAY_REACH, 0)).is_empty()
		or not _ray_hit(global_position, global_position + Vector2(RAY_REACH, 0)).is_empty()
	)

	if has_floor:
		return SpawnType.FLOOR  # พื้น + กำแพง → เกิดบนพื้นเสมอ
	if has_wall:
		return SpawnType.WALL
	return SpawnType.AIR


# --- หาจุดเกิด ---

func get_spawn_position() -> Vector2:
	match detect_environment():
		SpawnType.FLOOR: return _floor_pos()
		SpawnType.WALL:  return _wall_pos()
		_:               return _random_pos()


func _floor_pos() -> Vector2:
	# สุ่ม x ในแนวกว้าง แล้วยิง ray ลงหา y ของพื้นจริง
	var x = randf_range(
		global_position.x - spawn_half_size.x + WALL_MARGIN,
		global_position.x + spawn_half_size.x - WALL_MARGIN
	)
	var from = Vector2(x, global_position.y - spawn_half_size.y)
	var to   = Vector2(x, global_position.y + spawn_half_size.y)
	var hit  = _ray_hit(from, to)

	if hit:
		return hit.position - Vector2(0, WALL_MARGIN)  # ยกขึ้นเล็กน้อยกันติดพื้น
	return Vector2(x, global_position.y)


func _wall_pos() -> Vector2:
	# เก็บ x ของกำแพงที่ชน แล้วสุ่ม y
	var candidates: Array[float] = []

	var hit_l = _ray_hit(global_position, global_position + Vector2(-RAY_REACH, 0))
	var hit_r = _ray_hit(global_position, global_position + Vector2( RAY_REACH, 0))

	if hit_l: candidates.append(hit_l.position.x + WALL_MARGIN)
	if hit_r: candidates.append(hit_r.position.x - WALL_MARGIN)

	var x = candidates.pick_random() if not candidates.is_empty() else global_position.x
	var y = randf_range(
		global_position.y - spawn_half_size.y + WALL_MARGIN,
		global_position.y + spawn_half_size.y - WALL_MARGIN
	)
	return Vector2(x, y)


func _random_pos() -> Vector2:
	return Vector2(
		randf_range(global_position.x - spawn_half_size.x, global_position.x + spawn_half_size.x),
		randf_range(global_position.y - spawn_half_size.y, global_position.y + spawn_half_size.y)
	)


# --- spawn ---

func spawn(scene: PackedScene) -> Node:
	var enemy = scene.instantiate()
	enemy.position = get_spawn_position()
	get_parent().add_child(enemy)

	var stype = detect_environment()
	if enemy.has_method("init_spawn"):
		enemy.init_spawn(stype)

	return enemy


func _on_body_entered(_body):
	body_count = max(0, body_count + 1)
	
func _on_body_exited(_body):
	body_count = max(0, body_count - 1)
	
