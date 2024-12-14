extends Node

@export var next_scene : PackedScene
@onready var sfx_select = $SFXSelect
@onready var panel_credits_2 = $CanvasLayer/PanelCredits2


func _on_button_play_pressed():
	sfx_select.play()
	panel_credits_2.visible = false
	get_tree().change_scene_to_packed(next_scene)


func _on_label_credits_pressed():
	sfx_select.play()
	if !panel_credits_2.visible:
		panel_credits_2.visible = true
	else:
		panel_credits_2.visible = false
