@tool
class_name ExportFullscreen
extends EditorPlugin

## Plugin that automatically sets window mode to exclusive fullscreen during export,
## then reverts to the original mode after export completes. Also strips the
## autoloads injected by the godot_mcp editor plugin for the duration of the
## export, so exported builds neither run the MCP services nor error on the
## addon scripts excluded via the export filters.

const WINDOW_MODE_SETTING: String = "display/window/size/mode"
const WINDOW_MODE_WINDOWED: int = 0
const WINDOW_MODE_EXCLUSIVE_FULLSCREEN: int = 4

var _exporter: ExportFullscreenExporter

func _enter_tree() -> void:
	_exporter = ExportFullscreenExporter.new()
	add_export_plugin(_exporter)


func _exit_tree() -> void:
	# Ensure we restore settings if plugin is disabled during export
	if _exporter and _exporter._original_mode != -1:
		_exporter._restore_window_mode()
	if _exporter:
		_exporter._restore_mcp_autoloads()

	remove_export_plugin(_exporter)


class ExportFullscreenExporter extends EditorExportPlugin:
	const MCP_ADDON_PREFIX: String = "res://addons/godot_mcp/"

	var _original_mode: int = -1  # -1 means not currently exporting
	# Autoload settings (key -> original value) stripped for the export.
	var _stripped_autoloads: Dictionary = {}

	func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
		# Safety check: if we have a stored value, something went wrong in previous export
		if _original_mode != -1:
			push_warning("ExportFullscreen: Previous export didn't complete cleanly, resetting state")
			_restore_window_mode()
		if not _stripped_autoloads.is_empty():
			push_warning("ExportFullscreen: Previous export left MCP autoloads stripped, restoring first")
			_restore_mcp_autoloads()

		# Store current window mode (defaults to 0 if not set)
		_original_mode = ProjectSettings.get_setting(WINDOW_MODE_SETTING, WINDOW_MODE_WINDOWED)

		# Set to exclusive fullscreen for export
		ProjectSettings.set_setting(WINDOW_MODE_SETTING, WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

		_strip_mcp_autoloads()

		var err: Error = ProjectSettings.save()
		if err != OK:
			push_error("ExportFullscreen: Failed to save project settings. Error: %s" % error_string(err))
		else:
			print("ExportFullscreen: Set window mode to exclusive fullscreen for export (original: %d)" % _original_mode)


	func _export_end() -> void:
		_restore_window_mode()
		_restore_mcp_autoloads()


	# Remove every autoload whose script lives in the godot_mcp addon (the plugin
	# injects MCPScreenshot/MCPInputService/MCPGameInspector at editor start).
	# Exported builds must not reference them: the addon is excluded from the pck
	# by the export filters, and a missing autoload script errors at boot.
	# Originals are kept for _restore_mcp_autoloads.
	func _strip_mcp_autoloads() -> void:
		for prop: Dictionary in ProjectSettings.get_property_list():
			var key: String = prop.name
			if not key.begins_with("autoload/"):
				continue
			var value: Variant = ProjectSettings.get_setting(key)
			if value is String and (value as String).trim_prefix("*").begins_with(MCP_ADDON_PREFIX):
				_stripped_autoloads[key] = value
				ProjectSettings.set_setting(key, null)

		if not _stripped_autoloads.is_empty():
			print("ExportFullscreen: Stripped MCP autoloads for export: %s" % ", ".join(PackedStringArray(_stripped_autoloads.keys())))


	# Re-add the MCP autoloads removed by _strip_mcp_autoloads.
	func _restore_mcp_autoloads() -> void:
		if _stripped_autoloads.is_empty():
			return

		for key: String in _stripped_autoloads.keys():
			ProjectSettings.set_setting(key, _stripped_autoloads[key])
		_stripped_autoloads.clear()

		var err: Error = ProjectSettings.save()
		if err != OK:
			push_error("ExportFullscreen: Failed to restore MCP autoloads. Error: %s" % error_string(err))
		else:
			print("ExportFullscreen: Restored MCP autoloads")


	func _restore_window_mode() -> void:
		# Only restore if we have a stored value
		if _original_mode == -1:
			return

		# Restore original mode
		ProjectSettings.set_setting(WINDOW_MODE_SETTING, _original_mode)

		var err: Error = ProjectSettings.save()
		if err != OK:
			push_error("ExportFullscreen: Failed to restore window mode. Error: %s" % error_string(err))
		else:
			print("ExportFullscreen: Restored window mode to %d" % _original_mode)

		# Reset state
		_original_mode = -1
