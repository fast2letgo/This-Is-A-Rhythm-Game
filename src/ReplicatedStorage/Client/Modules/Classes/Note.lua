-- Note class for the Lanes
local RepS = game:GetService("ReplicatedStorage")

local ScoreService = require(RepS.Shared.Modules.Services.ScoreService)

local NoteData = require(RepS.Shared.Data.NoteData)

local Note = {}
Note.__index = Note

function Note.new(beat: number, endBeat: number?)
	local self = setmetatable({}, Note)

	self.Beat = beat
	self.EndBeat = endBeat
	
	-- Distance from current beat (positive = upcoming, negative = passed)
	self.BeatDelta = 0

	self.Delta = 0
	self.State = NoteData.States.Moving
	self.Judgement = NoteData.States.None
	
	self.Hit = false
	self.Miss = false
	
	return self
end

function Note:getBeatDelta(currentBeat: number, noteBeat: NoteBeat)
	if noteBeat == "Start" then
		return self.Beat - currentBeat
	elseif noteBeat == "End" then
		return self.EndBeat - currentBeat
	end
end

function Note:getDelta(currentBeat: number, noteBeat: NoteBeat)
	if noteBeat == "Start" then
		return math.abs(currentBeat - self.Beat)
	elseif noteBeat == "End" then
		return math.abs(currentBeat - self.EndBeat)
	end
end

function Note:isMissed(currentBeat, noteBeat)
	local beatDelta

	if noteBeat == "Start" then
		beatDelta = currentBeat - self.Beat
	else
		beatDelta = currentBeat - self.EndBeat
	end
	
	return beatDelta > NoteData.Miss.Delta
end

function Note:update(currentBeat: number)
	if self.State == NoteData.States.Holding then
		self.BeatDelta = self:getBeatDelta(currentBeat, "End")
	else
		self.BeatDelta = self:getBeatDelta(currentBeat, "Start")
	end
	
	if self.State == NoteData.States.Holding then
		if self:isMissed(currentBeat, "End") then
			self.Miss = true
			self.Judgement = NoteData.Miss.Id

			ScoreService.AddJudgement(self.Judgement)
			ScoreService.UpdateCombo(self.Judgement)
		end
	else
		if self:isMissed(currentBeat, "Start") then
			self.Miss = true
			self.Judgement = NoteData.Miss.Id
			
			ScoreService.AddJudgement(self.Judgement)
			ScoreService.UpdateCombo(self.Judgement)
		end
	end
end

function Note:onNotePress(currentBeat: number, state: boolean)
	if state == true then
		if self.Hit or self.Miss then
			return
		end
		
		local beatDelta = self.Beat - currentBeat
		if beatDelta > NoteData.Miss.Delta then
			return
		end
		
		self.Delta = math.abs(beatDelta)
		self.Judgement = self:Judge()

		if self.EndBeat then
			self.State = NoteData.States.Holding		
		else
			self.Hit = true
		end
		
		ScoreService.AddJudgement(self.Judgement)
		ScoreService.addScore(self.Judgement)
		ScoreService.UpdateCombo(self.Judgement)
	else
		if self.State == NoteData.States.Holding then
			-- check if they released on beat
			self.Delta = self:getDelta(currentBeat, "End")
			
			if self:isMissed(currentBeat, "End") then
				self.Miss = true
				return
			end
			
			self.Judgement = self:Judge()
			self.Hit = true
			
			ScoreService.addScore(self.Judgement)
			ScoreService.AddJudgement(self.Judgement)
			ScoreService.UpdateCombo(self.Judgement)
		end	
	end
end

function Note:Judge()
	if self.Delta <= NoteData.Marvelous.Delta then
		return NoteData.Marvelous.Id		
	elseif self.Delta <= NoteData.Perfect.Delta then
		return NoteData.Perfect.Id
	elseif self.Delta <= NoteData.Great.Delta then
		return NoteData.Great.Id
	elseif self.Delta <= NoteData.Good.Delta then
		return NoteData.Good.Id
	elseif self.Delta <= NoteData.Okay.Delta then
		return NoteData.Okay.Id
	end
	
	return NoteData.Miss.Id
end

type NoteBeat = "Start"|"End"

return Note