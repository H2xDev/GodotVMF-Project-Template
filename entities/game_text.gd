@tool
extends ValveIONode

var current_tween = null;

func _entity_ready():
	%label.text = entity.get("message", "").replace("\\n", "\n");
	%label.visible = false;
	%label['theme_override_colors/font_color'] = Color8(int(entity.color.x), int(entity.color.y), int(entity.color.z), 255);
	%label.modulate = Color8(255, 255, 255, 0);

func _reposite_text():
	var xpercent = entity.x;
	var ypercent = entity.y;

	if xpercent < 0: xpercent = 0.5;
	if ypercent < 0: ypercent = 0.5;

	%label.position.x = $panel.size.x * xpercent - %label.size.x * xpercent;
	%label.position.y = $panel.size.y * ypercent - %label.size.y * ypercent;

	if xpercent > 0.5:
		%label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT;

	if xpercent < 0.5:
		%label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT;

# INPUT
func Display(_param = null):
	_reposite_text();

	%label.visible = true;

	if current_tween != null:
		current_tween.stop();
		current_tween = null;

	current_tween = create_tween();
	current_tween.tween_property(%label, "modulate", Color8(255, 255, 255, 255), entity.fadein);

	await current_tween.finished;
	await get_tree().create_timer(entity.holdtime).timeout;

	current_tween = create_tween();
	current_tween.tween_property(%label, "modulate", Color8(255, 255, 255, 0), entity.fadeout);

	await current_tween.finished;
	current_tween = null;
	%label.visible = false;
