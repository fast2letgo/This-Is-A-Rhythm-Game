local RepS = game:GetService('ReplicatedStorage')

local RhythmService = require(RepS.Client.Modules.Services.RhythmService)

-- these numbers refer to the lanes in osu
local laneMap = {
	[64] = 1,
	[192] = 2,
	[320] = 3,
	[448] = 4,
}

-- "osu" refers to the giant text file that osu!mania has to create charts
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
		
		local x = tonumber(values[1]) -- x is the lane index
		local timeMS = tonumber(values[3]) -- MS is the miliseconds where the note hits the line
		local noteType = tonumber(values[4]) -- hold note or normal note
	
		local lane = laneMap[x]
		
		-- My charting data defines a note as an array with a Lane property and Beat property
		local note = {
			Lane = lane, -- easy stuff, usually 1-4
			Beat = RhythmService.MillisecondsToBeat(timeMS, BPM) -- converts miliseconds into beat number
		}
		
		if noteType == 128 then
			local holdInfo = string.split(values[6], ":")
			local endMS = tonumber(holdInfo[1])

			note.EndBeat = RhythmService.MillisecondsToBeat(endMS, BPM)
			-- if its a hold note, we add the EndBeat property which is the beat number where a note ends
		end
		
		table.insert(finalChart, note)
	end
	
	local copyPaste = "Notes = {\n"
	
	-- loop through the final chart array and convert it all into a string that can be copy and pasted through the output
	for _, note in finalChart do
		local beat = math.round(note.Beat * 100) / 100

		if note.EndBeat then
			local endBeat = math.round(note.EndBeat * 100) / 100
			
			-- yeah i have no idea. i had chatgpt do this
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
	
--	trust me it works
	print(copyPaste)
end