extends CharacterBody3D

const SPEED = 10.0

var time_since_last_played : float = 0.0

var rng = RandomNumberGenerator.new();

func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

func _process(delta: float) -> void:
	var wind = $Wind;
	if not wind.playing:
		wind.playing = true;
		
	var music = $Music;
	if not music.playing:
		music.play();

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	var camera = $Camera3D
	
	var direction = (camera.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		if time_since_last_played > (0.5 + rng.randf_range(-0.1, 0.1)):
			var audio = $Feet

			audio.playing = true
			time_since_last_played = 0.0;
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	time_since_last_played += delta;

	move_and_slide()


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
