class_name BaseEnemy
extends CharacterBody2D


signal die

@export var hp : int = 1
@export var damage : int = 1

@export var Speed : float = 200.0
@export var acceleration: float = 4.0
@export var friction: float = 5.0
@export var Break_Power : float = 20.0
@export var Nor_Gravity: float = 600.0

#time 
@export var reaction: float = 0.8
@export var stamina_Max: float = 20.0
@export var stun_time : float = 3.0
@export var spawn_time : float = 2.0
@export var stun_wall_time : float = 2.0

var reaction_id := 0







var is_stun_wall : bool = false
var is_reaction : bool = false

func take_damage(amount) -> void:
	hp -= amount 
	
	if hp <= 0:
		Die()






#Signal

func Die() -> void:
	die.emit()
	await get_tree().create_timer(1.0).timeout
	queue_free()
