extends Area2D

var speed = 100
var target_food = null

func _ready() -> void:
	print("Eater is here!")
	find_nearest_food()

func _process(_delta: float) -> void:
	# Проверяем, что еда существует и она не была удалена
	if target_food and is_instance_valid(target_food) and target_food.is_inside_tree():
		# Рассчитываем направление к еде
		var direction = (target_food.position - position).normalized()
		
		# Двигаемся к еде с учетом времени
		position += direction * speed * _delta
		
		# Проверяем расстояние до еды, если близко - "съедаем" её
		if position.distance_to(target_food.position) < 10:
			eat_food()
	else:
		# Если еды нет или она исчезла, ищем новую
		find_nearest_food()

func find_nearest_food() -> void:
	# Находим все объекты еды в сцене
	var foods = get_tree().get_nodes_in_group("food")
	
	# Проверяем, если еды нет
	if foods.is_empty():
		print("Нет объектов еды в сцене.")
		return  # Если еды нет, выходим из функции

	# Если еда есть, ищем ближайшую
	print("Есть объекты еды.")
	
	# Ищем ближайшую еду
	var nearest_distance = INF
	target_food = null  # Сбрасываем текущую цель
	for food in foods:
		var dist = position.distance_to(food.position)
		if dist < nearest_distance:
			nearest_distance = dist
			target_food = food

func eat_food() -> void:
	if target_food:
		target_food.queue_free()  # Удаляем еду из сцены
		target_food = null  # Сбрасываем цель после поедания
		#find_nearest_food()  # Ищем новую цель
