extends player_states

var is_hit_enemy : bool = false
var collision


func Enter_State() -> void:
	Name = "Dash"
	is_hit_enemy = false
	
	player.start_dash()
	


func Exit_State() -> void:
	player.hitbox.is_active = false

	if not is_hit_enemy:
		player.timercool = player.Cooldown





func Update(delta) -> void:
	if player.on_wall and not player.on_floor:
		if player.dash_dir != Vector2.UP:
			player.velocity.y = 0
			player.change_state(States.On_Wall)
			return
	
	if is_hit_enemy and player._action_dash():
		player.change_state(States.Dash)
		return
	
	
	Break(delta)

	if player.timer_dash <= 0 or is_hit_enemy:
		if player.is_on_floor():
			player.change_state(States.Idle)
			return
		else:
			player.change_state(States.Fall)
			return
	
	if is_hit_enemy: 
		return

	

func Break(delta) -> void:
	if is_hit_enemy or player.on_floor:
		player.velocity = player.velocity.move_toward(
			Vector2.ZERO, player.friction * delta
	)
	
	else: 
		player.velocity = player.velocity.move_toward(
		Vector2.ZERO, (player.friction / 4) * delta )	
	
	player.apply_gravity(delta, player.Gravity * 2) if sign(player.dash_dir.y) > 0 else 0.2 
