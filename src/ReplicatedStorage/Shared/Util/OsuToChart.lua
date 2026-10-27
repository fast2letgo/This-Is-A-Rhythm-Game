local RepS = game:GetService('ReplicatedStorage')

local RhythmService = require(RepS.Client.Modules.Services.RhythmService)

local laneMap = {
	[64] = 1,
	[192] = 2,
	[320] = 3,
	[448] = 4,
}


return function(osu: string)
	local finalChart = {}
	
	local lines = string.split(osu, "\n") -- create a new split for every new line
	local BPM = 0 -- will change
	
	if string.match(lines[1], "BPM:") then
		local bpmString = string.gsub(lines[1], "BPM:", "")
		--print('BPM STRING:',bpmString)
		
		BPM = tonumber(bpmString)
	end
		
	for i, str in lines do
		if i == 1 then
			continue
		end
		
		local values = string.split(str, ",") -- separate each value
		
		local x = tonumber(values[1])
		local timeMS = tonumber(values[3])
		local noteType = tonumber(values[4])
	
		local lane = laneMap[x]
		
		local note = {
			Lane = lane,
			Beat = RhythmService.MillisecondsToBeat(timeMS, BPM)
		}
		
		if noteType == 128 then
			local holdInfo = string.split(values[6], ":")
			local endMS = tonumber(holdInfo[1])

			note.EndBeat = RhythmService.MillisecondsToBeat(endMS, BPM)
		end
		
		table.insert(finalChart, note)
	end
	
	local copyPaste = "Notes = {\n"
	
	--dev note: no idea how any of this works, but it works
	-- thanks chatgpt
	for _, note in finalChart do
		local beat = math.round(note.Beat * 100) / 100

		if note.EndBeat then
			local endBeat = math.round(note.EndBeat * 100) / 100
			
			-- ALSO WTF YOU CAN JUST??
			-- text ..= "MORE TEXT???"
			copyPaste ..=
				string.format(
					"\t{Lane = %d, Beat = %.2f, EndBeat = %.2f},\n",
					note.Lane,
					beat,
					endBeat
				)
		else
			copyPaste ..=
				string.format(
					"\t{Lane = %d, Beat = %.2f},\n",
					note.Lane,
					beat
				)
		end
	end

	copyPaste ..= "}"
	
--	print(`Number of notes: {#finalChart}`)
	print(copyPaste)
end