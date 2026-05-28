extends CharacterBody2D


const DashSpeed : float = 1200.0
const Gravity : float = 600.0

var dashspeed  = DashSpeed
var gravity = Gravity

#time
const Cooldown : float = 0.4
const Time_Dash : float = 0.1


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

#region Loop function 

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	
	set_Time(delta)
	
	get_input()
	
	handle_Dash()
	
	
	apply_gravity(delta)
	
	
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


func handle_Dash() -> void:
	
	if is_dashing or is_cooldown: return
		#Up
	if keyUp :
		velocity = Vector2(0,-1) * DashSpeed
	
		
	if keyUpL :
		velocity = Vector2(-1, -1).normalized() * DashSpeed
	
		
	if keyUpR :
		velocity = Vector2(1, -1).normalized() * DashSpeed
	
	#horizon
	if keyLeft :
		velocity = Vector2(-1, 0) * DashSpeed
		
	if keyRight :
		velocity = Vector2(1, 0) * DashSpeed
		
	#Down
	if keyDown :
		velocity = Vector2(0, 1) * DashSpeed
		
	if keyDownL :
		velocity = Vector2(-1, 1).normalized() * DashSpeed
		
	if keyDownR :
		velocity = Vector2(1, 1).normalized() * DashSpeed
	
	if keyUp or keyRight or keyLeft or keyDown or keyDownL or keyDownR or keyUpL or keyUpR:
		is_dashing = true
		timer_dash = Time_Dash
	
	
	if Cooldown:
		velocity.x = move_toward(velocity.x, 0, 20)


func set_Time(delta) -> void:
 
	
	
	if timer_dash > 0:
		timer_dash -= delta
	else:
		timer_dash = 0.0
		if is_dashing:
			is_cooldown = true
			timercool = Cooldown
			is_dashing = false
	
	if timercool > 0:
		timercool -= delta
	else:
		timercool = 0.0
		if is_cooldown:
			is_cooldown = false
			wall_hit = false
		
		


func handle_wall_collision() -> void:
	if  is_dashing and is_on_wall() or is_on_ceiling():
		velocity.x = 0
		wall_hit = true
		end_dash()


func end_dash() -> void:
	if wall_hit and not is_cooldown:
		velocity = get_wall_normal() * 400
		timercool = Cooldown
		is_cooldown = true
		is_dashing = false
