extends player_states

#dodge ✓
#jump ✓
#dash ✓
#Fall ✓

var timer : float = 0.0


func Enter_State() -> void:
	Name = "Idle"


func Exit_State() -> void:
	pass


func Update(delta : float) -> void:
	
	if can_input() : return
	
	player.apply_gravity(delta)

	player.velocity.x = move_toward(player.velocity.x, 0, 20)
	
	
	if not player.is_on_floor() and player.velocity.y > 0:
		player.change_state(States.Fall)





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
