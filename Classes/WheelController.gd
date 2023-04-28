extends Node3D

class_name WheelController

@export var wheel_radius: float = 0.35

@onready var wheel: Node3D = get_node("Wheel")
@onready var ray: RayCast3D = get_node("RayCast3D")

var spring_distance_max: float
var spring_constant: float
var spring_damping: float
var force: Vector3
var offset: Vector3
var spring_distance: float
var spring_distance_now: float
var spring_rest_position: float
var wheel_position: Vector3
var spring_velocity: float
var circumference: float
var steering_rotation: Quaternion
var wanted_steering_rotation: Quaternion

func _ready():
	#circumference = 2 * PI * wheel_radius
	#steering_rotation = Quaternion(wheel.transform.basis)
	pass

func init_suspension(rest_force: float, arg_spring_distance_max: float, arg_spring_constant: float, arg_spring_damping: float):
	spring_distance_max = arg_spring_distance_max
	spring_constant = arg_spring_constant
	spring_damping = arg_spring_damping
	ray.target_position = Vector3(0, -(wheel_radius + spring_distance_max), 0)
	spring_distance = 0
	spring_rest_position = rest_force / spring_constant

func add_spring_force(delta: float, vehicle_body: RigidBody3D, vehicle_rotation: Quaternion) -> bool:
	var has_contact: bool = ray.is_colliding()
	if has_contact:
		var contact_point: Vector3 = ray.get_collision_point()
		var contact_point_vehicle: Vector3 = vehicle_body.to_local(contact_point)
		spring_distance_now = contact_point_vehicle.y + wheel_radius
		if spring_distance != 0:
			spring_velocity = (spring_distance_now - spring_distance) / delta
		else:
			spring_velocity = 0
		var spring_force: float = spring_constant * (spring_distance_now + spring_rest_position) # Hooke's Law
		var damping_force: float = spring_damping * spring_velocity
		force = Vector3(0, spring_force + damping_force, 0)
		offset = vehicle_rotation * contact_point_vehicle
		vehicle_body.apply_force(offset, force)
		spring_distance = spring_distance_now
		wheel_position = Vector3(0, spring_distance, 0)
	else:
		spring_distance = 0
		wheel_position = Vector3(0, -spring_distance_max, 0)
	wheel.transform.origin = wheel_position
	return has_contact

func rotate_wheel(delta: float, distance_moved: float, steering_angle: float):
	var steering_max: float = deg_to_rad(45)
	var rotation_angle = 2 * PI * distance_moved / circumference
	var movement_rotation: Quaternion = Quaternion(Vector3.LEFT, rotation_angle)
	if steering_angle > steering_max:
		wanted_steering_rotation = Quaternion(Vector3.UP, steering_max)
		steering_rotation = steering_rotation.slerp(wanted_steering_rotation, 6 * delta)
		steering_rotation = steering_rotation.normalized()
	else: if steering_angle < -steering_max:
		wanted_steering_rotation = Quaternion(Vector3.UP, -steering_max)
		steering_rotation = steering_rotation.slerp(wanted_steering_rotation, 6 * delta)
		steering_rotation = steering_rotation.normalized()
	else:
		steering_rotation = Quaternion(Vector3.UP, steering_angle)
	var rotation = steering_rotation * movement_rotation
	wheel.transform.basis = Basis(rotation)

func get_force():
	return force

func get_offset():
	return offset
