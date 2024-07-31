# GodotVMF Project Starter

## Preparation
1. Install Godot engine to be able to run the project from cmd.  
    1.1. You can do that via [Scoop package manager](https://scoop.sh/#/apps?q=godot&id=2fdd7b453f1ef3161d01986e2051c646911a642c)

3. Configure Hammer++ to work with [hammer_project](/hammer_project)  
    3.1. Set `Game Executable Directory` - `<your_project>`
	3.2. Set `Game Directory` - `<your_project>\hammer_project`  
	3.3. Set `Hammer VMF Directory` - `<your_project>\hammer_project\mapsrc`  
	3.4. Set `Prefab Directory` - `<your_project>\hammer_project\mapsrc\prefabs`  
	3.5. Add required FGD - base.fgd and halflife2.fgd (and your custom fgd as well)  
3. Restart Hammer++  

4. Open `Run Map` in Expert mode (F9)  
4.1. Create a new build configuration by click `Edit` and give it a name ("GodotVMF" for example)  
4.2. Add a command by click `New`  
4.3. In Command field type `godot`  
4.4. In Parameters field type `scenes/map.tscn --path $exedir --vmf $file -v`  
4.5. That's it! Now you can run your map by pressing F9 and selecting `GodotVMF` configuration.
 
> This project is already uses materials sync so you don't need to convert materials to VTF since it's done automatically once material or texture changed.  

## Planned Features
- Logic entities
- Gameplay Entities
