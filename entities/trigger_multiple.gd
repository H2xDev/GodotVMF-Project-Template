@tool
class_name trigger_multiple
extends ValveIONode

func _entity_ready():
	$Area3D.body_entered.connect(func(_node):
		if ValveIONode.aliases["!player"] == _node: 
			trigger_output("OnTrigger");
			trigger_output("OnStartTouch");
	);

	$Area3D.body_exited.connect(func(_node):
		if ValveIONode.aliases["!player"] == _node: 
			trigger_output("OnEndTouch");
	);

func _apply_entity(entityData):
	super._apply_entity(entityData);
	
	$Area3D/CollisionShape3D.shape = get_entity_shape();
