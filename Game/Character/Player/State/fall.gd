extends player_states


func Enter_State() -> void:
	Name = "Fall"


func Exit_State() -> void:
	pass


func Update(delta) -> void:
	
	if can_input(): return
	
	player.apply_gravity(delta)
	
	if player.is_on_floor():
		player.change_state(States.Idle)

func can_input() -> bool:

	if player.input_dir == Vector2.ZERO:
		return false
	
	if player.input_dir == Vector2.DOWN:
		player.change_state(States.Jump)
	
	elif player.input_dir.y > 0 and player.input_dir.x != 0:
		player.change_state(States.Dodge)  # เฉียงลงเสมอ
		
	elif player.is_on_wall():
		var toward = -player.get_wall_normal()
		if player.input_dir.dot(toward) > 0:
			player.change_state(States.Dodge)  # เข้ากำแพง → dodge
		else:
			if player.timercool > 0:
				return false
			player.change_state(States.Dash)   # ออกกำแพง → dash
			
	else:
		if player.timercool > 0:
			return false
		player.change_state(States.Dash)
	
	return true
