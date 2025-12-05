# Most important scripts in the project and who made them

## Rostyslav

Edited this paper together with Michael.

### body.gd
The script that contains the Body class. It extends from RigidBody2D, which is a type of “node” provided by the engine which helps with the basic physics. The Body class was created as the basic data type for everything that is a part of the gravity simulation, since RigidBody2D isn’t designed for that itself. Our gravity system queries the tree for every body and applies forces to them. Body class also handles the programmatic creation of sprite and collider for itself.

### Level Config (`level_config` directory)
All files in `level_config` directory (`asteroid.gd`, `attack.gd`, `attack_schedule.gd`, `attack_schedule.gd`, `attack_schedule_item.gd`, `bullet.gd`, `gun.gd`, `level.gd`) are classes that describe level and its components. Top level class is LevelConf (in level.gd) that has other conf classes as properties. For example, attack.gd lets us specify values such as an attack’s position, the direction from which asteroids are spawning, and the type of asteroid the attack should use. They extend Godot's Resource class which lets them be instantiated + serialized (saved as .tres assets), edited directly in the inspector, and referenced by the game at runtime without instantiating scene nodes.

### asteroid.gd
Contains the Asteroid class, which extends from Body. These are spawned by the custom attack system. Implements custom asteroid collision responses and has asteroid-specific properties.

### attack_system.gd
Takes relevant data from LevelConf and instantiates, gives, applies forces and positions all incoming asteroids that challenge the player.

### gun.gd
Contains the Gun class. This handles tasks such as instantiating bullets and reloading. This class extends Body so that it could be a part of the n-body simulation. The aiming is handled by the custom GunAiming class in aiming.gd, and the values of the gun are defined by the level. Reload, magazine size and cooldown mechanics are handled by GunMechanics in mechanics.gd.

### bullet.gd
Contains the Bullet class, which extends Body. Contains a bullet’s health, damage, and handles what happens when it collides with other bodies.

### game.gd
The code that runs inside of levels. This glues everything together, such as the level, attack system, physics, the HUD, input, and a lot of the game’s logic that didn’t deserve its own module so far.

### main.gd
Handles the title screen.

### choose_level.gd
The level select screen. This is where custom levels are added.

### Scene Tree
The scene tree (main layout of the program and the UI). Scenes are manually created and stored in .tscn files, which are nodes organized in a tree structure that can be instantiated as a whole. Scenes are switched from code.  
In Godot engine you can create GUI in editor, adding nodes to the tree. It’s not in code like html but fundamentally requires some work to do.

### UI directory
Files in the UI directory: Not code, but custom theme configuration for our game.

---

## Michael

The levels, this paper, and implementing the Barnes-Hut algorithm:

### QuadTree.cs
The quadtree used by the Barnes-Hut algorithm. Divides the map recursively into quadrants until each node contains one or zero bodies. The center of mass and total mass of each quadrant is then computed by traversing up the tree. Finally, a formula is used with an accuracy value (how far to traverse down the tree) to compute the approximated forces for each object. This class extends QuadTreeElement for simplicity.

### QuadTreeElement.cs
The data type for the QuadTree class’s nodes. These keep track of their total mass, center of mass, the 4 nodes beneath them, and its dimensions. These were done in C# for the sake of performance. Since it’s compiled and GDScript is interpreted, it has the potential to be much faster.

---

## Axelle

The slides, sprites, and documentation.

---

## Stuff we didn’t make

We didn’t make the addons folder, .cfg files, .import files or the engine itself. uid files are automatically created and are used to keep paths linked when files are moved or renamed. .godot files are automatically created but ultimately contain the configurations we tweaked from editor.

In Godot, most of these files are not shown in the file system as they are not relevant to developers.
