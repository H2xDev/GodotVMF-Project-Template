@tool
class_name info_player_start
extends ValveIONode

var player_entity = load("res://objects/player/player.tscn");
var instance: Player;

func _entity_ready():
	instance = Player.instance if Player.instance else player_entity.instantiate();

	get_tree().current_scene.add_child(instance);
	instance.global_transform.origin = global_transform.origin;
	instance.rotation.y = convert_direction(entity.get("angle", Vector3.ZERO)).y - PI / 2.0;

	get_parent().remove_child(self);
