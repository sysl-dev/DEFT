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


function love.draw()

end
