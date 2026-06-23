extends player_states


func Enter_State() -> void:
	Name = "On wall"

func Exit_State() -> void:
	pass


func Update(delta) -> void:
	if can_input_dir():
		return
	
	if player.on_floor:
		player.change_state(States.Idle)
		return
	
	if player.on_wall:
		player.apply_gravity(delta, player.Wall_Gravity)


func can_input_dir() -> bool:
	
	
	if player._action_dodge():
		player.change_state(States.Dodge)
		return true
	
	elif player._action_dash():
		player.change_state(States.Dash)
		return true
	

	
	return false
	
