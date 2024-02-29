local m = {}
function m.new(bool_error_duplicate)
  --[[----------------------------------------------------------------------------------------------------
        Create new DEFT system
  ----------------------------------------------------------------------------------------------------]]--
  local DEFT = {}
  --[[----------------------------------------------------------------------------------------------------
        Storage within system
  ----------------------------------------------------------------------------------------------------]]--
  DEFT.examine = {}                               -- has filters
  -- DEFT.examine.name = {filter, filter, filter, filter}
  DEFT.filter = {}                                -- has tasks
  -- DEFT.filter.name = {filter_function = fun, tasks = {task, task, task task}}
  DEFT.task = {}                                  -- function calls
  -- DEFT.task.name = function(data, ...) end

  --[[----------------------------------------------------------------------------------------------------
        Create new Examine Data queue
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.examine_new(string_name, string_sort_method)
    -- Error if this is a duplicate value
    if bool_error_duplicate then
      assert(type(DEFT.examine[string_name]) == "nil", "This examine was defined!")
    end
    -- Create new empty examine queue
    DEFT.examine[string_name] = {}
  end

  --[[----------------------------------------------------------------------------------------------------
        Remove Examine Data queue
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.examine_delete(string_name)
    -- Remove the examine queue
    DEFT.examine[string_name] = nil
  end

  --[[----------------------------------------------------------------------------------------------------
        Run though the Examine Data Queue
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.examine_run(string_name, data, string_sort_method, ...)
    local extra_data = {...}
    -- standard, reverse, ???
    string_sort_method = string_sort_method or "standard"

    local function process_data(data, data_selection, extra_data)
      -- Walk though each filter added to the examine queue
      for filter_current = 1, #DEFT.examine[string_name] do
        -- Select a filter
        local this_filter = DEFT.examine[string_name][filter_current]
        -- Check data selection with filter, if it passes then
        if this_filter.filter_function(data, data_selection, extra_data) then
          -- Run each task inside the filter
          for task = 1, #this_filter.tasks do
            this_filter.tasks[task](data, data_selection, extra_data)
          end
        end
      end
    end

    -- We can normally walk though the queue from 1 to end
    if string_sort_method == "standard" then
      for data_selection = 1, #data do
        process_data(data, data_selection, extra_data)
      end
    end

    -- However, if we are removing items it might be better to step backwards.
    if string_sort_method == "reverse" then
      for data_selection = #data, 1, -1 do
        process_data(data, data_selection, extra_data)
      end
    end
  end

  --[[----------------------------------------------------------------------------------------------------
        Add filter to Examine Data Queue
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.examine_add_filter(string_examine_name, string_filter_name)
    local examine_queue = DEFT.examine[string_examine_name]
    examine_queue[#examine_queue + 1] = DEFT.filter[string_filter_name]
  end

  --[[----------------------------------------------------------------------------------------------------
        Create new Filter Function
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.filter_new(string_name, function_filter)
    -- Error if this is a duplicate value
    if bool_error_duplicate then
      assert(type(DEFT.filter[string_name]) == "nil", "filter_new has been defined!")
    end
    -- Create new filter function and task queue
    DEFT.filter[string_name] = { filter_function = function_filter, tasks = {} }
  end

  --[[----------------------------------------------------------------------------------------------------
        Create new Filter Function
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.filter_delete(string_name)
    -- Remove the filter
    DEFT.filter[string_name] = { filter_function = nil, tasks = nil }
    DEFT.filter[string_name] = nil
  end

  --[[----------------------------------------------------------------------------------------------------
        Add task to Filter 
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.filter_add_task(string_filter_name, string_task_name)
    local filter_tasks = DEFT.filter[string_filter_name].tasks
    filter_tasks[#filter_tasks + 1] = DEFT.task[string_task_name]
  end
  --[[----------------------------------------------------------------------------------------------------
        Create new Task Function
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.task_new(string_name, function_task)
    -- Error if this is a duplicate value
    if bool_error_duplicate then
      assert(type(DEFT.task[string_name]) == "nil", "This task has been defined!")
    end
    -- Create new filter function and task queue
    DEFT.task[string_name] = function_task
  end

  --[[----------------------------------------------------------------------------------------------------
        Create new Filter Function
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.task_delete(string_name)
    -- Remove the filter
    DEFT.task[string_name] = nil
  end

  --[[----------------------------------------------------------------------------------------------------
        Return new DEFT System
  ----------------------------------------------------------------------------------------------------]]--
  return DEFT
end

return m
