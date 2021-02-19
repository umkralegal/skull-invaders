extends Area2D


enum ShotType {
	NORMAL,
	CRITICAL,
}


export(int) var speed = 10
export(int) var damage = 1
var shooter
var faction: int = 0
var critical_chance = 0.0
var type = ShotType.NORMAL


func _ready():
	var crit = randf() * 100.0
	if crit <= critical_chance:
		type = ShotType.CRITICAL

	match type:
		ShotType.NORMAL:
			pass

		ShotType.CRITICAL:
			$CPUParticles2D.emitting = true
			speed = ceil(speed * 1.1)
			damage = ceil(damage * 2.5)
			$Sprite.self_modulate = Color.red


func _physics_process(_delta):
	position.y += speed


func _on_Bullet_area_entered(area):
	if area.is_in_group("is:bullet"):
		return
	if area.faction == faction:
		return
	else:
		area.get_shot(damage)
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
