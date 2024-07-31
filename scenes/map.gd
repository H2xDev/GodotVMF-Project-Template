extends Node3D;

@onready var richText: RichTextLabel = %RichTextLabel;

func _ready():
	var args = OS.get_cmdline_args();
	var vmfArg = args.find("--vmf");

	if(vmfArg != -1):
		var mapName = args[vmfArg + 1];
		var mapPath = "res://hammer_project/mapsrc/{0}.vmf".format([mapName]);

		if (FileAccess.file_exists(mapPath) == false):
			message("Map file not found: {0}".format([mapPath]));
			return;

		richText.text += "Map: {0}".format([mapPath]);

		var vmf = VMFNode.new();

		get_tree().current_scene.add_child(vmf);

		vmf.vmf = mapPath;
		vmf.importMap(true);
	else:
		message("No map specified. Use --vmf <mapname> to specify a map to load.");

func _process(_delta):
	# On press ESC quit the game
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit();

func message(text):
	richText.text += "\n" + text;
