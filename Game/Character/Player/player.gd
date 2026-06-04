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

const DASH_DISTANCE : float = 200.0
const Gravity : float = 600.0

var input_dir : Vector2 = Vector2.ZERO

const Cooldown : float = 0.5
const Time_Dash : float = 0.5

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

	if states == States.IDLE or (states == States.COOLDOWN and timercool <= 0.0):
		handle_Dash_Input()

	match states:
		States.IDLE:
			apply_gravity(delta)
			velocity.x = move_toward(velocity.x, 0, 0.5)
			if is_on_floor():
				velocity.x = 0

		States.DASH:
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

	move_and_slide()


func get_input() -> void:
	keyUp    = Input.is_action_just_pressed("up")
	keyUpL   = Input.is_action_just_pressed("up_left")
	keyUpR   = Input.is_action_just_pressed("up_right")
	keyLeft  = Input.is_action_just_pressed("left")
	keyRight = Input.is_action_just_pressed("right")
	keyCenter = Input.is_action_just_pressed("centerbutton")
	keyDownL = Input.is_action_just_pressed("down_left")
	keyDownR = Input.is_action_just_pressed("down_right")
	keyDown  = Input.is_action_just_pressed("down")

#endregion

#region Custom functions 

func apply_gravity(delta) -> void:
	if not is_on_floor():
		velocity.y += Gravity * delta


func set_Time(delta) -> void:
	if timer_dash > 0:
		timer_dash -= delta
	if timercool > 0:
		timercool -= delta

#endregion

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
		var diff = enemy.global_position - global_position
		if dir.normalized().dot(diff.normalized()) > ZONE_DOT_MIN:
			var dist = diff.length()
			if dist < nearest_dist:
				nearest_dist = dist
				nearest = enemy

	return nearest


func is_valid_target(enemy: Node) -> bool:
	if not is_instance_valid(enemy):
		return false
	return enemy.get_node_or_null("Hurtbox") != null


@warning_ignore("shadowed_variable")
func can_lock_on(enemy: Node, input_dir: Vector2) -> bool:
	var diff = enemy.global_position - global_position

	if input_dir.x == 0 or input_dir.y == 0:
		if input_dir.x == 0:
			return abs(diff.x) <= CARDINAL_SNAP
		else:
			return abs(diff.y) <= CARDINAL_SNAP

	var dot = input_dir.normalized().dot(diff.normalized())
	return dot >= DIAGONAL_DOT_MIN


func do_lock_dash(target: Node) -> void:
	var result = get_safe_warp_result(global_position, target.global_position)
	global_position = result.position
	timer_dash = 0.1


@warning_ignore("shadowed_variable")
func do_normal_dash(input_dir: Vector2) -> void:
	var far_pos = global_position + input_dir.normalized() * 800.0
	var result = get_safe_warp_result(global_position, far_pos)
	global_position = result.position
	if result.hit:
		velocity = input_dir.bounce(result.normal) * 350.0
	timercool = Cooldown


func get_safe_warp_result(from: Vector2, to: Vector2) -> Dictionary:
	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [self]
	query.collision_mask = 1
	var result = space.intersect_ray(query)

	if result:
		var safe_pos = result.position - (to - from).normalized() * 16.0
		return {"position": safe_pos, "hit": true, "normal": result.normal}
	return {"position": to, "hit": false, "normal": Vector2.ZERO}

#endregion



#region Signal
func _on_hurtbox_die() -> void:
	pass


func _on_hitbox_hit() -> void:
	hitbox.is_active = false
	velocity.x = randi_range(-200, 200)
	velocity.y = randi_range(-100, -40)
	timercool = 0
	states = States.IDLE

#endregion
