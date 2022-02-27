function next_entity_id()
  local id = tdengine.next_entity_id
  tdengine.next_entity_id = tdengine.next_entity_id + 1
  return id
end

-- tdengine functions we're injecting in for sugar -- only functions can go here. check out how
-- the class stuff works for more info, anything put here is shared by all instances of the class.
local entity_mixin = {
  get_name = function(self)
	return self.name
  end,
  get_id = function(self)
	return self.id
  end,
  create_entity = function(self, name)
	local id = tdengine.create_entity(name)
	return tdengine.entities[id]
  end,
  destroy_entity = function(self, id)
	tdengine.destroy_entity(id)
  end,
  add_imgui_ignore = function(self, member_name)
	self.imgui_ignore[member_name] = true
  end,
  remove_imgui_ignore = function(self, member_name)
	self.imgui_ignore[member_name] = false
  end
}

function tdengine.entity(name)
  local class = tdengine.create_class(name)
  tdengine.add_new_to_class(class, tdengine.entity_types)
  class:include(entity_mixin)
  
  tdengine.entity_types[name] = class

  return class
end

function tdengine.find_entity(name)
  for id, entity in pairs(tdengine.entities) do
	if entity:get_name() == name then
	  return entity
	end
  end

  return nil
end

function tdengine.find_entity_by_id(id)
   return tdengine.entities[id]
end

function tdengine.find_entity_by_tag(tag)
  for id, entity in pairs(tdengine.entities) do
	if entity.tag == tag then
	  return entity
	end
  end

  return nil
end

function tdengine.find_entity_by_any(descriptor)
   if descriptor.id then
	  return tdengine.find_entity_by_id(descriptor.id)
   elseif descriptor.tag then
	  return tdengine.find_entity_by_tag(descriptor.tag)
   elseif descriptor.entity then
	  return tdengine.find_entity(descriptor.entity)
   else
	  tdengine.log('@no_descriptor_to_find')
	  return nil
   end
end

function tdengine.create_entity(name, data)
  data = data or {}

  -- Find the matching type in Lua
  EntityType = tdengine.entity_types[name]
  if not EntityType then
	tdengine.log(string.format("could not find entity type: type = %s", name))
	return nil
  end
  
  -- Construct the entity with a do-nothing constructor
  local entity = EntityType:new()

  -- Fill in its identifiers
  entity.id = next_entity_id()
  entity.tag = data.tag
  entity.name = name

  -- Fill in some internal tdengine data
  entity.imgui_ignore = {
	class = true,
	imgui_ignore = true
  }

  -- Call into the entity to initialize
  params = data.params or {}
  entity:init(params)

  tdengine.entities[entity.id] = entity
  
  return entity.id
end

function tdengine.destroy_entity(id)
  tdengine.entities[id] = nil
end

function tdengine.update_entities(dt)
  for id, entity in pairs(tdengine.entities) do
	entity:update(dt)
  end
end
