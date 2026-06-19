extends player_states

var is_hit_enemy : bool = false
var collision

func Enter_State() -> void:
	Name = "Dash"
	is_hit_enemy = false
	collision = player.move_and_collide(player.input_dir * player.DASH_DISTANCE)
	player.velocity = player.Dash_Speed * player.input_dir
	
func Exit_State() -> void:
	if not is_hit_enemy:
		player.timercool = player.Cooldown


func Update(delta) -> void:
	if collision:
		player.velocity = player.velocity.move_toward(Vector2.ZERO, player.friction * player.Dash_Speed * delta)
	
	
	if player.timer_dash <= 0:
		if player.is_on_floor():
			player.change_state(States.Idle)
			return
		elif player.is_on_wall_only():
			player.change_state(States.On_Wall)
			return
		else:
			player.change_state(States.Fall)
			return
	
