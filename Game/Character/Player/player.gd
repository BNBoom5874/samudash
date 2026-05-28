extends CharacterBody2D


const DashSpeed : float = 1200.0
const Gravity : float = 600.0

var dashspeed  = DashSpeed

var gravity = Gravity


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

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	
	get_input()
	
	Dash()
	
	apply_gravity(delta)
	
	move_and_slide()
	
	



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


func apply_gravity(delta) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func Dash() -> void:
	#Up
	if keyUp : velocity = Vector2(0,-1) * DashSpeed
	if keyUpL : velocity = Vector2(-1, -1).normalized() * DashSpeed
	if keyUpR : velocity = Vector2(1, -1).normalized() * DashSpeed
	#horizon
	if keyLeft :  velocity = Vector2(-1, 0) * DashSpeed
	if keyRight : velocity = Vector2(1, 0) * DashSpeed
	#Down
	if keyDown : velocity = Vector2(0, 1) * DashSpeed
	if keyDownL : velocity = Vector2(-1, 1).normalized() * DashSpeed
	if keyDownR : velocity = Vector2(1, 1).normalized() * DashSpeed
