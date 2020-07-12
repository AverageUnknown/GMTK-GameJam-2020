extends KinematicBody2D

enum {ANIMAL_BEAR, ANIMAL_HYENA, ANIMAL_RABBIT}

var vel : Vector2 = Vector2()
var direction : Vector2 = Vector2()
var knockback_direction : Vector2 = Vector2()
var knockbackSpeed = 50
var iframeTime = 1
onready var anim : AnimatedSprite = get_node("PlayerSprite")
onready var hyenaFrames = preload("res://HyenaAnim.tres")
onready var rabbitFrames = preload("res://RabbitAnim.tres")

var transformTime_min = 3
var transformTime_max = 7

var health = 100

var animals = [
#	{
#		animal = ANIMAL_BEAR,
#		name = "Bear",
#		attackSpeed = 1,
#		attackDamage = 5,
#		attackMove = 10,
#		moveSpeed = 30,
#		armor = 2,
#		superArmor = true,
#		scale = Vector2(2,3)
#	},
	{
		animal = ANIMAL_HYENA,
		name = "Hyena",
		attackSpeed = .5,
		attackDamage = 10,
		attackMove = 0,
		moveSpeed = 50,
		armor = 1,
		superArmor = false,
		scale = Vector2(1.552, 1.495),
		frames = preload("res://HyenaAnim.tres")
	},
	{
		animal = ANIMAL_RABBIT,
		name = "Rabbit",
		attackSpeed = 2.5,
		attackDamage = 2,
		attackMove = 350,
		moveSpeed = 75,
		armor = 0,
		superArmor = false,
		scale = Vector2(0.582, 0.432),
		frames = preload("res://RabbitAnim.tres")
	}
]

var currentAnimal = null
var rng = RandomNumberGenerator.new()

onready var transformTimer = get_node("TransformTimer")
onready var attackTimer = get_node("AttackTimer")
onready var attackAnimTimer = get_node("AttackAnimTimer")
onready var knockBackTimer = get_node("KnockBackTimer")
onready var iFrameTimer = get_node("IFrameTimer")

func _ready():
	print (animals[0].frames)
	var i = rng.randi_range(0,animals.size()-1)
	currentAnimal = clone_dictionary(animals[i])
	animals.remove(i)
	transformTimer.start(rng.randi_range(transformTime_min, transformTime_max))
	print (currentAnimal.frames)
	anim.set_sprite_frames(currentAnimal.frames)
	anim.set_scale(currentAnimal.scale)
	print(anim.frames)
	print(anim.scale)

func _physics_process (_delta):
	vel = Vector2()
	
	#inputs
	if !knockBackTimer.is_stopped():
		move_and_slide(knockback_direction.normalized() * knockbackSpeed)
	elif !attackAnimTimer.is_stopped():
		vel = (get_global_mouse_position() - position).normalized()
		if position.distance_to(get_global_mouse_position()) > 5:
			move_and_slide(vel * currentAnimal.attackMove)
	else:
		if Input.is_action_pressed("move_up"):
			vel.y -= 1
			direction = Vector2(0,-1)
		if Input.is_action_pressed("move_down"):
			vel.y += 1
			direction = Vector2(0,1)
		if Input.is_action_pressed("move_left"):
			vel.x -= 1
			direction = Vector2(-1,0)
		if Input.is_action_pressed("move_right"):
			vel.x += 1
			direction = Vector2(1,0)
		if Input.is_action_pressed("attack"):
			attack()
		move_and_slide(vel.normalized() * currentAnimal.moveSpeed)
		
	if vel.x != 0:
		anim.flip_h = vel.x > 0
		
	manage_animations()

func attack():
	if attackTimer.is_stopped():
		attackTimer.start(currentAnimal.attackSpeed)
		attackAnimTimer.start(currentAnimal.attackSpeed / 5)
		
func take_damage(dmg,dir):
	if !iFrameTimer.is_stopped():
		health -= dmg
		knockBackTimer.start(.15)
		knockback_direction = dir
		iFrameTimer.start(iframeTime)

#func _on_TransformTimer_timeout():
#	var i = rng.randi_range(0,animals.size()-1)
#	var temp = clone_dictionary(animals[i])
#	animals.remove(i)
#	animals.push_back(clone_dictionary(currentAnimal))
#	currentAnimal = clone_dictionary(temp)
#	transformTimer.start(rng.randi_range(transformTime_min, transformTime_max))

#func _on_KnockBackTimer_timeout():
#	knockback_direction = Vector2()

func clone_dictionary(dict):
	var newDict = {}
	for key in dict:
		newDict[key] = dict[key]
	return newDict
	
func _process(delta):
	if Input.is_action_just_pressed("transform"):
		transformTimer.start(.2)
		tform()
		
func manage_animations():
	if vel.x == 0 and vel.y == 0 and attackAnimTimer.is_stopped():
		play_animation(currentAnimal.name + "Idle")
	elif vel.x != 0 or vel.y != 0 and attackAnimTimer.is_stopped():
		play_animation(currentAnimal.name + "Move")
	elif !attackAnimTimer.is_stopped():
		play_animation(currentAnimal.name + "Attack")
	elif !transformTimer.is_stopped():
		play_animation("Transform")

func play_animation(anim_name):
	if anim.animation != anim.name:
		anim.play(anim_name)

func tform():
	anim.set_sprite_frames(currentAnimal.frames)
	anim.set_scale(currentAnimal.scale)