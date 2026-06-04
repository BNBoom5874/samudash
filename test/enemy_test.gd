extends BeseEnemy

@onready var hurtbox : Hurtbox = $Hurtbox



enum State {
	SPAWN,
	HUNT,
	DEAD
}

# ===== SETTINGS =====
@export var speed := 80.0
@export var turn_delay := 1.0
@export var spawn_time := 0.5


# ===== VARIABLES =====
const Gravity : float = 600



var state : State = State.SPAWN

var target : Node2D

var facing_dir := 1
var turn_timer := 0.0


func _ready():
	# หา player จาก group "player"
	target = get_tree().get_first_node_in_group("player")


	# เริ่มสถานะเกิด
	state = State.SPAWN

	# รอ spawn เสร็จก่อนค่อยล่า
	await get_tree().create_timer(spawn_time).timeout

	# ถ้ายังไม่ตาย ให้เริ่มล่า
	if state != State.DEAD:
		state = State.HUNT


func _physics_process(delta):
	
	#if not is_on_floor():
		#velocity.y += Gravity * delta
	
	match state:

		State.SPAWN:
			
			velocity.x = 0
			hunt_player(delta)
			#จากแอนิเมชั่นเล่นเสร็จ  ถ้าทิศแนวนอนที่หันไม่เจอผู้เล่น รอ 1.0 วิให้หันไปอีกทาง ทำเทำเรื่อยๆจนกว่าจะเจอ 
			#ถ้ากัน ซ้ายขวาแล้วไม่เจอ  รออีก 0.5 วิ  เพื่อเงย หน้า  ถ้าเจอ ก็reaction แล้วล่าได้ทันที  การกันจะกลับมาแบบ ไม่ดีเลย์  เว้นซะว่าจะกำหนด

		State.HUNT:
			apply_gravity(delta)
			hunt_player(delta)

		State.DEAD:
			velocity = Vector2.ZERO
			

	move_and_slide()




#region States Functions 


func hunt_player(delta):

	# ถ้าไม่มี player
	if target == null:
		return

	# เช็ค player อยู่ซ้ายหรือขวา
	var dir = sign(target.global_position.x - global_position.x)

	# ===== ระบบหันช้า =====
	# ถ้าต้องหัน และ cooldown หมด
	if dir != 0 and dir != facing_dir and turn_timer <= 0.0:

		facing_dir = dir
		turn_timer = turn_delay

		# กลับด้าน sprite
		scale.x = abs(scale.x) * facing_dir

	# ลดเวลาคูลดาวน์
	if turn_timer > 0.0:
		turn_timer -= delta

	# เดินไปทางที่กำลังหันอยู่
	velocity.x = facing_dir * speed




#endregion


#region Custom Functions 

func apply_gravity(delta) -> void:
	if not is_on_floor() :
		velocity.y += Gravity * delta

#endregion

func _on_hurtbox_die() -> void:
	remove_from_group("enemy")
	Die() #สืบทอดจาก BeseEnemy
	state = State.DEAD
