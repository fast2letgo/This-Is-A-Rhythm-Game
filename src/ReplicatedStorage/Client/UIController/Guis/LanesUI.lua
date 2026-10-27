local RepS = game:GetService('ReplicatedStorage')
local RS = game:GetService('RunService')
local TS = game:GetService('TweenService')

local RhythmService = require(RepS.Client.Modules.Services.RhythmService)
local ScoreService = require(RepS.Shared.Modules.Services.ScoreService)

local Settings = require(RepS.Client.Modules.Data.Settings)
local NoteData = require(RepS.Shared.Data.NoteData)

local Colors = require(RepS.Shared.Data.Colors)

local renderConnection = nil
local events = RepS.Client.Events

local scrollDir = Settings[2].Settings.Upscroll.CurrentState and -1 or 1

local HITLINE_Y = 0.85

local NOTE_WIDTH = Settings[2].Settings.NoteSize.CurrentValue
local HOLD_WIDTH = Settings[2].Settings.HoldWidth.CurrentValue

local SPAWN_OFFSET_TIME = 2 / Settings[2].Settings.ScrollSpeed.CurrentValue

local LanesUI = {
	AutoEnable = false,
	UI = script.LanesUI
}

local renderedNotes = {}

-- converts beat distance to UI position
local function BeatToY(beatDelta: number)
	local timeDelta = beatDelta * (60 / RhythmService.CurrentChart.Chart.BPM)
	scrollDir = Settings[2].Settings.Upscroll.CurrentState and -1 or 1

	return HITLINE_Y - (timeDelta * Settings[2].Settings.ScrollSpeed.CurrentValue * scrollDir)
end

local function createNoteVisual(note, frame)
	local noteTemplate = frame.NoteTemplate
	
	local head = noteTemplate:Clone()
	head.Visible = true
	head.Name = "ActiveNote"
	head.Size = UDim2.fromScale(Settings[2].Settings.NoteSize.CurrentValue, .1)
	head.Parent = frame

	local body
	if note.EndBeat then
		body = frame.NoteTemplate.HoldBar:Clone()
		body.Visible = true
		body.Parent = frame
		body.AnchorPoint = Vector2.new(0.5, 0)		
		body.BackgroundTransparency = Settings[2].Settings.HoldTransparency.CurrentValue
	end

	return {
		Head = head :: Frame,
		Body = body :: Frame
	}
end

function LanesUI.Init()
	local background = LanesUI.UI.Background
	
	LanesUI.UI.ComboLabel.Visible = false
	LanesUI.UI.AccuracyLabel.Visible = false
	LanesUI.UI.JudgementTemplate.Visible = false

	background.LaneCtn.Visible = true
	background.LaneCtn.LaneTemplate.Visible = false
	background.LaneCtn.LaneTemplate.NoteTemplate.Visible = false

	events.SongInit.Event:Connect(function(state: boolean)
		HITLINE_Y = if Settings[2].Settings.Upscroll.CurrentState then 1-HITLINE_Y else HITLINE_Y
		SPAWN_OFFSET_TIME = 2 / Settings[2].Settings.ScrollSpeed.CurrentValue
		HOLD_WIDTH = Settings[2].Settings.HoldWidth.CurrentValue

		LanesUI.UI.Enabled = state
		LanesUI.CreateLanes(state)
		
		LanesUI.UI.AccuracyLabel.Visible = false
		LanesUI.UI.ComboLabel.Visible = false
		
		if state then
			background.HitLine.Position = UDim2.fromScale(0, HITLINE_Y)
		else
			table.clear(renderedNotes)
		end
	end)

	events.SongStart.Event:Connect(function()
		if renderConnection then return end

		renderConnection = RS.RenderStepped:Connect(function()
			LanesUI.Update()
		end)
	end)

	events.SongEnd.Event:Connect(function()
		if not renderConnection then return end

		renderConnection:Disconnect()
		renderConnection = nil
	end)
end

function LanesUI.CreateLanes(state: boolean)
	local laneCtn = LanesUI.UI.Background.LaneCtn
	local laneTemplate = laneCtn.LaneTemplate

	local function createLane(lane)
		local new = laneTemplate:Clone()
		new.Visible = true
		new.Name = `Lane{lane.Index}`
		new.LayoutOrder = lane.Index
		new.KeybindLabel.Text = lane.Input.Name
		new.Parent = laneCtn

		return new
	end

	if state then
		for _, lane in RhythmService.Lanes do
			createLane(lane)
		end
	else
		for _, v in laneCtn:GetChildren() do
			if v:IsA('Frame') and v ~= laneTemplate then
				v:Destroy()
			end
		end
	end
end

-- Gameplay Feedback
function LanesUI.LaneColor(laneFrame: Frame, judgement: string)
	local color = Colors[judgement]
	if not color then
		return
	end
	laneFrame.BackgroundColor3 = color
	
	TS:Create(
		laneFrame,
		TweenInfo.new(.3),
		{BackgroundColor3 = Colors.Lane}
	):Play()
end

function LanesUI.ShowJudgement(judgement: string)
	local color = Colors[judgement]
	if not color then
		color = Color3.fromRGB(255, 255, 255)
	end
	
	local template = LanesUI.UI.JudgementTemplate
	
	local new = template:Clone()
	new.Name = "New_"..judgement
	new.Parent = LanesUI.UI
	new.Visible = true
	
	new.Text = judgement
	new.TextColor3 = color
	new.Position = UDim2.fromScale(0.5, 0.35)
	
	new:TweenPosition(
		UDim2.fromScale(0.5,.3),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quint,
		.25
	)
	
	task.delay(.35, function()
		new:Destroy()
	end)
end

function LanesUI.UpdateCombo()
	local comboLabel = LanesUI.UI.ComboLabel
	
	comboLabel.Visible = ScoreService.Combo > 50
	comboLabel.Text = ScoreService.Combo
end

function LanesUI.UpdateAccuracy()
	local accuracyLabel = LanesUI.UI.AccuracyLabel
	
	accuracyLabel.Visible = ScoreService.Accuracy > 0
	
	local rounded = math.floor(ScoreService.Accuracy * 100) / 100
	local accuracyText = string.format("%.2f", rounded)
	
	accuracyLabel.Text = `{accuracyText}%`
end

function LanesUI.UpdateScore()
	local scoreLabel = LanesUI.UI.ScoreLabel
	scoreLabel.Text = ScoreService.Score
end

-- Main
function LanesUI.Update()
	local laneCtn = LanesUI.UI.Background.LaneCtn

	local function getFrameIndex(index: number)
		return laneCtn:FindFirstChild(`Lane{index}`)
	end
	
	for _, lane in RhythmService.Lanes do
		for _, note in lane.Notes do
			
			local beatDelta = note.Beat - RhythmService.CurrentBeat
			local timeDelta = (RhythmService.BeatToTime(note.Beat, RhythmService.CurrentChart.Chart.BPM) - RhythmService.SongTime)
			
			if timeDelta >= SPAWN_OFFSET_TIME then
				continue
			end

			local frame = getFrameIndex(lane.Index)
			if not frame then continue end

			-- create visual once
			if not renderedNotes[note] then
				renderedNotes[note] = createNoteVisual(note, frame)
			end

			local visual = renderedNotes[note]

			local y = BeatToY(beatDelta)
			
			visual.Head.Position = UDim2.fromScale(0.5, y)
			
			
			if note.EndBeat and visual.Body then
				if note.State == "Holding" then
					-- shrinking effect
					local endDelta = note.EndBeat - RhythmService.CurrentBeat -- get the difference between the current beat and the end beat
					local tailY = BeatToY(endDelta)
					
					-- align the body and the head to the hitline
					visual.Head.Position = UDim2.fromScale(0.5, HITLINE_Y)
					visual.Body.Position = UDim2.fromScale(0.5, HITLINE_Y)
					
					-- adjust the body's size as it moves
					visual.Body.Size = UDim2.fromScale(HOLD_WIDTH, tailY - HITLINE_Y)
					
					if note.Judgement == NoteData.States.None then
						visual.Body.BackgroundColor3 = Colors.Miss
					else
						visual.Body.BackgroundColor3 = Colors[note.Judgement]
						visual.Head.BackgroundColor3 = Colors[note.Judgement]
					end
				else
					local topDelta = note.Beat - RhythmService.CurrentBeat
					local bottomDelta = note.EndBeat - RhythmService.CurrentBeat

					local topY = BeatToY(topDelta)
					local bottomY = BeatToY(bottomDelta)
										
					visual.Body.Position = UDim2.fromScale(0.5, topY)
					visual.Body.Size = UDim2.fromScale(
						HOLD_WIDTH,
						bottomY - topY
					)
				end
			end
			
			-- cleanup
			if note.Miss or note.Hit then
				if visual.Head then visual.Head:Destroy() end
				if visual.Body then visual.Body:Destroy() end
				
				if note.Hit then
					LanesUI.LaneColor(frame, note.Judgement)
				else
					LanesUI.LaneColor(frame, "Miss")
				end
				
				LanesUI.ShowJudgement(note.Judgement)
				renderedNotes[note] = nil
			end
			
			LanesUI.UpdateCombo()
			LanesUI.UpdateAccuracy()
			LanesUI.UpdateScore()
		end
	end
end

return LanesUI