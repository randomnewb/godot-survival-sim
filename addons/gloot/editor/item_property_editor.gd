extends EditorProperty

const GridConstraint = preload("res://addons/gloot/constraints/grid_constraint.gd")
const DictEditor = preload("res://addons/gloot/editor/dict_editor.tscn")
const EditorIcons = preload("res://addons/gloot/editor/editor_icons.gd")
const COLOR_OVERRIDDEN = Color.GREEN
const COLOR_INVALID = Color.RED
const POPUP_SIZE = Vector2i(800, 300)
const POPUP_MIN_SIZE = Vector2i(400, 200)
const POPUP_MARGIN = 10
var IMMUTABLE_KEYS: Array[String] = [ItemProtoset.KEY_ID, GridConstraint.KEY_GRID_POSITION]

var _dict_editor: Control
var current_value: Dictionary
var updating: bool = false
var gloot_undo_redo = null
var editor_interface: EditorInterface
var _window_dialog: Window
var _btn_prototype_id: Button


func _init():
    _dict_editor = DictEditor.instantiate()
    _dict_editor.value_changed.connect(Callable(self, "_on_value_changed"))
    _dict_editor.value_removed.connect(Callable(self, "_on_value_removed"))

    _window_dialog = Window.new()
    _window_dialog.title = "Edit Item Properties"
    _window_dialog.unresizable = false
    _window_dialog.size = POPUP_SIZE
    _window_dialog.min_size = POPUP_MIN_SIZE
    _window_dialog.close_requested.connect(func(): _window_dialog.hide())
    _window_dialog.visible = false
    _window_dialog.exclusive = true
    add_child(_window_dialog)

    var _margin_container = MarginContainer.new()
    _margin_container.offset_bottom = -POPUP_MARGIN
    _margin_container.offset_left = POPUP_MARGIN
    _margin_container.offset_right = -POPUP_MARGIN
    _margin_container.offset_top = POPUP_MARGIN
    _margin_container.size_flags_horizontal = SIZE_EXPAND_FILL
    _margin_container.size_flags_vertical = SIZE_EXPAND_FILL
    _margin_container.anchor_bottom = 1.0
    _margin_container.anchor_right = 1.0
    _margin_container.add_child(_dict_editor)
    _window_dialog.add_child(_margin_container)

    _btn_prototype_id = Button.new()
    _btn_prototype_id.text = "Edit Properties"
    _btn_prototype_id.pressed.connect(Callable(self, "_on_btn_edit"))
    add_child(_btn_prototype_id)


func _ready() -> void:
    _btn_prototype_id.icon = EditorIcons.get_icon(editor_interface, "Edit")

    var item: InventoryItem = get_edited_object()
    if !item:
        return
    item.properties_changed.connect(Callable(self, "update_property"))

    if !item.protoset:
        return
    item.protoset.changed.connect(Callable(self, "_on_protoset_changed"))

    _refresh_button()
    _refresh_dict_editor()


func _on_btn_edit() -> void:
    _window_dialog.popup_centered(POPUP_SIZE)


func _on_value_changed(key: String, new_value) -> void:
    var item: InventoryItem = get_edited_object()
    var new_properties = item.properties.duplicate()
    new_properties[key] = new_value

    var item_prototype: Dictionary = item.protoset.get_prototype(item.prototype_id)
    if item_prototype.has(key) && (item_prototype[key] == new_value):
        new_properties.erase(key)

    if new_properties.hash() == item.properties.hash():
        return

    gloot_undo_redo.set_item_properties(item, new_properties)

    _refresh_dict_editor()


func _on_value_removed(key: String) -> void:
    var item: InventoryItem = get_edited_object()
    var new_properties = item.properties.duplicate()
    new_properties.erase(key)

    _refresh_dict_editor()
    if new_properties.hash() == item.properties.hash():
        return

    gloot_undo_redo.set_item_properties(item, new_properties)


func update_property() -> void:
    var new_value = get_edited_object()[get_edited_property()]
    if new_value == current_value:
        return

    updating = true
    current_value = new_value
    _refresh_dict_editor()
    updating = false


func _on_protoset_changed() -> void:
    _refresh_dict_editor()
    _refresh_button()


func _refresh_dict_editor() -> void:
    if _dict_editor.btn_add:
        _dict_editor.btn_add.icon = EditorIcons.get_icon(editor_interface, "Add")
    _dict_editor.dictionary = _get_dictionary()
    _dict_editor.color_map = _get_color_map()
    _dict_editor.remove_button_map = _get_remove_button_map()
    _dict_editor.immutable_keys = IMMUTABLE_KEYS
    _dict_editor.refresh()


func _refresh_button() -> void:
    var item: InventoryItem = get_edited_object()
    if !item || !item.protoset:
        return
    _btn_prototype_id.disabled = !item.protoset.has_prototype(item.prototype_id)


func _get_dictionary() -> Dictionary:
    if !get_edited_object():
        return {}

    var item: InventoryItem = get_edited_object()
    if !item.protoset:
        return {}

    if !item.protoset.has_prototype(item.prototype_id):
        return {}

    var result: Dictionary = item.protoset.get_prototype(item.prototype_id).duplicate()
    for key in item.properties.keys():
        result[key] = item.properties[key]
    return result


func _get_color_map() -> Dictionary:
    if !get_edited_object():
        return {}

    var item: InventoryItem = get_edited_object()
    if !item.protoset:
        return {}

    var result: Dictionary = {}
    var dictionary: Dictionary = _get_dictionary()
    for key in dictionary.keys():
        if item.properties.has(key):
            result[key] = COLOR_OVERRIDDEN
        if key == ItemProtoset.KEY_ID && !item.protoset.has_prototype(dictionary[key]):
            result[key] = COLOR_INVALID

    return result
            

func _get_remove_button_map() -> Dictionary:
    if !get_edited_object():
        return {}

    var item: InventoryItem = get_edited_object()
    if !item.protoset:
        return {}

    var result: Dictionary = {}
    var dictionary: Dictionary = _get_dictionary()
    for key in dictionary.keys():
        result[key] = {}
        if item.protoset.get_prototype(item.prototype_id).has(key):
            result[key]["text"] = ""
            result[key]["icon"] = EditorIcons.get_icon(editor_interface, "Reload")
        else:
            result[key]["text"] = ""
            result[key]["icon"] = EditorIcons.get_icon(editor_interface, "Remove")

        result[key]["disabled"] = (not key in item.properties) or (key in IMMUTABLE_KEYS)
    return result

