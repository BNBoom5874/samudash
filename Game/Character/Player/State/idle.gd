extends player_states


var is_action : bool  = false

var timer : float = 0.0


func Enter_State() -> void:
	is_action = false
	Name = "Idle"
	

func Exit_State() -> void:
	pass


func Update(delta : float) -> void:
	if can_input_dir():
		is_action = true
		return 
		
	if player.on_wall:
		player.velocity.x = 0
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, 20)
	
	
	
	player.apply_gravity(delta)


	
	
	if not player.on_floor and player.velocity.y > 0:
		player.change_state(States.Fall)





func can_input_dir() -> bool:
	if is_action:
		return true
	
	
	if player._action_dodge():
		player.change_state(States.Dodge)
		return true
	
	elif player._action_dash():
		player.change_state(States.Dash)
		return true
	
	elif player._action_jump():
		player.change_state(States.Jump)
		return true
	
	return false
	
