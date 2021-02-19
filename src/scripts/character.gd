extends Area2D

signal destroyed


enum Behaviours {
	NONE,
	IA,
}

export(PackedScene) var bullet
export(float) var shot_cooldown = 1.0
export(bool) var shooting_up = true
export(int) var faction = 0
export(float) var speed = 1.0
export(int) var health = 1
export(float) var critical_chance = 3.0
var behaviour = Behaviours.NONE setget set_behaviour
var movement: Vector2 = Vector2.ZERO


func _ready():
	$Cooldown.start(shot_cooldown)
	$Sprite.self_modulate = Color(randf(),randf(),randf())
	$Tween.interpolate_property($Sprite, "self_modulate", Color.white, $Sprite.self_modulate, 0.5)


func _physics_process(_delta):
	match behaviour:
		Behaviours.NONE:
			position.x += movement.x * (speed * 5)
		Behaviours.IA:
			position.x += movement.x * (speed * 1)
			position.y += 1 * (speed / 10.0)
			shoot()
	position = Vector2(clamp(position.x, 0, Globals.screen_size.x), clamp(position.y, 0, Globals.screen_size.y))


func shoot():
	if $Cooldown.is_stopped():
		$Cooldown.start(shot_cooldown)
		var shot = bullet.instance()
		shot.faction = self.faction
		shot.shooter = self
		shot.critical_chance = critical_chance
		shot.position = $ShotPosition.global_position
		shot.speed = -shot.speed if shooting_up else shot.speed
		get_parent().add_child(shot)


func critical_shot():
	if $Cooldown.is_stopped():
		$Cooldown.start(shot_cooldown)
		var shot = bullet.instance()
		shot.faction = self.faction
		shot.shooter = self
		shot.critical_chance = 100.0
		shot.position = $ShotPosition.global_position
		shot.speed = -shot.speed if shooting_up else shot.speed
		get_parent().add_child(shot)


func get_shot(damage):
	health -= damage
	if health <= 0:
		emit_signal("destroyed", self)
		queue_free()
	else:
		$Tween.start()


func ai_change_movement():
	if position.x < 70:
		movement.x = 1
	elif position.x > 650:
		movement.x = -1
	else:
		movement.x = sign((randi() % 10 + 1) - 5)
	get_node("Timer").start((randi() % 2) + randf())


func set_behaviour(value):
	if value == Behaviours.IA:
		var timer = Timer.new()
		timer.connect("timeout", self, "ai_change_movement")
		add_child(timer)
		timer.name = "Timer"
		timer.one_shot = true
		timer.autostart = true
	behaviour = value
