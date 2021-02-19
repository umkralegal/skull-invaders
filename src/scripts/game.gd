extends Node2D
# Gameplay.


enum LevelStates {
	LEVEL_START,
	LEVEL_COMPLETE,
	LEVEL_PROCESS,
	GAME_OVER,
}

const SKULL = preload("res://src/data/characters/skull.tscn")
const TANK = preload("res://src/data/characters/tank.tscn")

var level_state = LevelStates.LEVEL_START
var game_level = 1
var enemies = []


func _ready():
	randomize()
	var player = TANK.instance()
	player.connect("destroyed", self, "game_over")
	player.position = $Spawn.position
	add_child(player)
	PlayerController.player1 = player
	$Label.text = "LEVEL %d" % game_level
	$Label.show()
	$Timer.start(3)


func generate_enemies():
	for x in game_level:
		spawn_enemy()


func spawn_enemy():
	var enemy = SKULL.instance()
	enemy.connect("destroyed", self, "remove_enemy",[enemy])
	enemies.append(enemy)
	enemy.add_to_group("is:enemy")
	enemy.shot_cooldown = (randf() * 5.0) + 5.0
	var rand_pos = Vector2(randi() % 700 + 30, randi() % 150 + 30)
	enemy.position = rand_pos
	enemy.behaviour = enemy.Behaviours.IA
	add_child(enemy)


func new_level():
	generate_enemies()


func remove_enemy(enemy):
	enemies.erase(enemy)
	update_game()


func level_up():
	get_tree().call_group("is:bullet", "queue_free")
	if not enemies.empty():
		for enemy in enemies:
			enemy.queue_free()
	game_level += 1
	$Label.show()
	$Timer.start(0.1)
	level_state = LevelStates.LEVEL_PROCESS
	$Label.text = "LEVEL %d" % game_level


func update_game():
	if enemies.empty():
		level_up()


func game_over():
	get_tree().call_group("is:enemy", "queue_free")
	enemies = []
	get_tree().call_group("is:bullet", "queue_free")
	$Label.text = "GAME OVER"
	$Label.show()
	$Timer.start(4)
	level_state = LevelStates.GAME_OVER


func _on_Timer_timeout():
	match level_state:
		LevelStates.LEVEL_START:
			$Label.hide()
			new_level()

		LevelStates.LEVEL_PROCESS:
			if PlayerController.player1:
				level_state = LevelStates.LEVEL_COMPLETE
				$Timer.start(2)
			else:
				game_over()

		LevelStates.LEVEL_COMPLETE:
			$Label.hide()
			level_state = LevelStates.LEVEL_START
			new_level()

		LevelStates.GAME_OVER:
			SceneManager.goto_scene("res://src/scenes/menu.tscn")
