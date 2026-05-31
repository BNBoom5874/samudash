extends CharacterBody2D

const Speed : float = 200
const Gravity : float = 600

#time
const IDLETime : float = 1.5
var idletimer : float = 0.0

var chase : bool = false
var alert : bool = false
var start : bool = false


var states = States.IDLE

enum States {
	IDLE, Alerts, CHASE, DEAD
}





func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	time_set(delta)
	
	
	apply_gravity(delta)
	
	match states:
		States.IDLE:
			idle()
		
		States.Alerts:
			Alert()
	
	
	move_and_slide()


func apply_gravity(delta) -> void:
	if not  is_on_floor():
		velocity.y += Gravity * delta




#region STATES

func idle() -> void:
	if alert: 
		states = States.Alerts
		return
	
	
	velocity.x = 0
	
	if not start:
		idletimer = IDLETime
		start = true
	
	
	if idletimer <= 0:
		alert = true


func Alert() -> void:
	if alert:
		velocity.y = -100
		alert = false
	
	if not alert:
		if is_on_floor():
			pass
			#states = States.CHASE
		
#endregion





func time_set(delta) -> void:
	if idletimer > 0:
		idletimer -= delta
