extends Node
class_name PlayerStatus

@export var player: CharacterBody2D = get_parent()
@export var collision_area: Area2D = get_parent()
@onready var invencibility_timer: Timer = $InvencibilityTimer

var shielding: bool = false
var base_life: int = 15
var base_mana: int = 10
var base_attack: int = 1
var base_magic_attack: int = 3
var base_defense: int = 1

var bonus_life: int = 0
var bonus_mana: int = 0
var bonus_attack: int = 0
var bonus_magic_attack: int = 0
var bonus_defense: int = 0

var curr_life: int
var curr_mana: int

var max_mana: int
var max_life: int

var curr_exp: int = 0

var level: int = 1
var level_dict: Dictionary = {
	"1": 25,
	"2": 33,
	"3": 49,
	"5": 66,
	"6": 93,
	"7": 135,
	"8": 186,
	"9": 251,
	"10": 356,
	"11": 551
}

func _ready() -> void:
	curr_mana = base_mana + bonus_mana
	max_mana = curr_mana
	
	curr_life = base_life + bonus_life
	max_life = curr_life

func update_exp(value: int) -> void:
	curr_exp += value
	var key: String = str(level)
	if curr_exp >= level_dict[key] and level < 11:
		var leftover: int = curr_exp - level_dict[key]
		curr_exp = leftover
		level += 1
	elif curr_exp >= level_dict[key] and level == level_dict.keys[-1]:
		curr_exp = level_dict[key]

func on_lvl_up() -> void:
	curr_mana = base_mana + bonus_mana
	curr_life = base_life + bonus_life
	
func update_life(type: String, value: int) -> void:
	match type:
		"Increase":
			curr_life += value
			if curr_life >= max_life:
				curr_life = max_life
		"Decrease":
			verify_shield(value)
			if curr_life <= 0:
				player.dead = true
			else:
				player.on_hit = true
				player.attacking = false
			print(player.dead)

func verify_shield(value: int) -> void:
	if shielding:
		if (base_defense + bonus_defense) >= value:
			return

		var damage: int = abs((base_defense + bonus_defense) - value)
		curr_life -= damage
	else:
		curr_life -= value
	
func update_mana(type: String, value: int) -> void:
	match type:
		"Increase":
			curr_mana += value
			if curr_mana >= max_mana:
				curr_mana = max_mana
		"Decrease":
			curr_mana -= value


#func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("mv_up"):
	#	update_life("Decrease", 5)


func on_colision_hit_area_entered(area: Area2D) -> void:
	if area.name == "EnemyAttackArea":
		update_life("Decrease", area.damage)
		collision_area.set_deferred("Monitoring", false)
		invencibility_timer.start(area.invencibility_timer)

func on_invencibility_timer_timeout() -> void:
	collision_area.set_deferred("Monitoring", true)
