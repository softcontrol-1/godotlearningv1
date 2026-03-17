extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -400.0
@export var dash_speed = 600.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

# Kılıç ve Skor Değişkenleri
@onready var sword_hitbox = $SwordHitbox
@onready var score_label = $ScoreLabel
var score = 0

# --- YENİ EKLENEN: Oyun Bitti Ekranı Değişkeni ---
@onready var game_over_ui = $GameOverUI 

# Durum Değişkenleri
var is_attacking = false
var is_dashing = false
var dash_direction = 1 

func _physics_process(delta):
	# 1. Yerçekimi
	if not is_on_floor():
		velocity.y += gravity * delta
		if not is_attacking and not is_dashing:
			anim.play("jump")

	# --- DURUM KONTROLÜ ---
	if is_attacking:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, speed)
		move_and_slide()
		return
		
	if is_dashing:
		velocity.x = dash_direction * dash_speed
		velocity.y = 0 
		move_and_slide()
		return

	# 2. Zıplama Kontrolü
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_velocity

	# 3. Sağ-Sol Hareketi ve Yön Ayarları
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = direction * speed
		anim.flip_h = direction < 0
		dash_direction = direction 
		
		# Kılıç Kutusunu Baktığımız Yöne Çevirme
		if direction < 0:
			sword_hitbox.scale.x = -1 
		else:
			sword_hitbox.scale.x = 1  
			
		if is_on_floor():
			anim.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		dash_direction = -1 if anim.flip_h else 1 
		if is_on_floor():
			anim.play("idle")

	# 4. Saldırı (Z Tuşu) ve Düşmanı Yok Etme
	if Input.is_action_just_pressed("attack") and is_on_floor():
		is_attacking = true
		anim.play("attack")
		
		var hit_bodies = sword_hitbox.get_overlapping_bodies()
		for body in hit_bodies:
			if body.is_in_group("enemy"): 
				body.queue_free() 
				score += 1 
				score_label.text = str(score) 

	# 5. Dash / İleri Atılma (X Tuşu)
	if Input.is_action_just_pressed("dash") and is_on_floor():
		is_dashing = true
		anim.play("dash")
		collision_shape.disabled = true

	# Hareketi Uygula
	move_and_slide()

# --- ANİMASYON BİTİŞ KONTROLÜ ---
func _on_animated_sprite_2d_animation_finished():
	if anim.animation == "attack":
		is_attacking = false
	elif anim.animation == "dash":
		is_dashing = false
		collision_shape.disabled = false

# --- OYUN BİTTİ SİSTEMİ ---
func die():
	# Eğer dash atıyorsak hasar almayız (Dokunulmazlık / I-frame)
	if is_dashing:
		return
		
	# Eğer dash atmıyorsak oyun biter
	game_over_ui.show() # Ekranı göster
	get_tree().paused = true # Oyunu dondur

# --- BUTON SİNYALLERİ ---
func _on_rety_pressed() -> void:
	get_tree().paused = false # Dondurmayı kaldır
	get_tree().reload_current_scene() # Sahneyi yenile

func _on_quit_pressed() -> void:
	get_tree().quit() # Oyundan çık
