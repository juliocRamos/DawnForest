extends CharacterBody2D
class_name Player

var body_direction: int = 1
var jump_count: int = 0

# player actions
var landing: bool = false
var attacking: bool = false
var defending: bool = false
var crouching: bool = false

# wall slide
var not_on_wall: bool = true # achei isso curioso, talvez apenas negar o on_wall seja o suficiente

var can_track_input: bool = true

@export var SPEED: int = 75
@export var JUMP_VELOCITY: int = -300
@export var JUMP_FACTOR: float = .80
@export var WALL_GRAVITY: int = 115
@export var WALL_IMPULSE_SPEED: int = 500
@export var WALL_JUMP_SPEED: int = -150

@onready var player_sprite: Sprite2D = $PlayerTexture
@onready var wall_ray: RayCast2D = $WallRay


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
	var attack_condition: bool = not attacking and not crouching and not defending
	if Input.is_action_pressed("attack") and attack_condition and is_on_floor():
		attacking = true
		player_sprite.normal_attack = true


func crouch() -> void:
	if Input.is_action_pressed("crouch") and is_on_floor() and not defending:
		crouching = true
		defending = false
		can_track_input = false
	elif not defending:
		crouching = false
		can_track_input = true
		player_sprite.crouching_off = true


func defend() -> void:
	if Input.is_action_pressed("defend") and is_on_floor() and not crouching:
		defending = true
		can_track_input = false
	elif not crouching:
		defending = false
		can_track_input = true
		player_sprite.shield_off = true


func vertical_movement_env(_delta: float) -> void:
	if is_on_floor() or is_on_wall():
		jump_count = 0

	var can_jump: bool = can_track_input and not attacking
	if Input.is_action_just_pressed("mv_up") and jump_count < 2 and can_jump:
		jump_count += 1
		if next_to_wall() and not is_on_floor():
			velocity.y = WALL_JUMP_SPEED
			velocity.x += WALL_IMPULSE_SPEED * body_direction
			move_and_slide()
		else:
			var jump_strength: float = JUMP_VELOCITY
			if jump_count == 2:
				jump_strength *= JUMP_FACTOR

			velocity.y = jump_strength
		print(velocity)


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
	if next_to_wall():
		velocity.y += WALL_GRAVITY * delta
		if velocity.y >= WALL_GRAVITY:
			velocity.y = WALL_GRAVITY
	else:
		if not is_on_floor():
			velocity.y += get_gravity().y * delta
		else:
			velocity.y = 0


func next_to_wall() -> bool:
	if wall_ray.is_colliding() and not is_on_floor():
		if not_on_wall:
			velocity.y = 0
			not_on_wall = false
		return true
	else:
		not_on_wall = true
		return false
