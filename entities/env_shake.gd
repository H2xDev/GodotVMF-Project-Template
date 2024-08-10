@tool
class_name env_shake
extends ValveIONode

const FLAG_GLOBAL_SHAKE = 1;
const FLAG_PHYSICS = 8;

var bodies = []

func _entity_ready():
	Disable();
	
	if not has_flag(FLAG_GLOBAL_SHAKE):
		$area.body_entered.connect(func(body):
			var is_rigid_body = body is RigidBody3D and has_flag(FLAG_PHYSICS);
			var is_character_body = body is CharacterBody3D;

			if is_rigid_body or is_character_body:
				bodies.append(body);
		);

		$area.body_exited.connect(func(body):
			bodies.erase(body);
		);

func _apply_entity(e):
	super._apply_entity(e);
	$area/collision.shape.radius = e.get("radius", 0.1) * config.import.scale;

func _physics_process(delta):
	if not enabled: return;
	var freq = float(entity.get("frequency", 0.1)) / 255.0 * 100.0;
	var amp = entity.get("amplitude", 0.1);
	var radius = entity.get("radius", 0.1) * config.import.scale;

	for body in bodies:
		var force_vector = Vector3(
			sin(Time.get_ticks_msec() * freq * 1.345092) * randf_range(-amp, amp),
			cos(Time.get_ticks_msec() * freq * 1.232092) * randf_range(-amp, amp),
			cos(Time.get_ticks_msec() * freq * 1.584098) * randf_range(-amp, amp)
		) * freq;

		var influence = 1 - clamp(body.global_transform.origin.distance_to(global_transform.origin) / radius, 0, 1);

		if body is RigidBody3D:
			body.apply_force(force_vector * delta * influence, Vector3.ZERO);
			body.apply_torque(force_vector * delta * influence * 0.1);
		elif body is CharacterBody3D and body.is_on_floor():
			if "shake" in body:
				body.shake += amp * delta;

# INPUTS

func StartShake(_param = null):
	Enable();
	await get_tree().create_timer(entity.get("duration", 1.0)).timeout;
	Disable();

func Stop(_param = null):
	Disable();
