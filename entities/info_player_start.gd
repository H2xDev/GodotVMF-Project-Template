@tool
class_name info_player_start
extends ValveIONode

var player_entity = load("res://objects/player/player.tscn");
var instance: Player;

func _entity_ready():
	instance = player_entity.instantiate();

	get_tree().current_scene.add_child(instance);
	instance.global_transform.origin = global_transform.origin;
	instance.rotation_degrees.y = entity.get("angle", Vector3.ZERO).y - 90;

	get_parent().remove_child(self);
