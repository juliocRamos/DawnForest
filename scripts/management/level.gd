extends Node2D
class_name Level

@onready var player: CharacterBody2D = $Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.get_node("PlayerTexture").game_over.connect(
		Callable(self, "_on_game_over")
	)
	
func _on_game_over() -> void:
	get_tree().reload_current_scene()
