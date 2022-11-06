# `mod_example`


## What this mod does

1. This mod adds an option to each pet's interaction menu, "change fave color...". 
2. Selecting "change fave color..." opens up a submenu with several color options. 
3. Selecting a color option alters the pet's favorite color.


## Why this mod exists

This mod is meant as a very simple example to demonstrate how mods are loaded and used in-game.


## Structure

### `mod.gd`

This is the mod file which is loaded into the game. This file is responsible for adding nodes into the scene tree.

### `action_item_data.json`

This is the schema that defines how the action button should look and act within the pet interaction menu.

### `on_pressed.gd`

This script contains a `run` function. It is called when any action button (where `on_pressed.run_script == "mod_example/on_pressed.gd"`) is pressed.