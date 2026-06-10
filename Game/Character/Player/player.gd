extends CharacterBody2D
class_name Player

#region Variables
@onready var hitbox : Hitbox = $Hitbox
@onready var hurtbox : Hurtbox = $Hurtbox

enum States { IDLE, DASH, HIT_SLIDE, COOLDOWN, DEAD }
var states = States.IDLE

const CARDINAL_SNAP    = 40.0
const DIAGONAL_DOT_MIN = 0.85
const ZONE_DOT_MIN     = 0.6

const DASH_DISTANCE : float = 100.0
const Gravity       : float = 600.0
const Cooldown      : float = 0.45
const Time_Dash     : float = 0.1
const PLAYER_RADIUS : float = 10.0

var input_dir  : Vector2 = Vector2.ZERO
var timer_dash : float   = 0.0
var timercool  : float   = 0.0

var keyUp     : bool = false
var keyUpL    : bool = false
var keyUpR    : bool = false
var keyLeft   : bool = false
var keyRight  : bool = false
var keyCenter : bool = false
var keyDownL  : bool = false
var keyDownR  : bool = false
var keyDown   : bool = false
#endregion

#region Loop

func _ready() -> void:
	add_to_group("player")
	set_hurtbox(false)
	hitbox.is_active = false

func _physics_process(delta: float) -> void:
	set_Time(delta)
	get_input()

	if states == States.IDLE or states == States.HIT_SLIDE or (states == States.COOLDOWN and timercool <= 0.0):
		handle_Dash_Input()

	match states:
		States.IDLE:
			apply_gravity(delta)
			velocity.x = lerp(velocity.x, 0.0, 50 * delta)
			
			

		States.DASH:
			set_hurtbox(true)
			hitbox.is_active = true
			if timer_dash <= 0:
				timercool = Cooldown
				states = States.COOLDOWN

		States.COOLDOWN:
			set_hurtbox(false)
			hitbox.is_active = false
			
			velocity.x = move_toward(velocity.x, 0, 20)
			apply_gravity(delta)
			if timercool <= 0.0:
				states = States.IDLE
		
		States.HIT_SLIDE:
			set_hurtbox(false)
			hitbox.is_active = false
			
			apply_gravity(delta)
			velocity.x = move_toward(velocity.x, 0, 2)
			
			if velocity.length() < 10.0 or is_on_floor():
				states = States.IDLE

	move_and_slide()

func get_input() -> void:
	keyUp     = Input.is_action_just_pressed("up")
	keyUpL    = Input.is_action_just_pressed("up_left")
	keyUpR    = Input.is_action_just_pressed("up_right")
	keyLeft   = Input.is_action_just_pressed("left")
	keyRight  = Input.is_action_just_pressed("right")
	keyCenter = Input.is_action_just_pressed("centerbutton")
	keyDownL  = Input.is_action_just_pressed("down_left")
	keyDownR  = Input.is_action_just_pressed("down_right")
	keyDown   = Input.is_action_just_pressed("down")

#endregion

#region Helpers

func apply_gravity(delta) -> void:
	if not is_on_floor():
		velocity.y += Gravity * delta

func set_Time(delta) -> void:
	if timer_dash > 0: timer_dash -= delta
	if timercool  > 0: timercool  -= delta

func get_center_of(node: Node) -> Vector2:
	var target_hurtbox = node.get_node_or_null("Hurtbox")
	if target_hurtbox:
		return target_hurtbox.global_position
	return node.global_position

func set_hurtbox(value :bool) -> void:
	if not is_instance_valid(hurtbox):
		return
	
	hurtbox.is_invisible = value

#endregion

#region Dash

func handle_Dash_Input() -> void:
	if keyUp:      input_dir = Vector2(0, -1)
	elif keyUpL:   input_dir = Vector2(-1, -1).normalized()
	elif keyUpR:   input_dir = Vector2( 1, -1).normalized()
	elif keyLeft:  input_dir = Vector2(-1,  0)
	elif keyRight: input_dir = Vector2( 1,  0)
	elif keyDown:  input_dir = Vector2(0,   1)
	elif keyDownL: input_dir = Vector2(-1,  1).normalized()
	elif keyDownR: input_dir = Vector2( 1,  1).normalized()
	else:          input_dir = Vector2.ZERO

	if input_dir != Vector2.ZERO:
		if is_on_floor() and input_dir.y > 0:
			return
		start_dash()
		states = States.DASH


func start_dash() -> void:
	var target = find_nearest_in_direction(input_dir)

	if target != null and can_lock_on(target, input_dir):
		do_lock_dash(target)
	else:
		do_normal_dash(input_dir)


func find_nearest_in_direction(dir: Vector2) -> Node:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var nearest: Node = null
	var nearest_dist := INF

	for enemy in enemies:
		if not is_valid_target(enemy):
			continue
		var enemy_center = get_center_of(enemy)
		var diff = enemy_center - global_position
		var dist = diff.length()
		if dist > DASH_DISTANCE:
			continue
		if dir.normalized().dot(diff.normalized()) > ZONE_DOT_MIN:
			if dist < nearest_dist:
				nearest_dist = dist
				nearest = enemy

	return nearest


func is_valid_target(enemy: Node) -> bool:
	if not is_instance_valid(enemy): return false
	return enemy.get_node_or_null("Hurtbox") != null


func can_lock_on(enemy: Node, dir: Vector2) -> bool:
	var enemy_center = get_center_of(enemy)
	var diff = enemy_center - global_position

	if dir.x == 0 or dir.y == 0:
		if dir.x == 0:
			return abs(diff.x) <= CARDINAL_SNAP
		else:
			return abs(diff.y) <= CARDINAL_SNAP

	return dir.normalized().dot(diff.normalized()) >= DIAGONAL_DOT_MIN

func do_lock_dash(target: Node) -> void:
	var enemy_center = get_center_of(target)
	var diff = enemy_center - global_position

	if diff.length() > DASH_DISTANCE:
		do_normal_dash(input_dir)
		return

	var result = get_safe_warp_result(global_position, enemy_center)
	global_position = result.position
	timer_dash = Time_Dash
	
	# แรงพุ่งเหลือทิศเดิม
	velocity = input_dir.normalized() * 150.0


func do_normal_dash(dir: Vector2) -> void:
	var far_pos = global_position + dir.normalized() * DASH_DISTANCE
	var result  = get_safe_warp_result(global_position, far_pos)
	global_position = result.position
	if result.hit and result.normal != Vector2.ZERO:
		velocity = dir.bounce(result.normal) * 350.0
	else:
		velocity = dir.normalized() * 150.0
	timercool = Cooldown

func get_safe_warp_result(from: Vector2, to: Vector2) -> Dictionary:
	var space = get_world_2d().direct_space_state

	var shape = CircleShape2D.new()
	shape.radius = PLAYER_RADIUS

	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, from)
	query.motion = to - from
	query.exclude = [self]
	query.collision_mask = 1

	var result = space.cast_motion(query)

	if result[0] < 1.0:
		var safe_pos = from + (to - from) * result[0]
		var ray_query = PhysicsRayQueryParameters2D.create(from, to)
		ray_query.exclude = [self]
		ray_query.collision_mask = 1
		var ray_result = space.intersect_ray(ray_query)
		var normal = ray_result.get("normal", Vector2.ZERO)
		return {"position": safe_pos, "hit": true, "normal": normal}

	return {"position": to, "hit": false, "normal": Vector2.ZERO}

#endregion

#region Signals

func _on_hurtbox_die() -> void:
	print("โดนนนนน")
	set_hurtbox(true)
	queue_free()

func _on_hitbox_hit() -> void:
	timercool = 0
	
	hitbox.is_active = false
	velocity = input_dir.normalized() * 650.0
	  # ลอยขึ้นนิดนึงให้รู้สึก
	
	states = States.HIT_SLIDE


func _on_hurtbox_hurt() -> void:
	pass
#endregion
