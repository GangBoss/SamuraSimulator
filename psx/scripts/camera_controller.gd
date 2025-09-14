extends Camera3D

var target_camera_state : CameraState;
var interpolating_camera_state : CameraState;

var rotation_lerp_time = 0.01;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_camera_state = CameraState.new();
	interpolating_camera_state = CameraState.new();

	target_camera_state.SetFromTransform(self.rotation, self.position)
	interpolating_camera_state.SetFromTransform(self.rotation, self.position)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_movement = event.relative * get_process_delta_time()

		target_camera_state.angles += Vector3(-mouse_movement.y, -mouse_movement.x, 0.0) * 0.25

		var rotation_lerp_percent = 1.0 - exp((log(1.0 - 0.99) / rotation_lerp_time) * get_process_delta_time())

		interpolating_camera_state.LerpTowards(target_camera_state, 0, rotation_lerp_percent)

		self.rotation = interpolating_camera_state.GetEulerAngles()
