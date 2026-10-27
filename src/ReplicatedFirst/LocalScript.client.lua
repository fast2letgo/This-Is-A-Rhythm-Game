local RepF = game:GetService('ReplicatedFirst')
local SS = game:GetService('SoundService')
local ConP = game:GetService('ContentProvider')

local songs = SS:WaitForChild('ChartSongs'):GetChildren()

ConP:PreloadAsync(songs)
