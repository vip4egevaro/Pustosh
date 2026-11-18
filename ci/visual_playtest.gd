extends SceneTree
# Pustosh V7.5 GUI smoke tests. Requires a real OpenGL display.
var out_dir: String
var failures := 0
var records: Array[Dictionary] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var args := OS.get_cmdline_user_args()
    out_dir = args[0] if args.size() > 0 else ProjectSettings.globalize_path("res://visual-artifacts")
    DirAccess.make_dir_recursive_absolute(out_dir)
    var scene := load("res://main_world.tscn") as PackedScene
    if scene == null:
        _record("Load main world", false)
        _finish()
        return
    var game := scene.instantiate() as Node2D
    root.add_child(game)
    current_scene = game
    await _frames(80)
    _record("Main world starts", is_instance_valid(game) and game.is_inside_tree())
    await _capture("01_game_start.png")
    var start: Vector2 = game.hero
    game.movement_target = start + Vector2(140.0, 0.0)
    game.has_movement_target = true
    for i in range(90):
        await physics_frame
    _record("Hero moves", start.distance_to(game.hero) > 8.0)
    await _capture("02_hero_moved.png")
    _send_key(KEY_K)
    await _frames(20)
    _record("Crafting panel", game.menu != null and game.menu.visible and game.menu.active_tab == "craft")
    await _capture("03_craft_panel.png")
    # The resource amounts below are test fixtures, not proof of world gathering.
    game.wood = 30
    game.stone = 10
    game.pebbles = 10
    game.fiber = 10
    game.menu._select_craft_recipe("club")
    game.menu.refresh()
    await _frames(10)
    _record("Club craft button enabled", not game.menu.craft_action.disabled)
    game.menu.craft_action.emit_signal("pressed")
    await _frames(10)
    _record("Craft club", game.has_club)
    await _capture("04_club_crafted.png")
    game.menu._select_craft_recipe("sleeveless")
    game.menu.refresh()
    await _frames(10)
    game.menu.craft_action.emit_signal("pressed")
    await _frames(10)
    _record("Craft sleeveless", game.has_sleeveless)
    await _capture("05_clothes_crafted.png")
    _finish()

func _frames(n: int) -> void:
    for i in range(n):
        await process_frame

func _send_key(key: Key) -> void:
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

func _capture(name: String) -> void:
    await RenderingServer.frame_post_draw
    var img := root.get_texture().get_image()
    _record("Screenshot " + name, not img.is_empty() and img.save_png(out_dir.path_join(name)) == OK)

func _record(label: String, ok: bool) -> void:
    records.append({"name": label, "passed": ok})
    if not ok:
        failures += 1
    print(("PASS: " if ok else "FAIL: ") + label)

func _finish() -> void:
    var report := {"version": "Pustosh V7.5", "tests": records, "passed": failures == 0}
    var file := FileAccess.open(out_dir.path_join("report.json"), FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(report, "  "))
        file.close()
    quit(0 if failures == 0 else 1)
