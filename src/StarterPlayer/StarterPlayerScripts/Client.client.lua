local RepS = game:GetService('ReplicatedStorage')

require(RepS.Shared.Data.Charts).Init()

require(RepS.Client.Modules.Services.RhythmService).Init()
require(RepS.Client.UIController).Init()