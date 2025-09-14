# BSD 3-Clause License
#
# Copyright (c) 2018, Oleg Malyavkin
# All rights reserved.

extends SceneTree

var Parser = preload("res://addons/protobuf/parser.gd")
var Util = preload("res://addons/protobuf/protobuf_util.gd")

func error(msg : String):
	push_error(msg)
	quit()

func _init():
	var arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]

	if !arguments.has("input") || !arguments.has("output"):
		error("Expected 2 Parameters: input and output")

	var input_file_name = arguments["input"]
	var output_file_name = arguments["output"]

	var file = FileAccess.open(input_file_name, FileAccess.READ)
	if file == null:
		error("File: '" + input_file_name + "' not found.")

	var parser = Parser.new()

	if parser.work(Util.extract_dir(input_file_name), Util.extract_filename(input_file_name), \
		output_file_name, "res://addons/protobuf/protobuf_core.gd"):
		print("Compiled '", input_file_name, "' to '", output_file_name, "'.")
	else:
		error("Compilation failed.")

	quit()
