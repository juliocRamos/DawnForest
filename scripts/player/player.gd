extends CharacterBody2D
class_name PlayerBody

var jump_count: int = 0

# player actions
var landing: bool = false
var attacking: bool = false
var defending: bool = false
var crouching: bool = false

var can_track_input: bool = true

@export var SPEED : int = 75
@export var JUMP_VELOCITY : int = -300
@export var JUMP_FACTOR : float = .80
@onready var player_sprite: Sprite2D = $Sprite2D

func _physics_process(delta: float) -> void:	
	vertical_movement_env(delta)
	horizontal_movement_env()
	actions_env()
	
	gravity(delta)
	player_sprite.animate(velocity)

func actions_env() -> void:
	attack()
	crouch()
	defend()

func attack() -> void:
	var attack_condition: bool = not attacking and not crouching \
		and not defending
	if Input.is_action_pressed("attack") and attack_condition \
		and is_on_floor():
			attacking = true
			player_sprite.normal_attack = true
			

func crouch() -> void:
	if Input.is_action_pressed("crouch") and is_on_floor() \
		and not defending:
			crouching = true
			defending = false
			can_track_input = false
	elif not defending:
		crouching = false
		can_track_input = true
		player_sprite.crouching_off = true

func defend() -> void:
	if Input.is_action_pressed("defend") and is_on_floor() \
		and not crouching:
			defending = true
			can_track_input = false
	elif not crouching:
		defending = false
		can_track_input = true
		player_sprite.shield_off = true


func vertical_movement_env(_delta: float) -> void:
	if is_on_floor():
		jump_count = 0
	
	var can_jump: bool = can_track_input and not attacking
	if Input.is_action_just_pressed("mv_up") and jump_count < 2 and can_jump:
		jump_count += 1
		var jump_strength : float = JUMP_VELOCITY
		if jump_count == 2:
			jump_strength *= JUMP_FACTOR
		
		velocity.y = jump_strength

func horizontal_movement_env() -> void:
	var direction := Input.get_action_strength("mv_right") \
		- Input.get_action_strength("mv_left")
	if can_track_input == false or attacking:
		velocity.x = 0
		return

	velocity.x = direction * SPEED
	move_and_slide()
	player_sprite.animate(velocity)

func gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	else:
		velocity.y = 0
