extends player_states

var timer : float = 0.0


func Enter_State() -> void:
	Name = "Jump"
	
	player.hurtbox.is_active = true
	
	player.velocity.y = player.Jump_power


func Exit_State() -> void:
	pass


func Update(delta) -> void:
	
	if can_input_dir():
		return
	
	player.apply_gravity(delta)
		

	
	if player.velocity.y > 0:
		player.change_state(States.Fall)


func can_input_dir() -> bool:
	if player.input_dir == Vector2.ZERO: return false
	
	if player._action_dash():
		player.change_state(States.Dash)
		return true

	return false
	
