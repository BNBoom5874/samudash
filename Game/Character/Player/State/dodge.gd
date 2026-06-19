#DODGE
extends player_states

var is_dodge : bool = false

func Enter_State() -> void:
	is_dodge = false
	Name = "Dodge"
	
	player.velocity =  player.Dodge_power * player.dodge_dir


func Exit_State() -> void:
	pass

func Update(delta) -> void:
	
	player.velocity = player.velocity.move_toward(Vector2.ZERO, 1200.0 * delta)
	player.apply_gravity(delta)
	
	
	if player.velocity.x < 10:
		if player.is_on_floor():
			player.change_state(States.Idle)
		else :
			if player.velocity.y > 0:
				player.change_state(States.Fall)
			elif player.on_wall:
				player.change_state(States.On_Wall)
			
			
			
