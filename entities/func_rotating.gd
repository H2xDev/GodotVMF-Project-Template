@tool
extends ValveIONode

@export var preview = false;

const FLAG_START_ON: int = 1;
const FLAG_REVERSE_DIRECTION: int = 2;
const FLAG_X_AXIS: int = 4;
const FLAG_Y_AXIS: int = 8;

var rotTween = null;

# Called when the node enters the scene tree for the first time.
func _process_physics(dt):
	if Engine.is_editor_hint() && not preview:
		return;

	if not enabled:
		return;

	var speed = entity.maxspeed * dt;

	if typeof(entity.spawnflags) != TYPE_INT:
		entity.spawnflags = int(entity.spawnflags);

	if entity.spawnflags & FLAG_REVERSE_DIRECTION:
		speed *= -1;

	if entity.spawnflags & FLAG_X_AXIS:
		rotation_degrees.x += speed;
	elif entity.spawnflags & FLAG_Y_AXIS:
		rotation_degrees.z += speed;
	else:
		rotation_degrees.y += speed;

func _entity_ready():
	if Engine.is_editor_hint():
		return;

	if typeof(entity.spawnflags) != TYPE_INT:
		entity.spawnflags = int(entity.spawnflags);

	enabled = has_flag(FLAG_START_ON);

func RotateBy(deg):
	if rotTween:
		return;

	deg = float(deg);

	rotTween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN);
	var target = Vector3.ZERO;

	if has_flag(FLAG_X_AXIS):
		target.x = deg;
	elif has_flag(FLAG_Y_AXIS):
		target.z = deg;
	else:
		target.y = deg;
	
	var endRot = rotation_degrees + target;

	rotTween.tween_property(self, "rotation_degrees", endRot, 2.0);
	rotTween.play();
	rotTween.finished.connect(func(): rotTween = null);

func _apply_entity(e):
	super._apply_entity(e);

	$body/mesh.set_mesh(get_mesh());
	$body/mesh.cast_shadow = entity.disableshadows == 0;
	$body/collision.shape = get_entity_shape();
