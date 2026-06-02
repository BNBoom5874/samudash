extends CharacterBody2D

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
		state = State.SPAWN


func _physics_process(delta):
	
	#if not is_on_floor():
		#velocity.y += Gravity * delta
	
	match state:

		State.SPAWN:
			velocity.x = 0

		State.HUNT:
			hunt_player(delta)

		State.DEAD:
			velocity = Vector2.ZERO

	move_and_slide()


func hunt_player(delta):

	# ถ้าไม่มี player
	if target == null:
		velocity = Vector2.ZERO
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
	velocity.y = 0


func die():

	# กันเรียกซ้ำ
	if state == State.DEAD:
		return
		

	state = State.DEAD

	velocity = Vector2.ZERO

	# ปิดการชน
	hurtbox.is_invisible = true

	# ลบตัวเองหลัง 1 วิ
	await get_tree().create_timer(1.0).timeout

	queue_free()


func _on_hurtbox_die() -> void:
	
	print("im dead")
	die()
