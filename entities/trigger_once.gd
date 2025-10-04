@tool
class_name trigger_once extends VMFEntityNode

func _entity_ready():
	# NOTE: Call deffered is used to prevent unexpected trigger after player spawn
	$area.body_entered.connect.call_deferred(func(_node):
		if "!player" in VMFEntityNode.aliases and VMFEntityNode.aliases["!player"] == _node: 
			trigger_output("OnTrigger");
			queue_free();
	);

func _entity_setup(_e: VMFEntity) -> void:
	$area/collision.shape = get_entity_shape();
