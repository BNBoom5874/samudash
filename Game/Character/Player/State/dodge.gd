#DODGE
extends player_states



var dodge_dir : Vector2 = Vector2.ZERO

func Enter_State() -> void:
	Name = "Dodge"
	set_dodge()
	


func Exit_State() -> void:
	pass


func Update(delta) -> void:
	player.velocity = player.velocity.move_toward(Vector2.ZERO, 800.0 * delta)
	
	
	if player.is_on_wall() and not player.is_on_floor():
		player.change_state(States.On_Wall)
		return
	
	
	
	if player.velocity.length() < 20:
		if player.is_on_floor():
			player.change_state(States.Idle)
			return
		else:
			player.change_state(States.Fall)
			return
			



func set_dodge() -> void:

	if player.is_on_wall():
		var wall_normal = player.get_wall_normal()
		
		#ถ้าอยู่บนพื้น + กดเฉียงขึ้นหากำแพง = พุ่งทิศแนวนอนตามปกติ
		if player.is_on_floor() and player.input_dir.y < 0:
			dodge_dir = wall_normal
			
		
		#ถ้าไม่ได้อยู่บนพื้นแล้วยังเกาะกำแพง
		#ถ้ากดเฉียงลง = เฉียงขึ้นในทิศตรงข้าม
		elif player.input_dir.y > 0:
			dodge_dir = Vector2(wall_normal.x,-1).normalized()
		
		#ถ้ากดเฉียงขึ้น = เฉียงลงในทิศตรงข้าม
		elif player.input_dir.y < 0:
			dodge_dir = Vector2(wall_normal.x,1).normalized()
		
		else:
			dodge_dir = wall_normal
	elif player.is_on_floor_only():
		dodge_dir = Vector2(player.input_dir.x, 0)
	
	player.velocity = dodge_dir * player.Dodge_power
