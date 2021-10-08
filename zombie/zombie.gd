extends KinematicBody2D

export (int) var speed = 200
export (int) var earshot = 400

puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()

func _ready():
    puppet_pos = position	
    rset('puppet_pos', position)
    if is_network_master():
        $Camera2D.current = true


func _physics_process(_delta):
    var velocity = Vector2()

    if is_network_master():
        if Input.is_action_pressed('right'):
            velocity.x += 1
        if Input.is_action_pressed('left'):
            velocity.x -= 1
        if Input.is_action_pressed('down'):
            velocity.y += 1
        if Input.is_action_pressed('up'):
            velocity.y -= 1

        velocity = velocity.normalized() * speed 

        rset("puppet_motion", velocity)
        rset("puppet_pos", position)

    else:
        position = puppet_pos
        velocity = puppet_motion


    if velocity.length() > 0:
        $AnimatedSprite.flip_h = velocity.x < 0
        $AnimatedSprite.play('walk-x')
    else:
        $AnimatedSprite.stop()

    velocity = move_and_slide(velocity)
    if not is_network_master():
        puppet_pos = position # To avoid jitter
