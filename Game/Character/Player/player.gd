extends CharacterBody2D


const DashSpeed : float = 600.0
const Gravity : float = 300.0



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
