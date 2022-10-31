@tool
class_name DrawSpacedString
extends Object

var font: Font
var font_size: int
var color: Color
var string: String
var spacing: float
var max_width: float
var h_align: int

var string_size: Vector2
var size: Vector2
var words: Array
var lines: Array = []

var _spacing_factor: float:
	get: return spacing if spacing > 0 else 0.0


func _init(font_val: Font, font_size_val: int, color_val: Color, string_val: String, spacing_val: float, h_align_val := 0, max_width_val := -1.0) -> void:
	font = font_val
	font_size = font_size_val
	color = color_val
	string = string_val
	spacing = spacing_val
	h_align = h_align_val
	max_width = max_width_val


func draw_at(parent: CanvasItem, draw_pos: Vector2) -> void:
	_update_member_vars()
	var pos := draw_pos + Vector2(0, font_size)
	if spacing > 0:
		for line in lines:
			for i in range(len(line)):
				var c: String = line[i]
				var char_pos := _get_char_pos_of(line, i)
				parent.draw_char(font, pos + char_pos, c, font_size, color)
			pos.y += font_size * 1.6
	else:
		parent.draw_multiline_string(font, pos, string, 0, max_width, font_size, -1, color)


func _get_char_pos_of(line: String, index: int) -> Vector2:
	var s := font.get_string_size(line.substr(0, index), h_align, -1, font_size)
	return Vector2(s.x + spacing * (index as float), 0)


func _update_member_vars() -> void:
	words = string.split(" ")
	
	lines = []
	var curr_line_length := 0.0
	var curr_line := 0
	
	for i in range(len(words)):
		var word: String = words[i]
		if i == 0: 
			lines.append(word)
			continue
		var word_size := _get_size_of_string(word)
		if (curr_line_length + word_size.x) > max_width:
			curr_line += 1
			curr_line_length = word_size.x
			lines.append(word)
		else:
			curr_line_length += word_size.x
			lines[curr_line] += " " + word
	
	size = _get_full_size()


func _get_size_of_string(string_val: String) -> Vector2:
	return font.get_string_size(
		string_val, 
		h_align,
		-1,
		font_size,
	) + Vector2((len(string_val) - 1 as float) * _spacing_factor, 0)


func _get_full_size() -> Vector2:
	if len(lines) > 0: return (
		Iter
			.new(lines)
			.map(func (line: String) -> Vector2:
				return _get_size_of_string(line))
			.array()
			.reduce(func (prev: Vector2, curr: Vector2) -> Vector2:
				if prev.x < curr.x: prev.x = curr.x
				prev.y += curr.y
				return prev)
	)
	else: return Vector2.ZERO
