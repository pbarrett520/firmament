local DialogueController = tdengine.entity('DialogueController')
function DialogueController:init(params)
   self.which = params.dialogue
   self.data = tdengine.load_dialogue(self.which)
   self.error = false
   self.current = self:find_entry_node()
   self.waiting_for_input = false

   self.input = tdengine.create_class('Input')
   self.input:set_channel(tdengine.InputChannel.Game)
   self.input:enable()
  
   -- Error checking
   local message = nil
   if not entry then
	  message = 'no entry point node found, dialogue = ' .. self.which
   end
   if entry and entry.kind == 'Choice' then
	  message = 'choice nodes cannot be entry points, dialogue = ' .. self.which
   end
   
   if message then
	  message = message .. 'Dialogue was: ' .. self.which
	  tdengine.log_to(message, tdengine.log_flags.console)
	  self.error = true
   end
end

function DialogueController:process()
  if node.kind == 'Text' then return end
  if node.kind == 'Set' then return end
  if node.kind == 'Branch' then return end
  if node.kind == 'Set' then return end
end

function DialogueController:update(dt)
  if self.error then return end

  if not self.waiting_for_input then return end
end
