# GodotVMF Project Starter [Work In Progress]

## Preparation
1. Install Godot engine to be able to run the project from cmd.  
1.1. You can do that via [Scoop package manager](https://scoop.sh/#/apps?q=godot&id=2fdd7b453f1ef3161d01986e2051c646911a642c)

2. Configure Hammer++ to work with [hammer_project](/hammer_project)  
2.1. Set `Game Executable Directory` - `<your_project>`  
2.2. Set `Game Directory` - `<your_project>\hammer_project`  
2.3. Set `Hammer VMF Directory` - `<your_project>\hammer_project\mapsrc`  
2.4. Set `Prefab Directory` - `<your_project>\hammer_project\mapsrc\prefabs`  
2.5. Add required FGD - base.fgd and halflife2.fgd (and your custom fgd as well)  

3. Restart Hammer++  

4. Open Godot project to precache project resources

5. Open `Run Map` in Expert mode (F9)  
5.1. Create a new build configuration by click `Edit` and give it a name ("GodotVMF" for example)  
5.2. Add a command by click `New`  
5.3. In Command field type `godot`  
5.4. In Parameters field type `scenes/map.tscn --path $exedir --vmf $file -v`  
5.5. That's it! Now you can run your map by pressing F9 and selecting `GodotVMF` configuration.
 
## Entities implemented
| Entity | Implementation State | Notes |
| --- | --- | --- |
| ambient_generic | Implemented | |
| info_player_start | Not completely | Flag master doesnt work |
| path_track | Implemented | |
| env_fade | Implemented | |
| point_teleport | Implemented | |
| info_overlay | Implemented | Has two modes - geometry and decal |
| game_text | Implemented | Without scan effect |
| light | Implemented | |
| light_spot | Implemented | |
| light_environment | Implemented | |
| trigger_once | Implemented | |
| trigger_multiple | Implemented | |
| func_detail | Implemented | |
| func_lod | Implemented | Duplicate of func_detail |
| func_brush | Not completely | Duplicate of func_detail |
| func_rotating | Implemented | |
| func_door | Implemented | |
| func_door_rotating | Implemented | |
| func_button | Implemented | |
| func_tracktrain | Not completely | Rotation by direction is not implemented |
| func_physbox | Not completely | Works only DisableMotion, EnableMotion and Motion Disabled flag |
| logic_relay | Implemented | |

## TODO
- env_fog_controller
