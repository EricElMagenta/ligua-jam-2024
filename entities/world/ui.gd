extends CanvasLayer

@onready var health = $Healthbar/Health
@onready var h_scroll_bar = $Node/HScrollBar
@onready var progress_bar = $Node/ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	progress_bar.value = h_scroll_bar.value
	health.value = progress_bar.value
