extends Node3D;
class_name Debugger;

@onready var richText: RichTextLabel = %logs;

const PROCESS_FILE = ".current_process";

static var instance: Debugger;
static func log(text: String):
	if instance: return;
	instance.message(text);

func kill_existing_process():
	var pid = FileAccess.open(PROCESS_FILE, FileAccess.READ);
	if pid:
		var processToKill = int(pid.get_line());

		if processToKill:
			message("Killing existing process: {0}".format([pid.get_line()]));
			OS.kill(processToKill);

		pid.close();

	var file = FileAccess.open(PROCESS_FILE, FileAccess.WRITE);
	file.store_string(str(OS.get_process_id()));
	file.close();

func launch_map():
	var args = OS.get_cmdline_args();
	var vmfArg = args.find("--vmf");

	var mapName = "devmap";

	if(vmfArg != -1):
		mapName = args[vmfArg + 1];
	
	var mapPath = "res://hammer_project/mapsrc/{0}.vmf".format([mapName]);

	if (FileAccess.file_exists(mapPath) == false):
		message("Map file not found: {0}".format([mapPath]));
		return;

	message("Loading map: {0}".format([mapPath]));

	var vmf = VMFNode.new();

	get_tree().current_scene.add_child(vmf);

	vmf.vmf = mapPath;
	vmf.saveGeometry = false;
	vmf.saveCollision = false;
	vmf.importMap(true);

	assign_skybox(vmf._structure);

func assign_skybox(vmf_struct: Dictionary):
	var env = $environment.environment;
	var sky_file = "res://skies/{0}".format([vmf_struct.world.skyname]);

	if not sky_file.get_extension():
		sky_file += ".jpg";

	if not FileAccess.file_exists(sky_file):
		print("Skybox file not found: {0}".format([sky_file]));
		return;

	print("Assigning skybox: {0}".format([sky_file]));

	env.sky.sky_material.panorama = load(sky_file);

func _ready():
	instance = self;

	kill_existing_process();
	launch_map();

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		DirAccess.remove_absolute(PROCESS_FILE);
		get_tree().quit();

func message(text):
	richText.text += "\n" + text;
