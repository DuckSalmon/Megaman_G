extends CharacterBody2D

@export var projectile = PackedScene
@onready var BULLET = preload("res://MegaBuster.tscn")
@onready var BUBBLE = preload("res://Bubble.tscn")

var WALK_SPEED := 82.5
var VELOCITY_X_DAMPING = 0.1
var JUMP_SPEED = 285.0
var GRAVITY_VEC := Vector2(0, 1)
var MAX_FALL_SPEED := 420.0
var left_right_key_press_time: float = 0

var walk_right := false
var walk_left := false
var ismoving := false
var is_launching_normal_attack := false
var is_sliding := false
var is_onair := false
var under_water := false

@onready var attacktimer = $Shootanimtimer
@onready var landsfx = preload("res://assets/AUDIO/SFX/Landing.wav")
@onready var defeatsfx = preload("res://assets/AUDIO/SFX/MegamanDefeat.wav")
@onready var megabustersfx = preload("res://assets/AUDIO/SFX/MegaBuster.wav")
@onready var splashsfx = preload("res://assets/AUDIO/SFX/splash.wav")

func _ready():
	pass

func _physics_process(delta):
	Global.playerxy = self.position


#Animations
	
	if is_launching_normal_attack == false:
		if ismoving == true:
			$Sprite/AnimationPlayer.play("walk")
		else:
			$Sprite/AnimationPlayer.play("Idle")
	
		if ismoving == true and left_right_key_press_time < 7: #max toe tipping frames
			$Sprite/AnimationPlayer.play("Tipping")
		if not is_on_floor():
			$Sprite/AnimationPlayer.play("jump")
		
	else:
		if ismoving == true:
			$Sprite/AnimationPlayer.play("shoot_walk")
		else:
			$Sprite/AnimationPlayer.play("shoot_idle")
		if not is_on_floor():
			$Sprite/AnimationPlayer.play("shoot_jump")
	
#	#Physics
	# Add the gravity.
	if not is_on_floor():
		velocity.y = clamp(velocity.y + 15.0, -MAX_FALL_SPEED, MAX_FALL_SPEED)
	
	
	if velocity.y > MAX_FALL_SPEED: #Limits fall speeds
		velocity.y = MAX_FALL_SPEED
	
	
	check_left_right_key_press_time(delta)
	
	var target_speed = 0
	
	if Input.is_action_pressed("left"):
		ismoving = true
		walk_left = true
	else:
		walk_left = false
		ismoving = false
	
	if Input.is_action_pressed("right"):
		walk_right = true
		ismoving = true
	else:
		walk_right = false

	if walk_right == true:
		target_speed += 1
		$Sprite.scale.x = 1
		Global.player_dir = 1
		$Shootpos.position.x = 32
	if walk_left == true:
		target_speed -= 1
		$Sprite.scale.x = -1
		Global.player_dir = -1
		$Shootpos.position.x = 0

	target_speed *= WALK_SPEED
	velocity.x = target_speed 


	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		is_onair = true
		velocity.y = -JUMP_SPEED * 1.0
	
	if Input.is_action_just_released("jump"):
		velocity.y = 0
	
	# Slide2
	if Input.is_action_pressed("jump") and Input.is_action_pressed("down"):
		is_sliding = true
		print("slide")
	
	#SHOOT
	if Input.is_action_just_pressed("shoot"):
		is_launching_normal_attack = true
		attacktimer.start() #add timer to the flag, after this time animations turns in non attacking
		if Global.projectile_max_number > 0:
			shoot()
			%SFXplayer.stream = megabustersfx
			%SFXplayer.play()
			
	if is_on_floor():
		if is_onair == false:
			%SFXplayer.stream = landsfx
			%SFXplayer.play()
			is_onair = true
	else:
		if is_onair == true:
			is_onair = false
			
			
		
func check_left_right_key_press_time(delta):
	if not(walk_left or walk_right): #If not currently doing either one of these
		left_right_key_press_time = 0
	else:
		left_right_key_press_time += 60 * delta


	move_and_slide()
	
	
func shoot():
	var b = BULLET.instantiate()	
	get_parent().add_child(b)
	b.position = $Shootpos.global_position
	Global.projectile_max_number -= 1

func _on_shootanimtimer_timeout():
	is_launching_normal_attack = false


func _on_visible_on_screen_notifier_2d_screen_exited():
	#death()
	pass

func _on_pit_ops():
	death()
	

func _on_area_2d_body_entered(body):
	splash()
	under_water = true
	$Bubble.start()


func _on_area_2d_body_exited(body):
	splash()
	under_water = false
	
func splash():
	%SFXplayer.stream = splashsfx
	%SFXplayer.play()
	print("splasgh")
	
	
func death():
	%SFXplayer.stream = defeatsfx
	%SFXplayer.play()
	print("ciao")
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://1.tscn")
	Global.reset_vars()


func _on_bubble_timeout():
	if under_water == true:
		var a = BUBBLE.instantiate()
		get_parent().add_child(a)
		a.position = self.position + Vector2(16,16)
		$Bubble.start(2.0)
