extends Area2D

var speed = 100
var target_food = null

func _ready() -> void:
	print("Eater is here!")
	find_nearest_food()

func _process(delta: float) -> void:
	if target_food and target_food.is_inside_tree():
		# Рассчитываем направление к еде
		var direction = (target_food.position - position).normalized()
		
		# Двигаемся к еде
		position += direction * speed * delta
		
		# Проверяем расстояние до еды, если близко - "съедаем" её
		if position.distance_to(target_food.position) < 10:
			eat_food()
	else:
		# Если еды нет или она исчезла, ищем новую
		find_nearest_food()

func find_nearest_food() -> void:
	# Находим все объекты еды в сцене
	var foods = get_tree().get_nodes_in_group("food")
	
	# Ищем ближайшую еду
	var nearest_distance = INF
	for food in foods:
		var dist = position.distance_to(food.position)
		if dist < nearest_distance:
			nearest_distance = dist
			target_food = food

func eat_food() -> void:
	if target_food:
		target_food.queue_free()  # Удаляем еду из сцены
		target_food = null  # Сбрасываем цель
		find_nearest_food()  # Ищем новую цель
