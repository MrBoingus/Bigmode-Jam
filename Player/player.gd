extends CharacterBody2D

var input : Vector2

var earlyJumpFrames = 4

# Ground Stats
var speed = 650
var friction = 0.8
var jumpForce = 1200
#Air Stats
var airSpeed = 650
var airFriction = 0.6
var earlyGravity = 5
var gravity = 80
var fallGravity = 100

var state : Enums.playerStates
var stateDuration : int

var bullet = preload("res://Bullet.tscn")

func _ready() -> void:
	state = Enums.playerStates.Idle

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if state == Enums.playerStates.Jump or state == Enums.playerStates.Airborne:
			pass
		else:
			velocity.y -= jumpForce
			state = Enums.playerStates.Jump
			ChangeState()
	
	if event.is_action_pressed("shoot"):
		CreateBullet()

func _physics_process(delta: float) -> void:
	input.x = Input.get_axis("left", "right")
	
	if input.x != 0:
		$Sprite2D.scale.x = sign(input.x)
		$Gun.position.x = sign(input.x) * 112 # replace with variable later

	stateDuration += 1
	
	match state:
		Enums.playerStates.Idle:
			if !is_on_floor():
				state = Enums.playerStates.Airborne
				ChangeState()
				
			if input.x != 0:
				state = Enums.playerStates.Move
				ChangeState()
			else:
				velocity.x = lerp(velocity.x, 0.0 , friction)
				
			move_and_slide()
			if !is_on_floor():
				state = Enums.playerStates.Airborne
				ChangeState()
				
		Enums.playerStates.Move:
			if input.x == 0:
				state = Enums.playerStates.Idle
				ChangeState()
				return
			else:
				velocity.x = input.x * speed
				
			move_and_slide()
			if !is_on_floor():
				state = Enums.playerStates.Airborne
				ChangeState()
				
		Enums.playerStates.Jump:
			if stateDuration <= earlyJumpFrames:
				velocity.y += earlyGravity
			else:
				velocity.y += gravity
			
			if sign(velocity.y) >= 0:
				state = Enums.playerStates.Airborne
				ChangeState()
				
			if input.x == 0:
				velocity.x = lerp(velocity.x, 0.0, airFriction)
			else:
				velocity.x = speed * input.x
			
			move_and_slide()
		
		Enums.playerStates.Airborne:
			velocity.y += fallGravity
			
			if input.x == 0:
				velocity.x = lerp(velocity.x, 0.0, airFriction)
			else:
				velocity.x = speed * input.x
			
			move_and_slide()
			if is_on_floor():
				state = Enums.playerStates.Idle
				ChangeState()
				return
			

func ChangeState():
	stateDuration = 0

func CreateBullet():
	var new : RigidBody2D = bullet.instantiate()
	
	owner.add_child(new)
	
	new.global_position = $Gun.global_position
	
	var force = 10000 * sign($Sprite2D.scale.x)
	new.apply_force(Vector2(force, 0))
