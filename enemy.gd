extends CharacterBody2D

@export var speed = 100.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player = null
@onready var anim = $AnimatedSprite2D

func _ready():
	# Oyun başlar başlamaz 'player' grubundaki karakterimizi bulur
	player = get_tree().get_first_node_in_group("player")
	anim.play("run") # Koşma animasyonunu başlat

func _physics_process(delta):
	# Yerçekimi
	if not is_on_floor():
		velocity.y += gravity * delta

	# Eğer oyuncuyu bulduysa ona doğru yürü
	if player:
		# Oyuncu sağda mı solda mı hesapla (1 veya -1 çıkar)
		var direction = sign(player.global_position.x - global_position.x)
		velocity.x = direction * speed
		
		# Düşmanın yüzünü oyuncuya dön
		anim.flip_h = direction < 0 
	else:
		velocity.x = 0
		anim.play("idle")

	move_and_slide()

# --- YENİ EKLENEN: Oyuncuya Değince Öldürme (Game Over) ---
func _on_damage_area_body_entered(body):
	if body.is_in_group("player"): # Eğer çarptığımız şey 'player' grubundaysa
		body.die() # Oyuncunun içindeki 'die' (öl) fonksiyonunu tetikle
