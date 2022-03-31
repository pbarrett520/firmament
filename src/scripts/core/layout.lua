function tdengine.layout(name)
  -- Update stuff in C++
  tdengine.use_layout(name)
  tdengine.thing(tdengine.current_layout.selected_tab)

  -- Update what we're keeping track of in Lua
  local info = {
	name = name,
	selected_tab = imgui.GetSelectedTabId()
  }
  tdengine.push_layout(info)
  tdengine.current_layout = info
end

function tdengine.push_layout(layout_info)
  for i, info in pairs(tdengine.layout_stack) do
	if info.name == layout_info.name then
	  tdengine.layout_stack[i] = nil
	end

	-- Shift everything up
	if tdengine.layout_stack[i] == nil then
	  tdengine.layout_stack[i] = tdengine.layout_stack[i + 1]
	end
  end

  table.insert(tdengine.layout_stack, layout_info)
end

function tdengine.next_layout()
  local stack_size = #tdengine.layout_stack
  local index = tdengine.layout_index
  tdengine.layout_index = (index % stack_size) + 1
  
  local layout_info = tdengine.layout_stack[tdengine.layout_index]
  tdengine.use_layout(layout_info.name)
  imgui.MakeTabVisible(layout_info.selected_tab)
end


function tdengine.previous_layout()
  local stack_size = #tdengine.layout_stack
  local index = tdengine.layout_index - 2
  tdengine.layout_index = (index % stack_size) + 1
  
  local layout_info = tdengine.layout_stack[tdengine.layout_index]
  tdengine.use_layout(layout_info.name)
  imgui.MakeTabVisible(layout_info.selected_tab)
end
