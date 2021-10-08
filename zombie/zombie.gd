extends KinematicBody2D

export (int) var speed = 200
export (int) var earshot = 400


func _ready():
	pass	


func _physics_process(_delta):
	var velocity: Vector2

	if Input.is_action_pressed('right'):
		velocity.x += 1
	if Input.is_action_pressed('left'):
		velocity.x -= 1
	if Input.is_action_pressed('down'):
		velocity.y += 1
	if Input.is_action_pressed('up'):
		velocity.y -= 1

	velocity = velocity.normalized() * speed 

	if velocity.length() > 0:
		$AnimatedSprite.flip_h = velocity.x < 0
		$AnimatedSprite.play('walk-x')
		velocity = move_and_slide(velocity)
	else:
		$AnimatedSprite.stop()
