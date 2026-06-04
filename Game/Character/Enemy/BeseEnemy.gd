class_name BeseEnemy
extends CharacterBody2D


signal die

@export var hp : int = 1
@export var damage : int = 1



func take_damage(amount) -> void:
	hp -= amount 
	
	if hp <= 0:
		Die()


func Die() -> void:
	die.emit()
	await get_tree().create_timer(1.0).timeout
	queue_free()
