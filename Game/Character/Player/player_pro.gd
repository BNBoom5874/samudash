extends CharacterBody2D
class_name Player

#region Variables
@onready var hitbox : Hitbox = $Hitbox
@onready var hurtbox : Hurtbox = $Hurtbox
@onready var States :StatesPlayer = $Statemachine
@onready var collider : CollisionShape2D = $CollisionShape2D
@onready var rayright : RayCast2D = $rayRight
@onready var rayleft : RayCast2D = $rayLeft


#State machine
var previous_state = null
var current_state = null

var on_floor: bool = false
var on_wall : bool = false
var on_air : bool = false


# Lock dash
const CARDINAL_SNAP    : float  = 40.0
const DIAGONAL_DOT_MIN : float= 0.85
const ZONE_DOT_MIN     : float   = 0.6

#สำหรับป้องกันตัวทะลุ
const PLAYER_RADIUS : float = 10.0 #Shape


#movement
const DASH_DISTANCE : float = 100.0
const Gravity : float = 600.0
const Wall_Gravity : float = 400.0
const Dodge_power : float = 500.0
const Jump_power : float = -300.0
const Dash_Speed : float = 100.0
const friction : float = 1200.0

#Direction
var input_dir  : Vector2 = Vector2.ZERO
var dash_dir : Vector2 = Vector2.ZERO
var wall_dir : int = 0 
var dodge_dir : Vector2 = Vector2.ZERO

@export_group("Time")
@export var Cooldown : float = 0.3
@export var Time_Dash : float = 0.22
@export var time_Dodge : float = 0.15
var timer_dash : float   = 0.0
var timercool  : float   = 0.0


#key input
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
	open_hurtbox(true)
	hitbox.is_active = false
	
	for state in States.get_children():
		state.States = States
		state.player = self
		previous_state = States.Idle
		current_state = States.Idle


func _physics_process(delta: float) -> void:
	
	#time
	set_Time(delta)
	
	#input
	get_input()
	handle_Dir_Input()
	handle_context()
	#states Updat
	current_state.Update(delta)
	
	move_and_slide()

#endregion


#region รับ inputต่างๆ รวมถึงทิศทางด้วย
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
	



func handle_Dir_Input() -> void:
	if keyUp:      input_dir = Vector2(0, -1)
	elif keyUpL:   input_dir = Vector2(-1, -1).normalized()
	elif keyUpR:   input_dir = Vector2( 1, -1).normalized()
	elif keyLeft:  input_dir = Vector2(-1,  0)
	elif keyRight: input_dir = Vector2( 1,  0)
	elif keyDown:  input_dir = Vector2(0,   1)
	elif keyDownL: input_dir = Vector2(-1,  1).normalized()
	elif keyDownR: input_dir = Vector2( 1,  1).normalized()
	else:          input_dir = Vector2.ZERO




#endregion

#region Helpers

func apply_gravity(delta, gravity : float = Gravity) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func set_Time(delta) -> void:
	if timer_dash > 0:
		timer_dash -= delta
	
	if timercool  > 0: timercool  -= delta


func get_center_of(node: Node) -> Vector2:
	var target_hurtbox = node.get_node_or_null("Hurtbox")
	if target_hurtbox:
		return target_hurtbox.global_position
	return node.global_position

func open_hurtbox(value :bool) -> void:
	if not is_instance_valid(hurtbox):
		return
	
	hurtbox.is_active = value

func handle_context() -> void:
	on_floor = is_on_floor()

	if rayleft.is_colliding():
		wall_dir = -1
		on_wall = true
		return
	
	elif rayright.is_colliding():
		wall_dir = 1
		on_wall = true
		return
	
	wall_dir = 0
	on_wall = false


func _action_dash() -> bool:
	if input_dir == Vector2.ZERO: return false
	if timercool > 0: return false
	
	if on_floor:
		if on_wall and sign(input_dir.x) != wall_dir:
			dash_dir = input_dir
			return true
			
		else:
			if not sign(input_dir.y) > 0:
				dash_dir = input_dir
				return true
	else:
		if on_wall and sign(input_dir.x) != wall_dir:
			dash_dir = input_dir
			return true
		else :
			dash_dir = input_dir
			return true
			
	return false


func _action_jump() -> bool:
	if input_dir == Vector2.ZERO:
		return false
	if on_floor and input_dir == Vector2.DOWN:
		return true
	return false


func _action_dodge() -> bool:
	if input_dir == Vector2.ZERO:
		return false
	
	if on_floor:
		# wall kick — กดทิศไหนก็ได้ที่มี x component ตอนติดกำแพง
		if on_wall and sign(input_dir.x) == wall_dir:
			dodge_dir.x = -wall_dir
			dodge_dir.y = -1 if sign(input_dir.y) == 1 else 0
			return true
		# floor bounce — เฉียงลงโดยไม่ติดกำแพง
		if input_dir.y > 0 and sign(input_dir.x) != 0:
			dodge_dir = Vector2(sign(input_dir.x), 0)
			return true
	else :
		if on_wall and sign(input_dir.x) == wall_dir:
			dodge_dir.x = -wall_dir
			if sign(input_dir.y) == 1:
				dodge_dir.y = -1
				return true
			elif sign(input_dir.y) == -1:
				dodge_dir.y = 1
				return true
			else:
				dodge_dir.y = 0
				return true
			
		
	return false
#endregion

#region Dash


func start_dash() -> void:
	
	var target = find_nearest_in_direction(dash_dir)
	
	if target != null and can_lock_on(target, dash_dir):
		do_lock_dash(target)
	else:
		do_normal_dash(dash_dir)

##หาศัตรูที่ใกล้ที่สุดในทิศที่กด
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

##ตรวจcollision โดน free รึยัง
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


func do_normal_dash(dir: Vector2) -> void:
	var result = get_safe_dash_position(dir, DASH_DISTANCE)
	global_position = result.position
	velocity = Vector2.ZERO if result.hit else dir.normalized() * 150.0
	timer_dash = Time_Dash


func do_lock_dash(target: Node) -> void:
	var enemy_center = get_center_of(target)
	var diff = enemy_center - global_position
	
	if diff.length() > DASH_DISTANCE:
		do_normal_dash(input_dir)
		return

	# dash ไปหาศัตรู แต่หยุดก่อนถึง (ห่าง PLAYER_RADIUS)
	var dir = diff.normalized()
	var stop_dist = max(diff.length() - PLAYER_RADIUS, 0.0)
	
	var result = get_safe_dash_position(dir, stop_dist)
	global_position = result.position
	velocity = dir * 150.0
	timer_dash = Time_Dash

##ตรวจจับกำแพง
## ตรวจจับกำแพงและหาสิ่งกีดขวางก่อนวาร์ปพุ่ง (แบบยิงร่างเงาเช็ครวดเดียว)
func get_safe_dash_position(dir: Vector2, distance: float) -> Dictionary:
	var motion = dir.normalized() * distance
	var collision = KinematicCollision2D.new()
	
	# test_move จะยิง "ร่างเงา" (Shape ของตัวละคร) พุ่งพรวดเดียวไปตามระยะ motion
	# ถ้าชนอะไรระหว่างทาง มันจะส่งค่า true และเก็บข้อมูลการชนไว้ในตัวแปร collision
	if test_move(global_transform, motion, collision):
		# collision.get_travel() จะคืนค่าเวกเตอร์ระยะทางที่ปลอดภัยที่สุดก่อนที่จะมิดกำแพง
		var safe_travel = collision.get_travel()
		
		return {
			"position": global_position + safe_travel,
			"hit": true
		}
	else:
		# ถ้าทางสะดวก ไม่ติดกำแพง ก็วาร์ปไปให้สุดระยะทาง
		return {
			"position": global_position + motion,
			"hit": false
		}


#endregion


#region State tool

func change_state(new_state) -> void: 
	if current_state == States.Dead: return
	if new_state != null:
		previous_state = current_state
		current_state = new_state
		
		previous_state.Exit_State()
		current_state.Enter_State()
		
		print_rich("[color=orange]Change "+
		"[b]"+ previous_state.Name +"[/b]"+ 
		" to: " + "[b][i]"+ current_state.Name +"[/i][/b][/color]")
		


#endregion


#region Signals

func _on_hurtbox_die() -> void:
	print("โดนนนนน")
	open_hurtbox(false)
	queue_free()
	remove_from_group("player")

func _on_hitbox_hit() -> void:
	timercool = 0
	if current_state == States.Dash:
		States.Dash.is_hit_enemy = true
	


func _on_hurtbox_hurt() -> void:
	pass
#endregion
