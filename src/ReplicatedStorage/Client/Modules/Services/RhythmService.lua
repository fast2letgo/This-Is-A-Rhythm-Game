-- Handles all the logic for playing charts
-- (ALL Client Sided)
local RepS = game:GetService('ReplicatedStorage')
local RS = game:GetService('RunService')
local SS = game:GetService('SoundService')

local chartSongs = SS.ChartSongs
local classes = RepS.Client.Modules.Classes
local events = RepS.Client.Events

local ScoreService = require(RepS.Shared.Modules.Services.ScoreService)

local Charts = require(RepS.Shared.Data.Charts)
local Settings = require(RepS.Client.Modules.Data.Settings)

local LaneClass = require(classes.Lane)
local NoteClass = require(classes.Note)

local chartConnection = nil
local BEAT_OFFSET = 1 -- makes the songs start at beat 1 rather than beat 0

local RhythmService = {
	Lanes = {},
	
	CurrentBeat = 0,
	CurrentChart = nil :: Charts.Chart?, -- Will change when a song starts
	
	SongTime = 0,
}

-- Fancy conversions
function RhythmService.BeatToTime(beat: number, bpm: number)
	return (beat - BEAT_OFFSET) * (60 / bpm)
end

function RhythmService.SecondsToBeat(seconds: number, bpm: number)
	return seconds * (bpm / 60) + BEAT_OFFSET
end

function RhythmService.MillisecondsToBeat(ms: number, bpm: number)
	return ms * (bpm / 60_000) + BEAT_OFFSET
end

function RhythmService.Init()
	events.SongSelected.Event:Connect(function(chartId: string)
		RhythmService.PlayChart(chartId)
	end)
end

function RhythmService.InitChart(chartId: string)
	if RhythmService.CurrentChart ~= nil then
		-- Prevent spam
		return
	end
	
	RhythmService.CurrentChart = Charts.Get(chartId)
	
	local notes = RhythmService.CurrentChart.Chart.Notes

	-- completely useless. the keybinds always remain ASKL
	local inputs = Settings[1].Settings.Keybinds.CurrentKeybinds

	for i, keycode: Enum.KeyCode in inputs do
		-- Create each lane according to the chart's data
		table.insert(RhythmService.Lanes, LaneClass.new(i, keycode, RhythmService))
	end
	
	for _, noteData in notes do
		if RhythmService.Lanes[noteData.Lane] then
			-- Each note has their own lane index
			local laneNote = NoteClass.new(noteData.Beat, noteData.EndBeat)
			table.insert(RhythmService.Lanes[noteData.Lane].Notes, laneNote)
			-- Insert all the notes for the respective lanes
		end
	end
end

function RhythmService.ToggleSong(state: boolean)
	if RhythmService.CurrentChart == nil then
		return
	end
	
	local song = chartSongs:FindFirstChild(RhythmService.CurrentChart.Chart.SongId) :: Sound
	-- Find the sound object based off the SongId

	if state == true then
		if chartConnection ~= nil then
			return
		end
		
		ScoreService.ToggleActive(true)
		-- Tell the client the song started
		events.SongInit:Fire(true)
		events.SongStart:Fire()
		
		local beatOffset = RhythmService.CurrentChart.Chart.BeatOffset or 0
		song.TimePosition = RhythmService.BeatToTime(beatOffset, RhythmService.CurrentChart.Chart.BPM)
		-- Set the song's time position so it syncs

		RhythmService.SongTime = -1.5 -- initial "countdown" before the song starts
		
		chartConnection = RS.Heartbeat:Connect(function(dt)
			-- Update song time every frame and sync with TimePosition
			if RhythmService.SongTime <= 0 then
				RhythmService.SongTime += dt
			else
				RhythmService.SongTime = song.TimePosition
			end
			
			song.Playing = RhythmService.SongTime > 0
			
			-- CurrentBeat refers to the beat of the song in time measure
			-- Like 4/4 music theory. 
			RhythmService.CurrentBeat = (RhythmService.SongTime * RhythmService.CurrentChart.Chart.BPM / 60) + 1
			
			for i, lane in RhythmService.Lanes do
				-- Update the lanes and notes
				lane:update()
				for _, note in lane.Notes do
					note:update(RhythmService.CurrentBeat)
				end
			end			
		end)
		
		song.Ended:Once(function()
			RhythmService.ToggleSong(false)
		end)
		
		song.Stopped:Once(function()
			-- Added this function if the player decides to exit the song early
			if song.TimePosition >= song.TimeLength then
				return
			end
			
			RhythmService.ToggleSong(false)
		end)
	else
		if chartConnection == nil then
			return
		end
		
		ScoreService.SaveCurrentStats(RhythmService.CurrentChart.Name)
		
		song:Stop()
		events.SongInit:Fire(false)
		events.SongEnd:Fire()
		
		chartConnection:Disconnect()
		chartConnection = nil
		
		RhythmService.Clear()
		ScoreService.Clear()
	end
end

function RhythmService.PlayChart(chartId: string)
	RhythmService.InitChart(chartId)
	RhythmService.ToggleSong(true)
end

function RhythmService.Clear()
	RhythmService.SongTime = 0
	RhythmService.CurrentChart = nil
	RhythmService.CurrentBeat = 0
	table.clear(RhythmService.Lanes)
end

return RhythmService
