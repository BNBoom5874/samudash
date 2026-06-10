extends BaseEnemy

@onready var hurtbox : Hurtbox = $Hurtbox
@onready var hitbox : Hitbox = $Hitbox

@onready var states_label : Label = $StatesLabel

var target : Node2D = null

#States
enum States { SPAWN, IDLE, CHASE, BREAK, STUN, DEAD }

var current_state = States.SPAWN

@export var bounce_force : float = 100.0
@export var slide_force : float = 50.0
@export var stumble_force : float = 100.0

var speed : float = Speed
var break_power : float = Break_Power
var gravity : float = Nor_Gravity
var stamina : float = 0


var facing_dir : int = 1



func _ready() -> void:
	add_to_group("enemy")
	speed = Speed
	break_power = Break_Power
	gravity = Nor_Gravity
	stamina  = stamina_Max
	change_State(States.SPAWN)

func _physics_process(delta: float) -> void:
	handle_States(delta)
	
	move_and_slide()




#region States

func handle_States(delta: float) -> void:
	
	match current_state:
		States.SPAWN:
			apply_gravity(delta)
			
		States.IDLE:
			apply_gravity(delta)
			_Idle()
		
		States.CHASE:
			hitbox.is_active = true
			apply_gravity(delta)
			_Chase(delta)
			
		States.BREAK:
			apply_gravity(delta)
			_Break()

			
		States.STUN:
			
			apply_gravity(delta)
			velocity.x = lerp(velocity.x, 0.0, friction )
		
		States.DEAD:
			apply_gravity(delta)
			velocity.x = lerp(velocity.x, 0.0, friction * delta)
	




func _Spawn() -> void:
	get_tree().create_timer(reaction).timeout.connect(func() -> void:
		if current_state == States.SPAWN:
			change_State(States.IDLE)
			)
	
	

func _Idle() -> void:
	
	if target == null:
		target = get_tree().get_first_node_in_group("player")
	
	
	if target != null:
		change_State(States.CHASE)

func _Chase(delta) -> void:
	if target == null or current_state == States.STUN:
		return
	
	var dir = sign(target.global_position.x - global_position.x)
	
	if is_on_wall():
		is_stun_wall = true
		change_State(States.STUN)
		return
	
	if facing_dir != dir:
		reaction_state(States.BREAK)
		return
	else:
		velocity.x = lerp(velocity.x, facing_dir * speed, acceleration * delta)
	

	stamina -= delta
	
	if stamina <= 0:
		change_State(States.STUN)



func _Break() -> void:
	velocity.x = move_toward(velocity.x, 0, break_power)
		
	if abs(velocity.x) <1:
		reaction_state(States.CHASE)
		
	if is_on_wall():
		is_stun_wall = true
		change_State(States.STUN)
	elif stamina <= 0:
		change_State(States.STUN)




func stun_wall() -> void:
	# เด้งตรงข้ามกำแพง
	velocity.x = -facing_dir * bounce_force
	velocity.y = -bounce_force * 0.5

func stun_stamina() -> void:
	# สะดุด เด้งขึ้นนิดหน่อย ไหลนิดหน่อย
	
	velocity.x = facing_dir * slide_force
	velocity.y = -stumble_force


#endregion

#region State tool

#change state
func reaction_state(new_state: States) -> void:
	if is_reaction:
		return
	if current_state == States.DEAD:
		return
	
	is_reaction = true
	await get_tree().create_timer(reaction).timeout
	if current_state != States.STUN and current_state != States.DEAD:
		change_State(new_state)
	is_reaction = false


func change_State(new_state: States) -> void:
	#Out
	match current_state:
		States.IDLE:
			pass
		States.STUN:
			if not is_stun_wall :
				if stamina <= 0:
					stamina = stamina_Max
					
			is_stun_wall = false
	
	current_state = new_state
	
	#in
	match current_state:
		States.SPAWN:
			_Spawn()
			hitbox.is_active = false
		
		States.IDLE:
			hitbox.is_active = false
		
		States.CHASE:
			hitbox.is_active = false
			var dir = sign(target.global_position.x - global_position.x)
			facing_dir = dir
		
		States.BREAK:
			hitbox.is_active = false
		
		States.STUN:
			hitbox.is_active = false
			if is_stun_wall:
				stun_wall()
				get_tree().create_timer(stun_wall_time).timeout.connect(func():
					if current_state == States.STUN:
						change_State(States.CHASE))
			else:
				stun_stamina()
				get_tree().create_timer(stun_time).timeout.connect(func():
					if current_state == States.STUN:
						change_State(States.IDLE))
			
		States.DEAD:
			
			stun_stamina()
			Die()
		
	

	states_label.text = str(States.keys()[new_state])




#endregion


#region Custom Func
func apply_gravity( delta) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func _on_hurtbox_die() -> void:
	hitbox.is_active = false
	if current_state != States.DEAD:
		change_State(States.DEAD)
	remove_from_group("enemy")
	print("ตุ๊ยดุ่ย")
