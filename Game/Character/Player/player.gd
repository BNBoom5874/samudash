extends CharacterBody2D
class_name  Player


#region Variables 
@onready var hitbox : Hitbox = $Hitbox
@onready var hurtbox : Hurtbox = $Hurtbox

enum States{
	IDLE, DASH, COOLDOWN, DEAD
}

var states = States.IDLE




const CARDINAL_SNAP = 40.0    # px ที่ยอมให้เบี่ยงสำหรับทิศตรง
const DIAGONAL_DOT_MIN = 0.85 # ความตรงขั้นต่ำสำหรับทิศเฉียง
const ZONE_DOT_MIN = 0.6      # ขอบโซนกว้างของแต่ละทิศ รับศัตรูได้กว้างแต่ไหน



const DASH_DISTANCE : float = 200.0  # ระยะวาร์ปปกติ ปรับได้
const Gravity : float = 400.0

var input_dir : Vector2 = Vector2.ZERO



#time
var gravity_scale : float = 1.0
var gravity_recover_timer : float = 0.0
const GRAVITY_RECOVER_TIME : float = 1.5



const Cooldown : float = 1.0
const Time_Dash : float = 0.05


var timer_dash : float = 0.0
var timercool : float = 0.0



#input
var keyUp :bool = false
var keyUpL :bool = false
var keyUpR :bool = false
var keyLeft :bool = false
var keyRight :bool = false
var keyCenter :bool = false
var keyDownL :bool = false
var keyDownR :bool = false
var keyDown :bool = false


#endregion

#region Loop function 

func _ready() -> void:
	add_to_group("player")

	
	hitbox.is_active = false


func _physics_process(delta: float) -> void:
	set_Time(delta)
	
	get_input()
	
	move_and_slide()
	
	match states:
		States.IDLE:
			velocity.x = move_toward(velocity.x,0 ,600)
			
			handle_Dash_Input()
			apply_gravity(delta)
			
		States.DASH:
			handle_wall_collision()
			hitbox.is_active = true
			if timer_dash <= 0:
				timercool = Cooldown
				states = States.COOLDOWN
			
		States.COOLDOWN:
			hitbox.is_active = false
			velocity.x = move_toward(velocity.x, 0, 20)
			apply_gravity(delta)
			if timercool <= 0.0:
				
				states = States.IDLE
	
	



func get_input() -> void:
	keyUp = Input.is_action_just_pressed("up")
	keyUpL = Input.is_action_just_pressed("up_left")
	keyUpR = Input.is_action_just_pressed("up_right")
	keyLeft = Input.is_action_just_pressed("left")
	keyRight = Input.is_action_just_pressed("right")
	keyCenter = Input.is_action_just_pressed("centerbutton")
	keyDownL = Input.is_action_just_pressed("down_left")
	keyDownR = Input.is_action_just_pressed("down_right")
	keyDown = Input.is_action_just_pressed("down")

#endregion

#region Custom functions 

func apply_gravity(delta) -> void:
	if gravity_scale < 1.0:
		gravity_recover_timer += delta
		gravity_scale = min(gravity_recover_timer / GRAVITY_RECOVER_TIME, 1.0)
	
	if not is_on_floor():
		velocity.y += Gravity * gravity_scale * delta


func set_Time(delta) -> void:

	if timer_dash > 0:
		timer_dash -= delta
	
	if timercool > 0:
		timercool -= delta


	#region Dash
	
	
func handle_Dash_Input() -> void:

	
	if keyUp:
		input_dir = Vector2(0, -1)
	elif keyUpL:
		input_dir = Vector2(-1, -1).normalized()
	elif keyUpR:
		input_dir = Vector2(1, -1).normalized()
	elif keyLeft:
		input_dir = Vector2(-1, 0)
	elif keyRight:
		input_dir = Vector2(1, 0)
	elif keyDown:
		input_dir = Vector2(0, 1)
	elif keyDownL:
		input_dir = Vector2(-1, 1).normalized()
	elif keyDownR:
		input_dir = Vector2(1, 1).normalized()
	else:
		input_dir = Vector2.ZERO
	
	if input_dir != Vector2.ZERO:
		start_dash()
		states = States.DASH
	

	


func start_dash() -> void:
	var candidates = find_candidates(input_dir)
	
	if candidates.is_empty():
		do_normal_dash(input_dir) #พุ่งปกติ ไม่ล็อกศัตรู
		return
	
	# ชั้น 3
	var target = select_enemy(candidates, input_dir)
	
	# ชั้น 4
	if can_lock_on(target, input_dir):
		do_lock_dash(target)
	else:
		do_normal_dash(input_dir)
	
	timer_dash = Time_Dash


func find_candidates(input_dir: Vector2) -> Array:
	var candidates = []
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	for enemy in enemies:
		var dir_to_enemy = (enemy.global_position - global_position).normalized()
		var dot = input_dir.normalized().dot(dir_to_enemy)
		if dot > ZONE_DOT_MIN:
			candidates.append(enemy)
	
	return candidates
	

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

func do_lock_dash(target: Node):
	gravity_scale = 0.0
	gravity_recover_timer = 0.0

	
	var safe_pos = get_safe_warp(global_position, target.global_position)
	
	
	
	global_position = safe_pos
	timer_dash = 0.1
	

func do_normal_dash(input_dir: Vector2):
	var far_pos = global_position + input_dir.normalized() * 1500.0
	var safe_pos = get_safe_warp(global_position, far_pos)
	global_position = safe_pos
	timercool = Cooldown
	states = States.COOLDOWN
	
func handle_wall_collision() -> void:
	if states == States.COOLDOWN : return
	if  (is_on_wall() or is_on_ceiling()):
		velocity = get_wall_normal() * 300
		timercool = Cooldown
		states = States.COOLDOWN





	#endregion



func get_safe_warp(from: Vector2, to: Vector2) -> Vector2:
	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [self]
	query.collision_mask = 1  # เลข layer ของกำแพง ปรับให้ตรงกับโปรเจกต์
	var result = space.intersect_ray(query)
	
	if result:
		# มีกำแพงขวาง → หยุดแค่หน้ากำแพง
		return result.position - (to - from).normalized() * 8.0
	return to


#endregion





func _on_hurtbox_die() -> void:
	pass # Replace with function body.


func _on_hitbox_hit() -> void:

	gravity_scale = 0.0
	gravity_recover_timer = 0.0
	timercool = 0
	states = States.IDLE
