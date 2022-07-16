# Stylesheet
#### A Godot addon to make adjusting UI components easier. Add CSS-like extra styles without affecting original resources.



## Description

The goal of this project is to keep themes & resources reusable AND make small adjustments whenever needed. 

The default styling tools work fine, but I found that I needed to make minor adjustments to almost every UI component, which defeats the purpose of themes & reusable theme overrides and led to lots of inconsistencies. I created Stylesheet so that I could have all styles *inherit* from a theme, but not have to *100% match* that theme.

It's also possible to create all styles entirely with the Stylesheet addon, if you prefer the syntax- every property is implemented. 

The styles created do not depend on the plugin, no harm will come from disabling/removing Stylesheet.

### Features
- Start with a base StyleBox or DynamicFont and apply styles on top, without damaging original resource
- Large built-in color palette (pulled from TailwindCSS) or add your own colors
- Built-in sizes for consistent scaling (or add your own sizes)
- Easily create preset styles 
- Apply styles to different style names with no extra code (e.g. pressed, hover, etc.)



## How to use

1. Move this plugin to your "addons" folder in your Godot project
2. Activate this plugin in your project settings
2. Edit any of the constants in `addons/stylesheet/resources/style_sheet_constants.gd` (palette, sizes, presets, fonts, and font sizes) to suit your project

### Usage options

#### StyleSheetSetter node

1. Add a StyleSheetSetter node to any scene (most likely, the child of a Control node)
2. In the inspector, set the `target_node_path` to be whichever node you'd like to style
3. Add in a `StyleBoxStyleSheet` and/or `FontStyleSheet` resource to the `stylebox_style_sheet` and `font_style_sheet` properties
4. Done! Start writing style rules (or add in a base style) and see as theme overrides get populated instantly.

#### StyleSheetMixin static script

1. Make sure your script is a `tool` script attached to a Control node

```
tool
class_name MyNode
extends Control
...
```

2. Export StyleSheet resources on the control node you'd like to style (add as many as needed)

```
export (Resource) var stylebox_style_sheet
```

3. Define `setget` methods for each StyleSheet and call the `StyleSheetMixin.setup` method when setting

```
export (Resource) var stylebox_style_sheet setget set_stylebox_style_sheet, get_stylebox_style_sheet

func set_stylebox_style_sheet(new_style_sheet: StyleBoxStyleSheet) -> void:
	stylebox_style_sheet = new_style_sheet
	StyleSheetMixin.setup(self, [stylebox_style_sheet])

...
```

4. Add StyleSheet resources to your exported variables in the editor inspector panel
5. Done! Start writing style rules (or add in a base style) and see as theme overrides get populated instantly.



## Exported variables

All variables are *optional*. Feel free to only set the ones you need.

### All StyleSheets

##### `apply_styles` String

A list of styles, separated by spaces. See the examples section to understand how to format this list. Basically equivalent to CSS's `class="..."` format with TailwindCSS classes.

##### `default_style_names` String

A list, separated by spaces, of the style names to apply all stylings to. For example, on a button, this may look like: `normal hover pressed`. This saves you the trouble of writing every style several times.

### StyleBoxStyleSheet

##### `preset` int (one of `StyleSheetConstants.StyleBoxPresets`)

This will only be helpful if you've set up some presets. See the [customization](#customization) section.

##### `base_stylebox` StyleBoxFlat

All styles will be applied on top of this stylebox, without affecting this resource. 

### FontStyleSheet

##### `preset` int (one of `StyleSheetConstants.FontPresets`)

This will only be helpful if you've set up some presets. See the [customization](#customization) section.

##### `base_font` DynamicFontData (preloaded font file)

If you don't want to specify a font in your `apply_styles` string, or if you want to use a different one than what you've set up in your constants, you should use this.

##### `base_color` Color

Similar to `base_font`, if you don't want to specify a font in your `apply_styles` string, or if you want to use a different one than what you've set up in your constants, you should use this.



## Customization

To customize any of the built in properties, edit the file `addons/stylesheet/resources/style_sheet_constants.gd`.

### Adding or editing fonts, sizes, and colors

Just add key/value pairs as needed. Feel free to remove any properties or key/value pairs that you don't need- none are necessary.

#### `sizes` & `font_sizes` Dictionary<{ String: int }>

Defines semantic strings that can be used in place of numbers wherever sizes are applicable. For example:

```
# style_sheet_constants.gd
const sizes := {
  "small": 5
}
const font_sizes := {
  "large": 48
}
# your_script.gd
var style_sheet := StyleBoxStyleSheet.new()
style_sheet.apply_styles = "content-margin_small" # would be the same as
style_sheet.apply_styles = "content-margin_5"

var font_style_sheet := FontStyleSheet.new()
font_style_sheet.apply_styles = "size_large" # would be the same as
font_style_sheet.apply_styles = "size_48" 
```

#### `fonts` Dictionary<{ String: DynamicFontData (preloaded font file) }

Defines semantic strings to use when loading font data. For example:

```
# style_sheet_constants.gd
const fonts := {
	bold = preload("res://path/to/font/OpenSans.ttf")
}
# your_script.gd
var style_sheet := FontStyleSheet.new()
style_sheet.apply_styles = "bold"
```

#### `palette` Dictionary<{ String: Dictionary<{ int: Color }> }>

Defines semantic color strings and a list of key/value pairs of shades & colors. `50` is generally the lightest color (almost white), and `900` is generally the darkest color (almost black). However, any integer works fine for any color.

```
# style_sheet_constants.gd
const palette := {
	red = {
		500: Color("#ff0000")
	}
}
# your_script.gd
var style_sheet := FontStyleSheet.new()
style_sheet.apply_styles = "color_red_500"
```

### Adding presets

1. Add a name to one of the Enums (`StyleBoxPresets` or `FontPresets`)
2. Use the enum as a key in the associated `STYLEBOX_PRESETS` or `FONT_PRESETS` dictionary
3. Use a string for the value, the same as what you would use in the [apply_styles](#apply_styles) property.



## Examples

#### StyleBoxStyleSheet

 ```
apply_styles = """
  bg_slate_600
  border_1
  border_slate_50
  bg-opacity_75
  expand-margin:sm
  content-margin_md_lg
  pressed:expand-margin_0
  pressed:bg-opacity_50
"""
 ```
>##### Will look like:
>
>###### (default stylebox):
>
>1. All styles from `base_stylebox`
>2. `bg_color = palette.slate[600]`
>3. `set_border_width_all(1)`
>4. `border_color = palette.slate[50]`
>5. `bg_color.a = (0.75)`
>6. `set_expand_margin_all(sizes.sm)`
>7. `content_margin_top = sizes.md` & `content_margin_bottom = sizes.md`
>7. `content_margin_left = sizes.lg` & `content_margin_right = sizes.lg`
>
>###### (pressed stylebox):
>1. All of the above
>2. `set_expand_margin_all(0)`
>2. `bg_color.a = 0.5`



## Roadmap

- [ ] Support all theme properties
  - [x] StyleBoxFlat
  - [ ] Font
- [ ] Support editing Themes (not just theme overrides)
- [ ] Create dock panel for easy editing (color palette picker, size editor, etc.)
- [ ] Port to Godot 4



## Known issues

- The editor interface doesn't automatically update exported fields when selecting a preset. As a workaround, just select a different node (or collapse the resource) and reopen, and the text will be there.
