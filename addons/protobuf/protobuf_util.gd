# BSD 3-Clause License
#
# Copyright (c) 2018, Oleg Malyavkin
# All rights reserved.

static func extract_dir(file_path):
	var parts = file_path.split("/", false)
	parts.remove_at(parts.size() - 1)
	var path
	if file_path.begins_with("/"):
		path = "/"
	else:
		path = ""
	for part in parts:
		path += part + "/"
	return path

static func extract_filename(file_path):
	var parts = file_path.split("/", false)
	return parts[parts.size() - 1]
