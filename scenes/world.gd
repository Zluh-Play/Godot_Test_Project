extends Node

var food_scene  = preload("res://scenes/food.tscn")
var eater_scene = preload("res://scenes/eater.tscn")

func _ready() -> void:
	print("World is created!..")

func _process(_delta: float) -> void:
	pass

func _input(event):
	# Проверяем левый клик мыши для спавна еды
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var food_instance = food_scene.instantiate()
		food_instance.position = event.position
		add_child(food_instance)
		
	# Проверяем правый клик мыши для спавна поедателя
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var eater_instance = eater_scene.instantiate()
		eater_instance.position = event.position
		add_child(eater_instance)
