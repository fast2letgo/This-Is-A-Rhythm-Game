-- Initialize all client scripts on StarterPlayerScripts so it only fires once

local RepS = game:GetService('ReplicatedStorage')

require(RepS.Shared.Data.Charts).Init()

require(RepS.Client.Modules.Services.RhythmService).Init()
require(RepS.Client.UIController).Init()