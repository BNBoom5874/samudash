extends player_states



func Enter_State() -> void:
	Name = "Fall"
	player.hurtbox.is_active = true
	

func Exit_State() -> void:
	pass


func Update(delta) -> void:
	if can_input_dir():
		return


	player.apply_gravity(delta)
	
	if player.is_on_floor():
		player.change_state(States.Idle)
		return
	else:
		if player.on_wall:
			player.change_state(States.On_Wall)



func can_input_dir() -> bool:
	if player.input_dir == Vector2.ZERO: return false
	
	if player._action_dash():
		player.change_state(States.Dash)
		return true

	return false
	
