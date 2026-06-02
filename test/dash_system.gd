extends CharacterBody2D

# ปรับค่าเหล่านี้ได้
const DASH_SPEED = 800.0
const CARDINAL_SNAP = 3.0    # px ที่ยอมให้เบี่ยงสำหรับทิศตรง
const DIAGONAL_DOT_MIN = 0.85 # ความตรงขั้นต่ำสำหรับทิศเฉียง
const ZONE_DOT_MIN = 0.6      # ขอบโซนกว้างของแต่ละทิศ รับศัตรูได้กว้างแต่ไหน

# ------------------------------------
# ชั้น 1: รับปุ่ม
# ------------------------------------

func _input(event):
	if event.is_action_pressed("dash"):
		var input_dir = get_input_dir()
		if input_dir == Vector2.ZERO:
			return
		execute_dash(input_dir)

func get_input_dir() -> Vector2:
	var x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	var y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return Vector2(x, y)

func _physics_process(_delta):
	move_and_slide()

# ------------------------------------
# ตัวกลาง: เชื่อมทุกชั้น
# ------------------------------------

func execute_dash(input_dir: Vector2):
	# ชั้น 2
	var candidates = find_candidates(input_dir)
	
	if candidates.is_empty():
		do_normal_dash(input_dir)
		return
	
	# ชั้น 3
	var target = select_enemy(candidates, input_dir)
	
	# ชั้น 4
	if can_lock_on(target, input_dir):
		do_lock_dash(target)
	else:
		do_normal_dash(input_dir)

# ------------------------------------
# ชั้น 2: หาศัตรูที่เข้าข่าย
# ------------------------------------

func find_candidates(input_dir: Vector2) -> Array:
	var candidates = []
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	for enemy in enemies:
		var dir_to_enemy = (enemy.global_position - global_position).normalized()
		var dot = input_dir.normalized().dot(dir_to_enemy)
		if dot > ZONE_DOT_MIN:
			candidates.append(enemy)
	
	return candidates

# ------------------------------------
# ชั้น 3: เลือกศัตรู 1 ตัว
# ------------------------------------

func select_enemy(candidates: Array, input_dir: Vector2) -> Node:
	var nearest = null
	var nearest_dist = INF
	var best_angle = null
	var best_dot = -1.0
	
	for enemy in candidates:
		var diff = enemy.global_position - global_position
		var dist = diff.length()
		var dot = input_dir.normalized().dot(diff.normalized())
		
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
		
		if dot > best_dot:
			best_dot = dot
			best_angle = enemy
	
	# ถ้าเป็นตัวเดียวกัน จบเลย
	if nearest == best_angle:
		return nearest
	
	# ยิงเส้นตรงไปหาตัวตรงองศา ดูว่าผ่านตัวใกล้ไหม
	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		best_angle.global_position
	)
	query.exclude = [self]
	var result = space.intersect_ray(query)
	
	if result and result.collider == nearest:
		return nearest  # เส้นผ่านตัวใกล้ → เลือกตัวใกล้
	else:
		return best_angle  # ไม่ผ่าน → เลือกตัวตรงองศา

# ------------------------------------
# ชั้น 4: ตัดสินใจว่า lock ได้ไหม
# ------------------------------------

func can_lock_on(enemy: Node, input_dir: Vector2) -> bool:
	var diff = enemy.global_position - global_position
	
	# ทิศตรง (บน/ล่าง/ซ้าย/ขวา)
	if input_dir.x == 0 or input_dir.y == 0:
		if input_dir.x == 0:  # พุ่งขึ้นหรือลง → เช็คแกน x
			return abs(diff.x) <= CARDINAL_SNAP
		else:                  # พุ่งซ้ายหรือขวา → เช็คแกน y
			return abs(diff.y) <= CARDINAL_SNAP
	
	# ทิศเฉียง
	var dot = input_dir.normalized().dot(diff.normalized())
	return dot >= DIAGONAL_DOT_MIN

# ------------------------------------
# ชั้น 5A: พุ่งแบบ lock
# ------------------------------------

func do_lock_dash(target: Node):
	var dir = (target.global_position - global_position).normalized()
	velocity = dir * DASH_SPEED

# ------------------------------------
# ชั้น 5B: พุ่งธรรมดา
# ------------------------------------

func do_normal_dash(input_dir: Vector2):
	velocity = input_dir.normalized() * DASH_SPEED
