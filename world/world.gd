extends Node2D

signal boss_fight
signal phase
# PhaseTimer waits for a certain amount of time and then changes|
# the current phase we are on.
onready var PhaseTimer := $PhaseTimer

# Preloaded enemies scenes, will be used to spawn enemies. Treat as a constant
#onready var  BasicEnemyScene = preload("res://characters/enemies/ground/basic.tscn");


func _ready():
	# Everytime we reload the world, we need to reset the current
	# phase back to 1 by going to the next phase, emit phase1
	Game.current_phase = 0
	next_phase()
	
	# PhaseTimer Setup
	PhaseTimer.wait_time = Game.TIME_UNTIL_BOSS_ARRIVAL / Game.MAX_PHASES
	PhaseTimer.connect("timeout", self, "next_phase")
	PhaseTimer.start()
	

func next_phase():
	# Change Phase
	Game.current_phase += 1
	if Game.current_phase > Game.MAX_PHASES:
		PhaseTimer.stop()
		emit_signal("boss_fight");
		return
	print("starting phase %s" % Game.current_phase)
	
	emit_signal("phase", [Game.current_phase])
	
	spawn_enemy_at(Game.EnemyTypes.BASIC_SKELETON, Vector2(rand_range(0, 1000), 520));

func spawn_enemy_at(script, pos : Vector2):
	var enemy = script.instance();
	add_child(enemy);
	enemy.translate(pos);
	#enemy.set_world_spawn_request_callback(self, "spawn_enemy_at");


func _on_enemies_hit(list):
	for enemy in list:
		if is_instance_valid(enemy):
			if enemy.has_method('hit'):
				enemy.hit(1);
				print("%s hurt, now has %s out of %s health remaining" % [enemy, enemy.health, enemy.max_health])
			else:
				enemy.queue_free();


func _on_Inbounds_body_exited(body):
	print(body, " killed");
	if is_instance_valid(body):
		body.queue_free();
