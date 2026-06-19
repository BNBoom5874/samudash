extends player_states


func Enter_State() -> void:
	Name = "Fall"


func Exit_State() -> void:
	pass


func Update(delta) -> void:
	
	player.apply_gravity(delta)
	
	if player.is_on_floor():
		player.change_state(States.Idle)
