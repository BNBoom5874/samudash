extends Label


@export var wave_manager : WaveManager


func _ready() -> void:
	wave_manager.score_change.connect(func(s): text = str(s))
