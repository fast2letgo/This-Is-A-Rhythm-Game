-- c_opys simple UIController 5/17/26
-- Inspired by derpmonster83

local guiFolder = script.Guis
local player = game:GetService('Players').LocalPlayer

local UIController = {
	GUIS = {}
}

function UIController.Init()	
	for _,v in guiFolder:GetChildren() do
		if not v:IsA('ModuleScript') then
			continue
		end
		
		local module = require(v)		
		UIController.GUIS[v.Name] = module

		local autoEnable = module.AutoEnable :: boolean?
		if autoEnable == nil then
			autoEnable = true
		end

		local newGui = module.UI:Clone()
		newGui.IgnoreGuiInset = true
		newGui.ResetOnSpawn = false
		newGui.Parent = player.PlayerGui
		newGui.Enabled = autoEnable

		module.UI = newGui

		if module.Init then
			module.Init()
		end
	end	
end

function UIController.ToggleUI(name: string, enabled: boolean)
	local gui = UIController.GUIS[name].UI :: ScreenGui

	if gui then
		gui.Enabled = enabled
	end
end

return UIController
