extends SceneTree

# Real graphical rendering is required. Never run this script with --headless.
var output_dir: String = ""
var results: Array[Dictionary] = []
var errors: int = 0

func _initialize() -> void:
    call_deferred("_play")

func _play() -> void:
    var args := OS.get_cmdline_user_args()
    output_dir = args[0] if args.size() > 0 else ProjectSettings.globalize_path("res://visual-artifacts")
    DirAccess.make_dir_recursive_absolute(output_dir)
    var packed: PackedScene = load("res://main.tscn")
    if packed == null:
        _record("Load main.tscn", false)
        _finish()
        return
    var game := packed.instantiate() as Node2D
    if game == null:
        _record("Instantiate main scene", false)
        _finish()
        return
    root.add_child(game)
    current_scene = game
    await _frames(45)
    _record("Main scene started", game.is_inside_tree())
    await _shot("01_start.png")

    var start: Vector2 = game.get("hero")
    game.set("movement_target", start + Vector2(100.0, 0.0))
    game.set("has_movement_target", true)
    for i in range(90):
        await physics_frame
    var displacement: float = start.distance_to(game.get("hero"))
    _record("Hero moves", displacement > 10.0)
    await _shot("02_after_move.png")

    _key(KEY_K)
    await _frames(12)
    var menu: Control = game.get("menu") as Control
    _record("Crafting menu opens", menu != null and menu.visible)
    await _shot("03_craft.png")

    # Crafting fixtures: this does not test gathering wood/fiber in the world.
    if menu != null:
        game.set("wood", 3)
        game.call("_refresh_ui")
        await _frames(5)
        var recipes: Dictionary = menu.get("recipe_buttons")
        if recipes.has("club"):
            var button: Button = recipes["club"] as Button
            _mouse_click(button.get_global_rect().get_center())
            await _frames(12)
            _record("Craft club by clicking UI", bool(game.get("has_club")))
        else:
            _record("Club recipe button exists", false)
        await _shot("04_club.png")

        game.set("fiber", 2)
        game.call("_refresh_ui")
        await _frames(5)
        if recipes.has("sleeveless"):
            var shirt: Button = recipes["sleeveless"] as Button
            _mouse_click(shirt.get_global_rect().get_center())
            await _frames(12)
            _record("Craft sleeveless by clicking UI", bool(game.get("has_sleeveless")))
        else:
            _record("Sleeveless recipe button exists", false)
        await _shot("05_clothes.png")
    _finish()

func _frames(count: int) -> void:
    for i in range(count):
        await process_frame

func _record(label: String, success: bool) -> void:
    results.append({"name": label, "passed": success})
    if not success:
        errors += 1
        push_error("FAILED: " + label)
    else:
        print("PASSED: " + label)

func _shot(filename: String) -> void:
    await process_frame
    await RenderingServer.frame_post_draw
    var img := root.get_texture().get_image()
    if img.is_empty():
        _record("Screenshot " + filename, false)
        return
    var status := img.save_png(output_dir.path_join(filename))
    _record("Screenshot " + filename, status == OK)

func _key(key: Key) -> void:
    var down := InputEventKey.new()
    down.keycode = key
    down.physical_keycode = key
    down.pressed = true
    Input.parse_input_event(down)
    var up := InputEventKey.new()
    up.keycode = key
    up.physical_keycode = key
    up.pressed = false
    Input.parse_input_event(up)

func _mouse_click(position: Vector2) -> void:
    var motion := InputEventMouseMotion.new()
    motion.position = position
    motion.global_position = position
    Input.parse_input_event(motion)
    var down := InputEventMouseButton.new()
    down.position = position
    down.global_position = position
    down.button_index = MOUSE_BUTTON_LEFT
    down.button_mask = MOUSE_BUTTON_MASK_LEFT
    down.pressed = true
    Input.parse_input_event(down)
    var up := InputEventMouseButton.new()
    up.position = position
    up.global_position = position
    up.button_index = MOUSE_BUTTON_LEFT
    up.pressed = false
    Input.parse_input_event(up)

func _finish() -> void:
    var report := {
        "game": "Pustosh V6",
        "godot": Engine.get_version_info().get("string", "unknown"),
        "display": DisplayServer.get_name(),
        "tests": results,
        "passed": errors == 0
    }
    var f := FileAccess.open(output_dir.path_join("playtest_report.json"), FileAccess.WRITE)
    if f != null:
        f.store_string(JSON.stringify(report, "  "))
        f.close()
    quit(0 if errors == 0 else 1)
