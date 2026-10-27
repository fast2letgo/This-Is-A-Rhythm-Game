local RepS = game:GetService('ReplicatedStorage')
local RhythmService = require(RepS.Client.Modules.Services.RhythmService)

local events = RepS.Client.Events

local SongController = {
	UI = script.SongControllerUI
}

function SongController.Init()
	local button = SongController.UI.StopButton
	button.Visible = false
	
	events.SongStart.Event:Connect(function()
		button.Visible = true
	end)
	
	events.SongEnd.Event:Connect(function()
		button.Visible = false
	end)
	
	button.Activated:Connect(function()
		RhythmService.ToggleSong(false)
	end)
end

return SongController
