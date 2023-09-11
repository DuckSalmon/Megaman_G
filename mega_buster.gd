extends Area2D

var speed = 300
var direction := Vector2(1, 0)
@onready var xypoint = preload("res://Player.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer2D.play()
	direction.x = Global.player_dir
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#position = $Shootpos.position
	translate(speed*delta*direction)
	
	
	


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	Global.projectile_max_number += 1
