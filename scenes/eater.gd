extends Area2D

var speed = 100
var target_food = null
var hunger_time = 0  # Время с момента последнего поедания еды
var hunger_limit = 10  # Время в секундах до "смерти" от голода
var reproduction_radius = 50  # Радиус для поиска партнера для размножения
var reproduce_timeout = 10

var move_direction = Vector2.ZERO  # Направление движения

func _ready() -> void:
	print("Eater is here!")
	self.add_to_group("eater")
	find_nearest_food()
	set_random_move_direction()

func _process(_delta: float) -> void:
	# Увеличиваем счетчик времени голода
	hunger_time += _delta
	
	# Проверяем, не истекло ли время голода
	if hunger_time >= hunger_limit:
		die_of_hunger()
		return
	
	# Если еда есть, идем к ней
	find_nearest_food()
	
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
		# Если еды нет или она исчезла, бродим случайным образом
		move_randomly(_delta)
		
		if hunger_time <= 3:
			try_reproduce()
			return

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
		hunger_time = 0  # Сбрасываем счетчик времени голода
		print("Eater ate food and is no longer hungry.")
		
		# После поедания еды ищем партнера для размножения
		try_reproduce()

func try_reproduce() -> void:
	# Ищем других "eater" поблизости
	if reproduce_timeout <= 0:
		var eaters = get_tree().get_nodes_in_group("eater")
		var nearest_eater = null
		var nearest_distance = reproduction_radius
		
		# Ищем ближайшего "eater"
		for eater in eaters:
			# Игнорируем себя
			if eater == self:
				continue
				
			var dist = position.distance_to(eater.position)
			if dist < nearest_distance:
				nearest_distance = dist
				nearest_eater = eater
		
		# Если нашли партнера для размножения, создаем нового "eater"
		if nearest_eater:
			print("Found a mate for reproduction!")
			reproduce(nearest_eater)
			reproduce_timeout = 1000
	else:
		reproduce_timeout -= 1

func reproduce(partner: Area2D) -> void:
	# Создаем нового "eater" на позиции текущего
	var new_eater = load("res://scenes/eater.tscn").instantiate()  # Укажите путь к сцене Eater
	get_parent().add_child(new_eater)
	new_eater.position = position + Vector2(randf_range(-50, 50), randf_range(-50, 50))  # Небольшое случайное смещение
	print("New Eater has been born!")
	
	
	# Можно добавить дополнительные условия для размножения, например, увеличить шанс после нескольких поеданий.
	
func die_of_hunger() -> void:
	print("Eater died of hunger.")
	queue_free()  # Удаляем объект Eater из сцены

func move_randomly(_delta: float) -> void:
	# Если Eater не двигается в определенном направлении, создаем новое случайное направление
	if move_direction == Vector2.ZERO:
		set_random_move_direction()
	
	# Двигаемся в выбранном случайном направлении
	position += move_direction * speed * _delta
	
	# Периодически меняем направление случайным образом
	if randf() < 0.01:  # 1% шанс изменить направление каждый кадр
		set_random_move_direction()

func set_random_move_direction() -> void:
	# Устанавливаем случайное направление (угол в пределах 0-2π)
	var angle = randf_range(0, 2 * PI)
	move_direction = Vector2(cos(angle), sin(angle)).normalized()
