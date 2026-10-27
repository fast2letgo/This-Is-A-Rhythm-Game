local RepS = game:GetService('ReplicatedStorage')

local events = RepS.Client.Events

local player = game:GetService('Players').LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char.Humanoid

events.SongStart.Event:Connect(function()
	if humanoid then
		humanoid.WalkSpeed = 0
	end
end)

events.SongEnd.Event:Connect(function()
	if humanoid then
		humanoid.WalkSpeed = 16
	end
end)