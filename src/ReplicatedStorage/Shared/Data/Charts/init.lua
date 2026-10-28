local chartsFolder = script.ChartsFolder

local Charts = {}
local cache = {}
local init = false

-- Load all the charts and store it in cache to be retrieved later
function Charts.Init()
	if init == true then
		warn("Charts already initialized")
		return
	end
	
	for _,v in chartsFolder:GetChildren() do
		if not v:IsA('ModuleScript') then
			continue
		end
		
		local module = require(v)
		if module.Ignore == true then
			continue
		end
		
		cache[module.Id] = module
	end
	
	init = true
end

function Charts.Get(id: string|"All"): Chart?
	if id == "All" then
		return cache
	end
	
	local chart = cache[id]
	if not chart then
		return
	end
	
	return chart
end

-- Custom type for charts (Autocomplete)
export type Chart = {
	Id: string,
	Name: string,
	MaxLanes: number,
	
	Chart: {
		BPM: number,
		SongId: string,
		
		Notes: {
			{Lane: number, Beat: number, EndBeat: number?}
		}
	}
}

return Charts
