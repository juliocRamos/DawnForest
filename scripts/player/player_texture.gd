extends Sprite2D
class_name PlayerTexture

var normal_attack: bool = true
var suffix: String = "_right"
var shield_off: bool = false
var crouching_off: bool = false

var anim_locked: bool = false

@export var animation: AnimationPlayer = get_parent()
@export var player: PlayerBody = get_parent()

func animate(direction: Vector2) -> void:
	if anim_locked:
		return # doesn't change until animation has finished.
	
	verify_position(direction)
	
	if player.attacking or player.defending or player.crouching:
		action_behavior()
	elif direction.y != 0:
		vertical_behavior(direction)
	elif player.landing == true:
		landing_behavior()
	else:
		horizontal_behavior(direction)

func action_behavior() -> void:
	if player.attacking and normal_attack:
		animation.play("attack" + suffix)
	elif player.defending and shield_off:
		animation.play("shield")
		shield_off = false
	elif player.crouching and crouching_off:
		animation.play("crouch")
		crouching_off = false

func verify_position(direction: Vector2) -> void:
	if direction.x > 0:
		flip_h = false
		suffix = "_right"
	elif direction.x < 0:
		flip_h = true
		suffix = "_left"

func landing_behavior() -> void:
	if animation.current_animation != "landing":
		anim_locked = true
		animation.play("landing")

func vertical_behavior(direction: Vector2) -> void:
	if direction.y > 0:
		player.landing = true
		animation.play("fall")
	elif direction.y < 0:
		animation.play("jump")

func horizontal_behavior(direction: Vector2) -> void:
	if direction.x != 0:
		animation.play("run")
	else:
		animation.play("idle")

func on_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"landing":
			player.landing = false
			anim_locked = false
		"attack_left":
			player.attacking = false
			normal_attack = false
		"attack_right":
			player.attacking = false
			normal_attack = false
