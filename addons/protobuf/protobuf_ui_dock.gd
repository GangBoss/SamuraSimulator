@tool
# BSD 3-Clause License
#
# Copyright (c) 2018 - 2023, Oleg Malyavkin
# All rights reserved.

extends VBoxContainer

var Parser = preload("res://addons/protobuf/parser.gd")
var Util = preload("res://addons/protobuf/protobuf_util.gd")

var input_file_path = null
var output_file_path = null

func _ready():
	pass

func _on_InputFileButton_pressed():
	
	show_dialog($InputFileDialog)
	$InputFileDialog.invalidate()

func _on_OutputFileButton_pressed():
	
	show_dialog($OutputFileDialog)
	$OutputFileDialog.invalidate()

func _on_InputFileDialog_file_selected(path):
	
	input_file_path = path
	$HBoxContainer/InputFileEdit.text = path

func _on_OutputFileDialog_file_selected(path):
	
	output_file_path = path
	$HBoxContainer2/OutputFileEdit.text = path

func show_dialog(dialog):
	
	dialog.popup_centered()

func _on_CompileButton_pressed():
	
	if input_file_path == null || output_file_path == null:
		show_dialog($FilesErrorAcceptDialog)
		return
	
	var file = FileAccess.open(input_file_path, FileAccess.READ)
	if file == null:
		print("File: '", input_file_path, "' not found.")
		show_dialog($FailAcceptDialog)
		return
	
	var parser = Parser.new()
	
	if parser.work(Util.extract_dir(input_file_path), Util.extract_filename(input_file_path), \
		output_file_path, "res://addons/protobuf/protobuf_core.gd"):
		show_dialog($SuccessAcceptDialog)
	else:
		show_dialog($FailAcceptDialog)
	
	file.close()
	
	return
