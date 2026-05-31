extends CharacterBody2D
class_name  Player


#region Variables 

var enemy : Node2D = null
var lock_range : float = 200.0


const DashSpeed : float = 1200.0
const Gravity : float = 600.0

var input_dir : Vector2 = Vector2.ZERO


var dashspeed  = DashSpeed
var gravity = Gravity

#time
const Cooldown : float = 0.4
const Time_Dash : float = 0.3


var timer_dash : float = 0.0
var timercool : float = 0.0


var is_dashing : bool = false
var is_cooldown : bool = false
var wall_hit : bool = false

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
	enemy = get_tree().get_first_node_in_group("enemy")


func _physics_process(delta: float) -> void:
	if input_dir != Vector2.ZERO:
		print("*",is_dash_toward_enemy())
	
	set_Time(delta)
	
	get_input()
	
	handle_Dash_Input()
	
	
	apply_gravity(delta)
	
	if is_cooldown:
		velocity.x = move_toward(velocity.x, 0, 20)
	
	move_and_slide()
	
	handle_wall_collision()



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
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta


func set_Time(delta) -> void:
	
	
	if timer_dash > 0:
		timer_dash -= delta
	else:
		timer_dash = 0.0
		if is_dashing:
			is_cooldown = true
			timercool = Cooldown
			is_dashing = false
			end_dash()
	
	if timercool > 0:
		timercool -= delta
	
	else:
		timercool = 0.0
		if is_cooldown:
			is_cooldown = false
			wall_hit = false


	#region Dash
	
	
func handle_Dash_Input() -> void:
	if is_dashing or is_cooldown: return
	
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
	

	


func start_dash() -> void:
	if is_dash_toward_enemy():
		var to_enemy = (enemy.global_position - global_position).normalized()
		velocity = to_enemy * dashspeed
	else:
		velocity = input_dir * DashSpeed
	
	

	is_dashing = true
	timer_dash = Time_Dash
	


	
func handle_wall_collision() -> void:
	if  is_dashing and is_on_wall() or is_on_ceiling():
		wall_hit = true
		if wall_hit and not is_cooldown:
			velocity = get_wall_normal() * 400
			end_dash()


func end_dash() -> void:

	
		timercool = Cooldown
		is_cooldown = true
		is_dashing = false
	#endregion
#endregion


func is_enemy_in_range() -> bool:
	if enemy == null: return false
	return global_position.distance_to(enemy.global_position) <= lock_range

func is_dash_toward_enemy() -> bool:
	var to_enemy = (enemy.global_position - global_position).normalized()
	var dot = input_dir.dot(to_enemy)
	return dot > 0.8
