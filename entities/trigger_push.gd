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
		# FIXME Rigid bodies won't work here
		if "velocity" in node and not bodies.has(node):
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
		var isPhysicsAllowed = has_flag(FLAG_PHYSICS_OBJECTS) and PHYSICS_CLASSES.has(body.get_class());
		var isClientAllowed = has_flag(FLAG_CLIENTS) and CLIENT_CLASSES.has(body.get_class());

		if isPhysicsAllowed or isClientAllowed:
			body.velocity += acceleration * delta;
