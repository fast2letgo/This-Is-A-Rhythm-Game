local RepS = game:GetService('ReplicatedStorage')

local ScoreService = require(RepS.Shared.Modules.Services.ScoreService)
local Colors = require(RepS.Shared.Data.Colors)

local events = RepS.Client.Events

local EndScreen = {
	UI = script.EndScreenGUI
}

local judgementOrders = {
	Marvelous = 1,
	Perfect = 2,
	Great = 3,
	Good = 4,
	Okay = 5,
	Miss = 6
}

function EndScreen.Init()
	local background = EndScreen.UI.Background
	local notesCtn = background.NotesCtn
	local hitTemplate = notesCtn.HitTemplate

	background.CloseButton.Activated:Connect(function()
		background.Visible = false
	end)
	
	events.SongEnd.Event:Connect(function()
		background.Visible = true
		
		local songStats = ScoreService.FinalStats
		local rounded = math.floor(songStats.Accuracy * 100) / 100
		local accuracyText = string.format("%.2f", rounded)
		
		-- set the song
		background.SongTitle.Text = songStats.Song
		
		-- kill the old stuff
		for _,v in notesCtn:GetChildren() do
			if not v:IsA('TextLabel') or v == hitTemplate then
				continue
			end
			
			v:Destroy()
		end
		
		-- add the new stuff
		for judgement: string, amount: number in songStats.Hits do
			local judgementColor = Colors[judgement] :: Color3
			local r, g, b = math.round(judgementColor.R * 255), math.round(judgementColor.G * 255),  math.round(judgementColor.B * 255)
			
			local new = hitTemplate:Clone()
			new.Visible = true
			new.Name = judgement
			new.Text = `<font color="rgb({r},{g},{b})"><b>{judgement}</b></font>: {amount}`
			new.LayoutOrder = judgementOrders[judgement]
			new.Parent = notesCtn
		end
		
		-- accuracy
		background.GradeLabel.Text = `{accuracyText}%`
		
		--score
		background.ScoreLabel.Text = songStats.Score
	end)
	
	events.SongInit.Event:Connect(function()
		background.Visible = false
	end)
end

return EndScreen
