class_name PlayerPickupProcessor extends RefCounted

var current_item = null;
var hand_point = null;
var old_gravity_scale = 0;
var movement_speed = 100000;
var throw_force = 0.01;

func _init(point: Node3D):
	self.hand_point = point;

func pickup_item(item: PhysicsBody3D):
	if not item.is_class("RigidBody3D"):
		return;

	if not item.is_in_group("pickupable"):
		return;

	current_item = item;
	old_gravity_scale = current_item.gravity_scale;
	current_item.gravity_scale = 0;
	current_item.lock_rotation = true;

func drop_item():
	if not current_item: return;

	current_item.gravity_scale = old_gravity_scale;
	current_item.lock_rotation = false;
	current_item = null;

func throw_item():
	if not current_item: return;

	var forward_vector = -hand_point.global_transform.basis.z;

	current_item.gravity_scale = old_gravity_scale;
	current_item.lock_rotation = false;
	current_item.apply_impulse(forward_vector * throw_force, Vector3.ZERO);
	current_item = null;

func has_item():
	return current_item != null;

func physics_process(delta):
	if not current_item: return;

	var actual_movement_speed = movement_speed * current_item.mass;
	var delta_position = hand_point.global_transform.origin - current_item.global_transform.origin;
	current_item.apply_force(delta_position * actual_movement_speed * delta, Vector3.ZERO);

	var friction_factor = 1 / (1 + movement_speed * delta);
	current_item.linear_velocity *= friction_factor;
