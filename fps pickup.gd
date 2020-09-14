extends KinematicBody

var speed = 7
var acceleration = 10
var gravity = 0.09
var jump = 10

var mouse_sensitivity = 0.03

var weapon_to_spawn
var weapon_to_drop

var direction = Vector3()
var velocity = Vector3()
var fall = Vector3() 

onready var head = $Head
onready var camera = $Head/Camera
onready var reach = $Head/Camera/Reach
onready var hand = $Head/Hand

onready var gun_a_hr = preload("res://scenes/Gun A HR.tscn")
onready var gun_a = preload("res://scenes/Gun A.tscn")
onready var gun_b_hr = preload("res://scenes/Gun B HR.tscn")
onready var gun_b = preload("res://scenes/Gun B.tscn")

func _ready():
	pass

func _process(delta):
	if reach.is_colliding():
		if reach.get_collider().get_name() == "Gun A":
			weapon_to_spawn = gun_a_hr.instance()
		elif reach.get_collider().get_name() == "Gun B":
			weapon_to_spawn = gun_b_hr.instance()
		else:
			weapon_to_spawn = null
	else:
		weapon_to_spawn = null
		
	if hand.get_child(0) != null:
		if hand.get_child(0).get_name() == "Gun A HR":
			weapon_to_drop = gun_a.instance()
		elif hand.get_child(0).get_name() == "Gun B HR":
			weapon_to_drop = gun_b.instance()
	else:
		weapon_to_drop = null
		
	if Input.is_action_just_pressed("interact"):
		if weapon_to_spawn != null:
			if hand.get_child(0) != null:
				get_parent().add_child(weapon_to_drop)
				weapon_to_drop.global_transform = hand.global_transform
				weapon_to_drop.dropped = true
				hand.get_child(0).queue_free()
			reach.get_collider().queue_free()
			hand.add_child(weapon_to_spawn)
			weapon_to_spawn.rotation = hand.rotation
		
func _input(event):
	
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity)) 
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity)) 
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))	
			
func _physics_process(delta):
	
	direction = Vector3()
	
	move_and_slide(fall, Vector3.UP)
	
	if not is_on_floor():
		fall.y -= gravity
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		fall.y = jump
		
	
	if Input.is_action_pressed("move_forward"):
	
		direction -= transform.basis.z
	
	elif Input.is_action_pressed("move_backward"):
		
		direction += transform.basis.z
		
	if Input.is_action_pressed("move_left"):
		
		direction -= transform.basis.x			
		
	elif Input.is_action_pressed("move_right"):
		
		direction += transform.basis.x
			
		
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta) 
	velocity = move_and_slide(velocity, Vector3.UP) 
