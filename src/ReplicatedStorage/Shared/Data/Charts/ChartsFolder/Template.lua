return {
	Ignore = true, -- Determines if Chart initialization skips chart
	Id = "Template",
	Name = "hi template",
	MaxLanes = 4, -- Flexibility for songs with 4+ lanes or <4 lanes
	
	Chart = {
		BPM = 140, -- Setting BPM is required
		
		SongId = "Template", -- Id for Sound object (must be exactly the same in workspace)
		BeatOffset = 0,
		
		Notes = {
			{Lane = 1, Beat = 1}, -- Spawns note in the A lane on the first beat
			{Lane = 2, Beat = 2}, -- Spawns note in the S lane on the second beat
			{Lane = 3, Beat = 3}, -- Spawns note in the K lane on the third beat
			{Lane = 4, Beat = 4} -- Spawns note in the L lane on the fourth beat
		}
	}
}