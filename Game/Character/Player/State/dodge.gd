#DODGE
extends player_states





func Enter_State() -> void:
	

	Name = "Dodge"
	
	player.hurtbox.is_active = false
	player.velocity =  player.Dodge_power * player.dodge_dir


func Exit_State() -> void:
	pass
func Update(delta) -> void:

	
	if can_action():
		return
	
	
	player.velocity = player.velocity.move_toward(Vector2.ZERO, 1000.0 * delta)
	player.apply_gravity(delta)
	
	
	if abs(player.velocity.x) < 20:
		if player.is_on_floor():
			player.change_state(States.Idle)
		else :
			if player.velocity.y > 0:
				player.change_state(States.Fall)
			elif player.on_wall:
				player.change_state(States.On_Wall)
			
			

func can_action() -> bool:



	if player._action_dash():
		player.change_state(States.Dash)
		return true
	
	elif player._action_jump():
		player.change_state(States.Jump)
		return true
	
	return false
