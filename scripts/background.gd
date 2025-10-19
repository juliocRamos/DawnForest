extends ParallaxBackground
class_name Background

@export var can_proc: bool
@export var layer_speed: Array[float]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if can_proc == false:
		set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for idx in get_child_count():
		var node = get_child(idx)
		if node is ParallaxLayer:
			node.motion_offset.x -= delta * layer_speed[idx]
