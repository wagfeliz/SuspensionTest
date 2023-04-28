extends RigidBody3D

class_name VehicleController

@export var spring_distance_max: float = 0.14
@export var spring_constant: float = 42214
@export var spring_damping: float = 7904

@onready var fl: WheelController = get_node("FL")
@onready var fr: WheelController = get_node("FR")
@onready var bl: WheelController = get_node("BL")
@onready var br: WheelController = get_node("BR")

func _ready():
	var weight: float = mass * ProjectSettings.get_setting("physics/3d/default_gravity")
	fl.init_suspension(weight / 4, spring_distance_max, spring_constant, spring_damping)
	fr.init_suspension(weight / 4, spring_distance_max, spring_constant, spring_damping)
	bl.init_suspension(weight / 4, spring_distance_max, spring_constant, spring_damping)
	br.init_suspension(weight / 4, spring_distance_max, spring_constant, spring_damping)

func _physics_process(delta: float):
	#var vehicle_rotation = Quaternion(transform.basis)
	var vehicle_rotation = Quaternion(get_global_transform().basis)
	
	fl.add_spring_force(delta, self, vehicle_rotation)
	fr.add_spring_force(delta, self, vehicle_rotation)
	bl.add_spring_force(delta, self, vehicle_rotation)
	br.add_spring_force(delta, self, vehicle_rotation)
