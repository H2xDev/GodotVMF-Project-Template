@tool
class_name trigger_once
extends ValveIONode

func _entity_ready():
	$Area3D.body_entered.connect.call_deferred(func(_node):
		if ValveIONode.aliases["!player"] == _node: 
			trigger_output("OnTrigger");
			queue_free();
	);

func _apply_entity(entityData):
	super._apply_entity(entityData);
	
	$Area3D/CollisionShape3D.shape = get_entity_shape();
