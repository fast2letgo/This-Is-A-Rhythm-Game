local RepS = game:GetService('ReplicatedStorage')
local SS = game:GetService('SoundService')

local events = RepS.Client.Events

local Charts = require(RepS.Shared.Data.Charts)

local SongSelect = {
	UI = script.SongSelectGUI,
	AutoEnable = true
}

local songStates = {
	Idle = {
		Color = Color3.fromRGB(33, 24, 34),
		Position = UDim2.fromScale(0.5, 0.5)
	},
	
	Hover = {
		Color = Color3.fromRGB(139, 101, 143),
		Position = UDim2.fromScale(0.65, 0.5)
	}
}

local visibleStates = {
	[true] = UDim2.fromScale(0,.5),
	[false] = UDim2.fromScale(-0.5,.5)
}

local open = false

function SongSelect.Init()
	local songCtn = SongSelect.UI.SongCtn
	local toggleButton = SongSelect.UI.ToggleButton
	
	local template = songCtn.Template
	
	local function createButton(chartData)
		local songId = chartData.Chart.SongId :: string

		local new = template:Clone()
		
		new.Name = chartData.Id
		new.TextButton.Text = chartData.Name
		new.Parent = songCtn
		new.Visible = true

		new.TextButton.Activated:Connect(function()
			events.SongSelected:Fire(chartData.Id)
			toggleButton.Visible = false
			open = false
			SongSelect.ToggleVisible(open)
		end)
		
		new:GetPropertyChangedSignal("GuiState"):Connect(function()
			local state = new.GuiState.Name
			local stateData = songStates[state]

			if stateData then
				new.BackgroundColor3 = stateData.Color	
				new.TextButton:TweenPosition(
					stateData.Position,
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quint,
					.2,
					true
				)
			end
			
			if state == "Hover" then
				local sound = SS.ChartSongs:FindFirstChild(songId) :: Sound
				
				local sampleSound = sound:Clone()
				sampleSound.Name = songId .. "SAMPLE"
				sampleSound.Parent = SS
				
				sampleSound.TimePosition = chartData.Chart.PreviewTime or 0
				sampleSound:Play()
			else
				local oldSample = SS:FindFirstChild(songId .. "SAMPLE")
				if oldSample then
					oldSample:Destroy()
				end
			end
		end)		
	end
	
	for _,data in Charts.Get("All") do
		createButton(data)
	end
	
	SongSelect.ToggleVisible(open)
	
	toggleButton.Activated:Connect(function()
		open = not open
		SongSelect.ToggleVisible(open)
	end)
	
	events.SongEnd.Event:Connect(function()
		toggleButton.Visible = true
	end)
end

function SongSelect.ToggleVisible(state: boolean)
	local songCtn = SongSelect.UI.SongCtn
	local statePosition = visibleStates[state]
	
	songCtn:TweenPosition(
		statePosition,
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quint,
		.5,
		true
	)
end

return SongSelect
