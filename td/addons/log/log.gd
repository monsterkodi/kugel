
@tool
extends Object
class_name Log

static func assoc(opts: Dictionary, key: String, val: Variant) -> Dictionary:
    var _opts: Dictionary = opts.duplicate(true)
    _opts[key] = val
    return _opts

static func initialize_setting(key: String, default_value: Variant, type: int, hint: int = PROPERTY_HINT_NONE, hint_string: String = ""):
    if not ProjectSettings.has_setting(key):
        ProjectSettings.set(key, default_value)
    ProjectSettings.set_initial_value(key, default_value)
    ProjectSettings.add_property_info({name=key, type=type, hint=hint, hint_string=hint_string})

static func get_setting(key: String) -> Variant:
    if ProjectSettings.has_setting(key):
        return ProjectSettings.get_setting(key)
    return

const KEY_PREFIX: String = "log_gd/config"
static var is_config_setup: bool = false
static var nil: String = "NIL"
const KEY_COLOR_THEME_DICT: String = "log_color_theme_dict"
const KEY_COLOR_THEME_RESOURCE_PATH: String = "%s/color_resource_path" % KEY_PREFIX
const KEY_DISABLE_COLORS: String = "%s/disable_colors" % KEY_PREFIX
const KEY_MAX_ARRAY_SIZE: String = "%s/max_array_size" % KEY_PREFIX
const KEY_SKIP_KEYS: String = "%s/dictionary_skip_keys" % KEY_PREFIX

const CONFIG_DEFAULTS := {
        KEY_COLOR_THEME_RESOURCE_PATH: "res://addons/log/color_theme_dark.tres",
        KEY_DISABLE_COLORS: false,
        KEY_MAX_ARRAY_SIZE: 20,
        KEY_SKIP_KEYS: ["layer_0/tile_data"],
    }

static func setup_settings(opts: Dictionary = {}):
    initialize_setting(KEY_COLOR_THEME_RESOURCE_PATH, CONFIG_DEFAULTS[KEY_COLOR_THEME_RESOURCE_PATH], TYPE_STRING, PROPERTY_HINT_FILE)
    initialize_setting(KEY_DISABLE_COLORS, CONFIG_DEFAULTS[KEY_DISABLE_COLORS], TYPE_BOOL)
    initialize_setting(KEY_MAX_ARRAY_SIZE, CONFIG_DEFAULTS[KEY_MAX_ARRAY_SIZE], TYPE_BOOL)
    initialize_setting(KEY_SKIP_KEYS, CONFIG_DEFAULTS[KEY_SKIP_KEYS], TYPE_PACKED_STRING_ARRAY)

static var config: Dictionary = {}
static func rebuild_config(opts: Dictionary = {}):
    for key: String in CONFIG_DEFAULTS.keys():
        var val: Variant = get_setting(key)
        if val == null:
            val = CONFIG_DEFAULTS[key]

        Log.config[key] = val

        if val != null and key == KEY_COLOR_THEME_RESOURCE_PATH:
            Log.config[KEY_COLOR_THEME_DICT] = load(val).to_color_dict()

    Log.is_config_setup = true

static func get_max_array_size() -> int:
    return Log.config.get(KEY_MAX_ARRAY_SIZE, CONFIG_DEFAULTS[KEY_MAX_ARRAY_SIZE])

static func get_dictionary_skip_keys() -> Array:
    return Log.config.get(KEY_SKIP_KEYS, CONFIG_DEFAULTS[KEY_SKIP_KEYS])

static func get_disable_colors() -> bool:
    return Log.config.get(KEY_DISABLE_COLORS, CONFIG_DEFAULTS[KEY_DISABLE_COLORS])

static var warned_about_termsafe_fallback := false
static func get_config_color_theme() -> Dictionary:
    var color_dict = Log.config.get(KEY_COLOR_THEME_DICT)
    if color_dict != null:
        return color_dict
    if not warned_about_termsafe_fallback:
        print("Falling back to TERM_SAFE colors")
        warned_about_termsafe_fallback = true
    return LogColorTheme.COLORS_TERM_SAFE

static func disable_colors():
    Log.config[KEY_DISABLE_COLORS] = true

static func enable_colors():
    Log.config[KEY_DISABLE_COLORS] = false

static func set_colors_termsafe():
    Log.config[KEY_COLOR_THEME_DICT] = LogColorTheme.COLORS_TERM_SAFE

static func set_colors_pretty():
    var theme_path: Variant = Log.config.get(KEY_COLOR_THEME_RESOURCE_PATH)
    if theme_path != null:
        Log.config[KEY_COLOR_THEME_DICT] = load(theme_path).to_color_dict()
    else:
        print("WARNING no color theme resource path to load!")

static func should_use_color(opts: Dictionary = {}) -> bool:
    if OS.has_feature("ios") or OS.has_feature("web"):
        return false
    if Log.get_disable_colors():
        return false
    if opts.get("disable_colors", false):
        return false
    return true

static func color_wrap(s: Variant, opts: Dictionary = {}) -> String:
    var colors: Dictionary = get_config_color_theme()

    if not should_use_color(opts):
        return str(s)

    var color: Variant = opts.get("color", "")
    if color == null or (color is String and color == ""):
        var s_type: Variant = opts.get("typeof", typeof(s))
        if s_type is String:
            color = colors.get(s_type)
        elif s_type is int and s_type == TYPE_STRING:
            var s_trimmed: String = str(s).strip_edges()
            if s_trimmed in colors:
                color = colors.get(s_trimmed)
            else:
                color = colors.get(s_type)
        else:
            color = colors.get(s_type)

    if color is String and color == "" or color == null:
        print("Log.gd could not determine color for object: %s type: (%s)" % [str(s), typeof(s)])

    if color is Array:
        if opts.get("typeof", "") in ["dict_key"]:
            color = color[opts.get("delimiter_index", 0) - 1 % len(color)]
        else:
            color = color[opts.get("delimiter_index", 0) % len(color)]

    if color is Color:
        color = color.to_html(false)

    return "[color=%s]%s[/color]" % [color, s]

static var type_overwrites: Dictionary = {}

static func register_type_overwrite(key: String, handler: Callable):
    type_overwrites[key] = handler

static func register_type_overwrites(overwrites: Dictionary):
    type_overwrites.merge(overwrites, true)

static func clear_type_overwrites():
    type_overwrites = {}

static func to_pretty(msg: Variant, opts: Dictionary = {}) -> String:
    var newlines: bool = opts.get("newlines", false)
    var indent_level: int = opts.get("indent_level", 0)
    var delimiter_index: int = opts.get("delimiter_index", 0)
    if not "indent_level" in opts:
        opts["indent_level"] = indent_level

    if not "delimiter_index" in opts:
        opts["delimiter_index"] = delimiter_index

    if not is_instance_valid(msg) and typeof(msg) == TYPE_OBJECT:
        return str("invalid instance: ", msg)

    if msg == null:
        return Log.color_wrap(msg, opts)

    if msg is Object and (msg as Object).get_class() in type_overwrites:
        var fn: Callable = type_overwrites.get((msg as Object).get_class())
        return Log.to_pretty(fn.call(msg), opts)
    elif typeof(msg) in type_overwrites:
        var fn: Callable = type_overwrites.get(typeof(msg))
        return Log.to_pretty(fn.call(msg), opts)

    if msg is Object and (msg as Object).has_method("to_pretty"):
        return Log.to_pretty((msg as Object).call("to_pretty"), opts)
    if msg is Object and (msg as Object).has_method("data"):
        return Log.to_pretty((msg as Object).call("data"), opts)

    if msg is Array or msg is PackedStringArray:
        var msg_array: Array = msg
        if len(msg) > Log.get_max_array_size():
            pr("[DEBUG]: truncating large array. total:", len(msg))
            msg_array = msg_array.slice(0, Log.get_max_array_size() - 1)
            if newlines:
                msg_array.append("...")

        var tmp: String = Log.color_wrap("[ ", opts)
        opts["delimiter_index"] += 1
        var last: int = len(msg) - 1
        for i: int in range(len(msg)):
            if newlines and last > 1:
                tmp += "\n\t"
            tmp += Log.to_pretty(msg[i],
                # duplicate here to prevent indenting-per-msg
                # e.g. when printing an array of dictionaries
                opts.duplicate(true))
            if i != last:
                tmp += Log.color_wrap(", ", opts)
        opts["delimiter_index"] -= 1
        tmp += Log.color_wrap(" ]", opts)
        return tmp

    elif msg is Dictionary:
        var tmp: String = Log.color_wrap("{ ", opts)
        opts["delimiter_index"] += 1
        var ct: int = len(msg)
        var last: Variant
        if len(msg) > 0:
            last = (msg as Dictionary).keys()[-1]
        var indent_updated = false
        for k: Variant in (msg as Dictionary).keys():
            var val: Variant
            if k in Log.get_dictionary_skip_keys():
                val = "..."
            else:
                if not indent_updated:
                    indent_updated = true
                    opts["indent_level"] += 1
                val = Log.to_pretty(msg[k], opts)
            if newlines and ct > 1:
                tmp += "\n\t" \
                    + range(indent_level)\
                    .map(func(_i: int) -> String: return "\t")\
                    .reduce(func(a: String, b: Variant) -> String: return str(a, b), "")
            var key: String = Log.color_wrap('"%s"' % k, Log.assoc(opts, "typeof", "dict_key"))
            tmp += "%s: %s" % [key, val]
            if last and str(k) != str(last):
                tmp += Log.color_wrap(", ", opts)
        opts["delimiter_index"] -= 1
        tmp += Log.color_wrap(" }", opts)
        opts["indent_level"] -= 1 # ugh! updating the dict in-place
        return tmp

    elif msg is String:
        if msg == "":
            return '""'
        if "[color=" in msg and "[/color]" in msg:
            return msg
        return Log.color_wrap(msg, opts)
    elif msg is StringName:
        return str(Log.color_wrap("&", opts), '"%s"' % msg)
    elif msg is NodePath:
        return str(Log.color_wrap("^", opts), '"%s"' % msg)

    elif msg is Color:
        return Log.color_wrap(msg.to_html(), Log.assoc(opts, "typeof", TYPE_COLOR))

    elif msg is Vector2 or msg is Vector2i:
        return '%s%s%s%s%s' % [
            Log.color_wrap("(", opts),
            Log.color_wrap(msg.x, Log.assoc(opts, "typeof", "vector_value")),
            Log.color_wrap(",", opts),
            Log.color_wrap(msg.y, Log.assoc(opts, "typeof", "vector_value")),
            Log.color_wrap(")", opts),
        ]

    elif msg is Vector3 or msg is Vector3i:
        return '%s%s%s%s%s%s%s' % [
            Log.color_wrap("(", opts),
            Log.color_wrap(msg.x, Log.assoc(opts, "typeof", "vector_value")),
            Log.color_wrap(",", opts),
            Log.color_wrap(msg.y, Log.assoc(opts, "typeof", "vector_value")),
            Log.color_wrap(",", opts),
            Log.color_wrap(msg.z, Log.assoc(opts, "typeof", "vector_value")),
            Log.color_wrap(")", opts),
            ]
    elif msg is Vector4 or msg is Vector4i:
        return '%s%s%s%s%s%s%s%s%s' % [
            Log.color_wrap("(", opts),
            Log.color_wrap(msg.x, Log.assoc(opts, "typeof", "vector_value")),
            Log.color_wrap(",", opts),
            Log.color_wrap(msg.y, Log.assoc(opts, "typeof", "vector_value")),
            Log.color_wrap(",", opts),
            Log.color_wrap(msg.z, Log.assoc(opts, "typeof", "vector_value")),
            Log.color_wrap(",", opts),
            Log.color_wrap(msg.w, Log.assoc(opts, "typeof", "vector_value")),
            Log.color_wrap(")", opts),
            ]

    elif msg is PackedScene:
        var msg_ps: PackedScene = msg
        if msg_ps.resource_path != "":
            return str(Log.color_wrap("PackedScene:", opts), '%s' % msg_ps.resource_path.get_file())
        elif msg_ps.get_script() != null and msg_ps.get_script().resource_path != "":
            var path: String = msg_ps.get_script().resource_path
            return Log.color_wrap(path.get_file(), Log.assoc(opts, "typeof", "class_name"))
        else:
            return Log.color_wrap(msg_ps, opts)

    elif msg is Resource:
        var msg_res: Resource = msg
        if msg_res.get_script() != null and msg_res.get_script().resource_path != "":
            var path: String = msg_res.get_script().resource_path
            return Log.color_wrap(path.get_file(), Log.assoc(opts, "typeof", "class_name"))
        elif msg_res.resource_path != "":
            var path: String = msg_res.resource_path
            return str(Log.color_wrap("Resource:", opts), '%s' % path.get_file())
        else:
            return Log.color_wrap(msg_res, opts)

    elif msg is RefCounted:
        var msg_ref: RefCounted = msg
        if msg_ref.get_script() != null and msg_ref.get_script().resource_path != "":
            var path: String = msg_ref.get_script().resource_path
            return Log.color_wrap(path.get_file(), Log.assoc(opts, "typeof", "class_name"))
        else:
            return Log.color_wrap(msg_ref.get_class(), Log.assoc(opts, "typeof", "class_name"))

    else:
        return Log.color_wrap(msg, opts)

static func log_prefix(stack: Array) -> String:
    if len(stack) > 1:
        var call_site: Dictionary = stack[1]
        var call_site_source: String = call_site.get("source", "")
        var basename: String = call_site_source.get_file().get_basename()
        var line_num: String = str(call_site.get("line", 0))
        
        #var url_prefix: String = "[url=" + ProjectSettings.globalize_path(call_site_source) + "]"
        var url_prefix: String = "[url=" + JSON.stringify({"src":call_site_source, "line":line_num}) + "]"
        var url_postfix: String = "[/url]"

        if call_site_source.match("*/test/*"):
            return "{" + url_prefix + basename + ":" + line_num + url_postfix + "}: "
        elif call_site_source.match("*/addons/*"):
            return "<" + url_prefix + basename + ":" + line_num + url_postfix + ">: "
        else:
            return url_prefix + basename + ":" + line_num + url_postfix + " "
            
    return ""

static func to_printable(msgs: Array, opts: Dictionary = {}) -> String:
    if not Log.is_config_setup:
        rebuild_config()

    if not msgs is Array:
        msgs = [msgs]
    var stack: Array = opts.get("stack", [])
    var pretty: bool = opts.get("pretty", true)
    var m: String = ""
    if len(stack) > 0:
        var prefix: String = Log.log_prefix(stack)
        var prefix_type: String = "SRC"
        if prefix != null and prefix[0] == "{":
            prefix_type = "TEST"
        elif prefix != null and prefix[0] == "<":
            prefix_type = "ADDONS"
        if pretty:
            m += Log.color_wrap(prefix, Log.assoc(opts, "typeof", prefix_type))
        else:
            m += prefix
    for msg: Variant in msgs:
        # add a space between msgs
        if pretty:
            m += "%s " % Log.to_pretty(msg, opts)
        else:
            m += "%s " % str(msg)
    return m.trim_suffix(" ")

static func not_nil(v: Variant) -> bool:
    return not v is String or v != Log.nil

static func pr(msg: Variant, msg2: Variant = Log.nil, msg3: Variant = Log.nil, msg4: Variant = Log.nil, msg5: Variant = Log.nil, msg6: Variant = Log.nil, msg7: Variant = Log.nil):
    var msgs: Array = [msg, msg2, msg3, msg4, msg5, msg6, msg7]
    msgs = msgs.filter(Log.not_nil)
    var m: String = Log.to_printable(msgs, {stack=get_stack()})
    print_rich(m)

static func info(msg: Variant, msg2: Variant = Log.nil, msg3: Variant = Log.nil, msg4: Variant = Log.nil, msg5: Variant = Log.nil, msg6: Variant = Log.nil, msg7: Variant = Log.nil):
    print_rich(Log.to_printable([msg, msg2, msg3, msg4, msg5, msg6, msg7].filter(Log.not_nil), {stack=get_stack()}))

static func log(msg: Variant, msg2: Variant = Log.nil, msg3: Variant = Log.nil, msg4: Variant = Log.nil, msg5: Variant = Log.nil, msg6: Variant = Log.nil, msg7: Variant = Log.nil):
    var msgs: Array = [msg, msg2, msg3, msg4, msg5, msg6, msg7]
    msgs = msgs.filter(Log.not_nil)
    var m: String = Log.to_printable(msgs, {stack=get_stack()})
    print_rich(m)

static func prn(msg: Variant, msg2: Variant = Log.nil, msg3: Variant = Log.nil, msg4: Variant = Log.nil, msg5: Variant = Log.nil, msg6: Variant = Log.nil, msg7: Variant = Log.nil):
    var msgs: Array = [msg, msg2, msg3, msg4, msg5, msg6, msg7]
    msgs = msgs.filter(Log.not_nil)
    var m: String = Log.to_printable(msgs, {stack=get_stack(), newlines=true})
    print_rich(m)
    
static func lvl(level:int, msg: Variant, msg2: Variant = Log.nil, msg3: Variant = Log.nil, msg4: Variant = Log.nil, msg5: Variant = Log.nil, msg6: Variant = Log.nil, msg7: Variant = Log.nil):
    #var msgs: Array = [msg, msg2, msg3, msg4, msg5, msg6, msg7]
    #msgs = msgs.filter(Log.not_nil)
    var stack: Array = get_stack()
    for i in level:
        stack.pop_front()
    #var m: String = Log.to_printable(msgs, {stack=stack, newlines=true})
    #print_rich(m)
    print_rich(Log.to_printable([msg, msg2, msg3, msg4, msg5, msg6, msg7].filter(Log.not_nil), {stack=stack, newlines=true}))

static func warn(msg: Variant, msg2: Variant = Log.nil, msg3: Variant = Log.nil, msg4: Variant = Log.nil, msg5: Variant = Log.nil, msg6: Variant = Log.nil, msg7: Variant = Log.nil):
    var msgs: Array = [msg, msg2, msg3, msg4, msg5, msg6, msg7]
    msgs = msgs.filter(Log.not_nil)
    var rich_msgs: Array = msgs.duplicate()
    rich_msgs.push_front("[color=yellow][WARN][/color]")
    print_rich(Log.to_printable(rich_msgs, {stack=get_stack(), newlines=true}))
    var m: String = Log.to_printable(msgs, {stack=get_stack(), newlines=true, pretty=false})
    push_warning(m)

## Like [code]Log.prn()[/code], but prepends a "[TODO]" and calls push_warning() with the pretty string.
static func todo(msg: Variant, msg2: Variant = Log.nil, msg3: Variant = Log.nil, msg4: Variant = Log.nil, msg5: Variant = Log.nil, msg6: Variant = Log.nil, msg7: Variant = Log.nil):
    var msgs: Array = [msg, msg2, msg3, msg4, msg5, msg6, msg7]
    msgs = msgs.filter(Log.not_nil)
    msgs.push_front("[TODO]")
    var rich_msgs: Array = msgs.duplicate()
    rich_msgs.push_front("[color=yellow][WARN][/color]")
    print_rich(Log.to_printable(rich_msgs, {stack=get_stack(), newlines=true}))
    var m: String = Log.to_printable(msgs, {stack=get_stack(), newlines=true, pretty=false})
    push_warning(m)

## Like [code]Log.prn()[/code], but also calls push_error() with the pretty string.
static func err(msg: Variant, msg2: Variant = Log.nil, msg3: Variant = Log.nil, msg4: Variant = Log.nil, msg5: Variant = Log.nil, msg6: Variant = Log.nil, msg7: Variant = Log.nil):
    var msgs: Array = [msg, msg2, msg3, msg4, msg5, msg6, msg7]
    msgs = msgs.filter(Log.not_nil)
    var rich_msgs: Array = msgs.duplicate()
    rich_msgs.push_front("[color=red][ERR][/color]")
    print_rich(Log.to_printable(rich_msgs, {stack=get_stack(), newlines=true}))
    var m: String = Log.to_printable(msgs, {stack=get_stack(), newlines=true, pretty=false})
    push_error(m)

## Like [code]Log.prn()[/code], but also calls push_error() with the pretty string.
static func error(msg: Variant, msg2: Variant = Log.nil, msg3: Variant = Log.nil, msg4: Variant = Log.nil, msg5: Variant = Log.nil, msg6: Variant = Log.nil, msg7: Variant = Log.nil):
    var msgs: Array = [msg, msg2, msg3, msg4, msg5, msg6, msg7]
    msgs = msgs.filter(Log.not_nil)
    var rich_msgs: Array = msgs.duplicate()
    rich_msgs.push_front("[color=red][ERR][/color]")
    print_rich(Log.to_printable(rich_msgs, {stack=get_stack(), newlines=true}))
    var m: String = Log.to_printable(msgs, {stack=get_stack(), newlines=true, pretty=false})
    push_error(m)


## Helper that will both print() and print_rich() the enriched string
static func _internal_debug(msg: Variant, msg2: Variant = Log.nil, msg3: Variant = Log.nil, msg4: Variant = Log.nil, msg5: Variant = Log.nil, msg6: Variant = Log.nil, msg7: Variant = Log.nil):
    var msgs: Array = [msg, msg2, msg3, msg4, msg5, msg6, msg7]
    msgs = msgs.filter(Log.not_nil)
    var m: String = Log.to_printable(msgs, {stack=get_stack()})
    print("_internal_debug: ", m)
    print_rich(m)
