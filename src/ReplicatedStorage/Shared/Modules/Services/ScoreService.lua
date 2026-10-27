local RepS = game:GetService('ReplicatedStorage')

local NoteData = require(RepS.Shared.Data.NoteData)

local ScoreService = {
	Score = 0, 
	Combo = 0,
	TotalNotes = 0,
	Accuracy = 0,
	
	Hits = {}, -- keep track of how many times a certain judgement was hit
	AccuracyScores = {}, -- track the score of each judgement hit
	FinalStats = {},
	
	Active = false
}

function ScoreService.ToggleActive(state: boolean)
	ScoreService.Active = state
end

function ScoreService.UpdateCombo(judgement: string)
	if judgement == "Miss" then
		ScoreService.Combo = 0
	else
		ScoreService.Combo += 1
	end
end

function ScoreService.AddJudgement(judgement: string)
	if ScoreService.Active == false then
		return
	end
	
	if ScoreService.Hits[judgement] == nil then
		ScoreService.Hits[judgement] = 0
		ScoreService.AccuracyScores[judgement] = 0
	end
	
	ScoreService.AccuracyScores[judgement] += NoteData[judgement].Accuracy
	ScoreService.Hits[judgement] += 1
	
	ScoreService.TotalNotes += 1
	ScoreService.Accuracy = ScoreService.getAccuracy()	
end

function ScoreService.addScore(judgement: string)
	ScoreService.Score += NoteData[judgement].Score
end

function ScoreService.getAccuracy()
	local finalAccuracy = 0
	
	for _, score in ScoreService.AccuracyScores do
		finalAccuracy += score
	end
	
	finalAccuracy /= ScoreService.TotalNotes
	
	return finalAccuracy
end


function ScoreService.SaveCurrentStats(songName: string)
	for i,v in ScoreService do
		if type(v) == "function" then
			continue
		end
		
		if i == "FinalStats" or i == "AccuracyScores" or i == "Active" then
			continue
		end
		
		if i == "Hits" then
			ScoreService.FinalStats.Hits = table.clone(ScoreService.Hits)
			continue
		end
		
		ScoreService.FinalStats[i] = v
	end
	
	-- this is gonna be ugly
	for i,v in NoteData do
		if i == "States" then
			continue
		end
		
		if ScoreService.FinalStats.Hits[i] == nil then
			-- if you didnt hit a certain judgement, it will be marked as zero automatically
			ScoreService.FinalStats.Hits[i] = 0
		end
	end
	
	ScoreService.FinalStats.Song = songName
	
	return ScoreService.FinalStats
end

function ScoreService.Clear()
	ScoreService.ToggleActive(false)
	
	ScoreService.TotalNotes = 0
	ScoreService.Accuracy = 0
	ScoreService.Active = 0
	ScoreService.Score = 0
	ScoreService.Combo = 0
	
	table.clear(ScoreService.AccuracyScores)
	table.clear(ScoreService.Hits)
	table.clone(ScoreService.FinalStats)
end

return ScoreService
