class_name PlayerPickupProcessor extends RefCounted

var current_item = null;
var hand_point = null;

func _init(point: Node3D):
	self.hand_point = point;

func pickup_item(item: PhysicsBody3D):
	if not item.is_class("RigidBody3D"):
		return;

	if not item.is_in_group("pickupable"):
		return;

	current_item = item;
	item.freeze = true;

func drop_item():
	if not current_item:
		return;

	current_item.freeze = false;
	current_item = null;

func has_item():
	return current_item != null;

func physics_process(delta):
	if not current_item:
		return;

	current_item.global_transform.origin = current_item.global_transform.origin \
			.lerp(hand_point.global_transform.origin, 20 * delta);
