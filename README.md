# DEFT
Data, Examine, Filter, Task

# About
DEFT (Data, Examine, Filter, Task) is the way that I look at all my games made in love, but in a more standarized library.

## what?
Things we want to do things with are just data in a table, we look at that table, filter and run tasks based on those filters.

## Demo
Simple demo is included that shows the names in a table once and plays a boom about every 1 second.

# Functions
## Create Deft Class
```lua
DEFT = require('DEFT')
```
This creates the class so you can use ```DEFT.new()``` to make unique DEFT boxes.
```lua
Conductor = DEFT.new()
```

## Create new Examine Queue
```lua
Conductor.examine_new("actor_watch")
```

## Remove new Examine Queue
```lua
Conductor.examine_delete("actor_watch")
```

## Run Examine Queue (under update, draw, etc)
```lua
function love.update(dt)
  -- Conductor..examine_run(string_name, data, string_sort_method, ...)
  Conductor.examine_run("actor_watch", actors, "standard", dt)
end
```
You can also call "reverse" instead of standard to walk though the data in reverse order. Good if you're removing values from the table.

## Add a Filter to Examine Queue
```lua
Conductor.examine_add_filter("actor_watch", "data_has_name")

Conductor.examine_add_filter(string_examine_name, string_filter_name)
```

## Create a new filter
```lua
local function data_has_name(data, data_value)
  if data[data_value].name then return true end
end

Conductor.filter_new("data_has_name", data_has_name)

Conductor.filter_new(string_name, function_filter)
```

## Delete a filter (remember to remove it from any Examine queues first)
```lua
Conductor.filter_delete(string_name)
```

## Add a task to a filter
```lua
Conductor.filter_add_task(string_filter_name, string_task_name)
```

## Create a task
```lua
Conductor.task_new(string_name, function_task)
```

## Delete a task
```lua
Conductor.task_delete(string_name)
```

# Example
```lua
local actors = {
{name = "bob", x=0, y=0, w=16, h=16, state="alive", timer=0},
{name = "sally", x=0, y=0, w=16, h=16, state="alive", timer=0},
{name = "bomb", x=0, y=0, w=16, h=16, state="alive", timer=0, dieon=1},
{type = "point", x=0, y=0},
}

local DEFT_SYSTEM = require('DEFT')

Conductor = DEFT_SYSTEM.new(true)


local function data_has_name(data, data_value)
  if data[data_value].name then return true end
end

local said_names = {}
local function print_names_once(data, data_value, extra_data)
  if not said_names[data[data_value].name] then
    print("Name: ", data[data_value].name)
    said_names[data[data_value].name] = true
  end
end

local function data_has_timer_and_called_bomb(data, data_value)
  local data_part = data[data_value]
  if data_part.timer and data_part.name == "bomb" and data_part.dieon then return true end
end

local function bomb_counts_up(data, data_value, extra_data)
  data[data_value].timer = data[data_value].timer + extra_data[1]
end

local function bomb_blows_up_and_resets(data, data_value, extra_data)
  local data_part = data[data_value]
  if data[data_value].timer > data_part.dieon then
    print("BOOOOOOM")
    data[data_value].timer = 0
  end
end


Conductor.examine_new("actor_watch")
Conductor.filter_new("data_has_name", data_has_name)
Conductor.task_new("print_names", print_names_once)
Conductor.examine_add_filter("actor_watch", "data_has_name")
Conductor.filter_add_task("data_has_name", "print_names")

Conductor.filter_new("data_has_timer_and_called_bomb", data_has_timer_and_called_bomb)
Conductor.examine_add_filter("actor_watch", "data_has_timer_and_called_bomb")
Conductor.task_new("bomb_counts_up", bomb_counts_up)
Conductor.task_new("bomb_blows_up_and_resets", bomb_blows_up_and_resets)

Conductor.filter_add_task("data_has_timer_and_called_bomb", "bomb_counts_up")
Conductor.filter_add_task("data_has_timer_and_called_bomb", "bomb_blows_up_and_resets")


function love.update(dt)
  Conductor.examine_run("actor_watch", actors, "standard", dt)
end

```
