extends Control
# MigrationUI - Interface para o MigrationTool

@onready var migration_tool = $"."
@onready var status_label = $VBoxContainer/Status
@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var backup_button = $VBoxContainer/BackupButton
@onready var migrate_button = $VBoxContainer/MigrateButton
@onready var verify_button = $VBoxContainer/VerifyButton
@onready var log_button = $VBoxContainer/LogButton
@onready var close_button = $VBoxContainer/CloseButton
@onready var log_label = $ScrollContainer/LogLabel

func _ready():
	# Conectar sinais do MigrationTool
	migration_tool.migration_started.connect(_on_migration_started)
	migration_tool.migration_progress.connect(_on_migration_progress)
	migration_tool.migration_completed.connect(_on_migration_completed)
	
	# Conectar botoes
	backup_button.pressed.connect(_on_backup_pressed)
	migrate_button.pressed.connect(_on_migrate_pressed)
	verify_button.pressed.connect(_on_verify_pressed)
	log_button.pressed.connect(_on_log_pressed)
	close_button.pressed.connect(_on_close_pressed)
	
	_update_status("Aguardando acao...")

func _on_backup_pressed():
	_update_status("Criando backup...")
	_disable_buttons()
	
	var success = migration_tool.backup_json_files()
	
	if success:
		_update_status("Backup criado com sucesso!")
	else:
		_update_status("Erro ao criar backup")
	
	_enable_buttons()

func _on_migrate_pressed():
	_update_status("Iniciando migracao...")
	_disable_buttons()
	progress_bar.value = 0
	
	var result = await _run_migration()
	
	if result.success:
		_update_status("Migracao concluida! " + str(result.players) + " jogadores migrados")
		progress_bar.value = 100
	else:
		_update_status("Erro na migracao: " + result.get("error", "Desconhecido"))
	
	_enable_buttons()

func _run_migration():
	# Pequeno delay para UI atualizar
	await get_tree().create_timer(0.1).timeout
	return migration_tool.start_migration()

func _on_verify_pressed():
	_update_status("Verificando migracao...")
	_disable_buttons()
	
	var result = migration_tool.verify_migration()
	
	if result.success:
		_update_status("Verificacao OK! JSON: " + str(result.json_count) + " | SQLite: " + str(result.db_count))
	else:
		_update_status("Verificacao com avisos - verifique o log")
	
	_enable_buttons()

func _on_log_pressed():
	migration_tool.print_summary()
	_update_log()

func _on_close_pressed():
	get_tree().quit()

func _on_migration_started():
	_update_status("Migracao em progresso...")
	progress_bar.value = 0

func _on_migration_progress(current: int, total: int, message: String):
	var percent = (float(current) / float(total)) * 100.0
	progress_bar.value = percent
	_update_status(message + " (" + str(current) + "/" + str(total) + ")")

func _on_migration_completed(success: bool, log: Array):
	if success:
		_update_status("Migracao concluida com sucesso!")
	else:
		_update_status("Migracao falhou - verifique o log")
	
	_update_log()

func _update_status(text: String):
	status_label.text = text
	print("[UI] ", text)

func _update_log():
	var log_text = ""
	for line in migration_tool.migration_log:
		log_text += line + "\n"
	log_label.text = log_text

func _disable_buttons():
	backup_button.disabled = true
	migrate_button.disabled = true
	verify_button.disabled = true

func _enable_buttons():
	backup_button.disabled = false
	migrate_button.disabled = false
	verify_button.disabled = false

