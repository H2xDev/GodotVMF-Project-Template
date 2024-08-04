class_name HUD
extends Control

static var instance: HUD;

static func fade(color: Color, duration: float, from = false):
	if instance == null: return;
	instance._fade(color, duration, from);

var fade_tween = null;

func _ready():
	HUD.instance = self;

func _fade(color: Color, duration: float, from = false):
	if fade_tween != null:
		fade_tween.stop();
		fade_tween = null;	

	var target_color = color

	if from:
		$fade_panel.modulate = color;
		target_color = Color(color.r, color.g, color.b, 0);
	else:
		$fade_panel.modulate = Color(color.r, color.g, color.b, 0);

	fade_tween = create_tween();
	fade_tween.tween_property($fade_panel, "modulate", target_color, duration);

	await fade_tween.finished;
