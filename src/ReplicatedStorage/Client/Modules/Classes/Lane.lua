-- Indivitual note lane class with one input to keep track of
local UIS = game:GetService('UserInputService')

local Lane = {}
Lane.__index = Lane

function Lane.new(index: number, input: Enum.KeyCode, controller)
	local self = setmetatable({}, Lane)

	self.Notes = {}
	self.Index = index
	self.Input = input
	self.Controller = controller -- a reference to rhythm service to prevent cyclic requiring
	
	self.Connections = {}
	
	self:init()
	
	return self
end

function Lane:init()
	
	table.insert(
		self.Connections,
		UIS.InputBegan:Connect(function(input, gp)
			if gp then
				return
			end
			
			if input.KeyCode == self.Input then
				self:onPress(true)
			end
		end)
	)
	
	table.insert(
		self.Connections,
		UIS.InputEnded:Connect(function(input, gp)
			if gp then
				return
			end
			
			if input.KeyCode == self.Input then
				self:onPress(false)
			end
		end)
	)
end

function Lane:onPress(state: boolean)	
	local note = self.Notes[1]
	if note then
		note:onNotePress(self.Controller.CurrentBeat, state)
	end
end

function Lane:update()
	local note = self.Notes[1]
	
	if note then		
		if note.Hit == true or note.Miss == true then
			table.remove(self.Notes, 1)
		end
	end
end

function Lane:Destroy()
	for _,v in self.Connections do
		v:Disconnect()
	end
	table.clear(self.Connections)
	table.clone(self.Notes)
end

return Lane
