@tool
class_name TriggerPush extends trigger_multiple;

var acceleration = Vector3.ZERO;
var bodies = [];

const FLAG_PHYSICS_OBJECTS = 8;

const CLIENT_CLASSES = ["CharacterBody3D"];
const PHYSICS_CLASSES = ["RigidBody3D", "KinematicBody3D"];

func _entity_ready():
	super._entity_ready();

	acceleration = float(entity.speed) * get_movement_vector(entity.pushdir) * config.import.scale;

	$area.body_entered.connect(func(node):
		if bodies.has(node): return;

		var is_rigid_body = node is RigidBody3D and has_flag(FLAG_PHYSICS_OBJECTS);
		var is_character_body = node is CharacterBody3D and has_flag(FLAG_CLIENTS);

		if not is_rigid_body and not is_character_body:
			bodies.append(node);
	);
	
	$area.body_exited.connect(func(node):
		if bodies.has(node):
			bodies.erase(node);
	);

func _physics_process(delta):
	if Engine.is_editor_hint(): return;
	if not enabled: return;
	if not has_flag(FLAG_PHYSICS_OBJECTS) and not has_flag(FLAG_CLIENTS): return;
	
	for body in bodies:
		var is_rigid_body = body is RigidBody3D;
		var has_velocity = "velocity" in body;

		if is_rigid_body:
			body.apply_force(acceleration, Vector3.ZERO);
		elif has_velocity:
			body.velocity += acceleration * delta;
