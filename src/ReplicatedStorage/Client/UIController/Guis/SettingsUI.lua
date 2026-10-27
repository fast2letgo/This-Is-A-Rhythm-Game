local RepS = game:GetService('ReplicatedStorage')
local UIS = game:GetService('UserInputService')

local ClientSettings = require(RepS.Client.Modules.Data.Settings)

local SettingsUI = {
	UI = script.SettingsGUI
}

local activeSlider = nil

local settingsFunctions = {
	Toggle = function(key: string, data, index: number)
		local settingsCtn = SettingsUI.UI.Background.SettingsCtn

		local states = {
			[true] = {
				ButtonColor = Color3.fromRGB(144, 255, 93),
				BackgroundColor = Color3.fromRGB(46, 74, 44)
			},

			[false] = {
				ButtonColor = Color3.fromRGB(255, 107, 107),
				BackgroundColor = Color3.fromRGB(74, 43, 43)
			},
		}

		local toggleTemplate = settingsCtn.ToggleTemplate
		local new = toggleTemplate:Clone()
		new.Name = key
		new.Title.Text = data.Name or key
		new.Visible = true
		new.Parent = settingsCtn
		new.LayoutOrder = index

		local function updateButton(state: boolean)
			new.BackgroundColor3 = states[state].BackgroundColor
			new.TextButton.BackgroundColor3 = states[state].ButtonColor
		end

		updateButton(data.CurrentState)

		new.TextButton.Activated:Connect(function()
			data.CurrentState = not data.CurrentState
			updateButton(data.CurrentState)
		end)
	end,

	Input = function(key, data, index)
		local settingsCtn = SettingsUI.UI.Background.SettingsCtn

		local inputTemplate = settingsCtn.InputTemplate
		local new = inputTemplate:Clone()
		new.Name = key
		new.Title.Text = data.Name or key
		new.Visible = true
		new.Parent = settingsCtn
		new.LayoutOrder = index
		new.TextBox.Text = ""

		new.TextBox.FocusLost:Connect(function()
			data.CurrentInput = new.TextBox.Text
		end)
	end,

	Slider = function(key: string, data, index: number)
		local settingsCtn = SettingsUI.UI.Background.SettingsCtn
		
		local inputTemplate = settingsCtn.SliderTemplate
		local new = inputTemplate:Clone()
		new.Name = key
		new.Title.Text = data.Name or key
		new.Visible = true
		new.Parent = settingsCtn
		new.LayoutOrder = index
		
		local sliderCtn = new.SliderCtn
		local valueLabel = new.ValueLabel
		local hold = sliderCtn.Hold
		local decimals = data.Decimals or 0

		valueLabel.Text = data.CurrentValue
		hold.Position = UDim2.new(data.CurrentValue/data.Max,0,.5,0)
		
		sliderCtn.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			local MIN_X, MAX_X = sliderCtn.AbsolutePosition.X, sliderCtn.AbsolutePosition.X + sliderCtn.AbsoluteSize.X

			activeSlider = {
				Data = data,
				UI = new,
				MinX = MIN_X,
				MaxX = MAX_X,
				Update = function(mouseX)
					
					local mouseX = math.clamp(
						UIS:GetMouseLocation().X,
						MIN_X,
						MAX_X
					)
					local blend = math.lerp(0,1, (mouseX-MIN_X)/sliderCtn.AbsoluteSize.X)
					local udim = UDim2.new(blend, 0, 0.5, 0)

					hold.Position = udim
					data.CurrentValue = data.Max * blend					
					data.CurrentValue = math.round(data.CurrentValue / data.Step) * data.Step
					valueLabel.Text = string.format("%." .. decimals .. "f", data.CurrentValue)
				end
			}
		end)
	end,
}

function initSettings()
	local settingsCtn = SettingsUI.UI.Background.SettingsCtn
	
	local categoryTemplate = settingsCtn.CategoryTemplate
	local currentIndex = 0

	for index, category in ClientSettings do
		if category.Name == "Inputs" then
			-- temporary until i decide to add custom inputs
			continue
		end
		currentIndex += 1 

		local newCategory = categoryTemplate:Clone()
		newCategory.Parent = settingsCtn
		newCategory.Visible = true
		newCategory.LayoutOrder = currentIndex
		newCategory.Name = category.Name
		newCategory.Title.Text = category.Name

		for key,data in category.Settings do
			if settingsFunctions[data.Type] then
				currentIndex += 1
				settingsFunctions[data.Type](key, data, currentIndex)
			end
		end
	end
end

function initSliderConnections()
	UIS.InputChanged:Connect(function(input)
		if not activeSlider then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		
		activeSlider.Update(UIS:GetMouseLocation().X)
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			activeSlider = nil
		end
	end)
end

function SettingsUI.toggleBackground()
	local gui = SettingsUI.UI
	local background = gui.Background
	
	background.Visible = not background.Visible
end

function SettingsUI.Init()
	local gui = SettingsUI.UI

	local toggleButton = gui.ToggleButton

	toggleButton.Activated:Connect(SettingsUI.toggleBackground)

	initSettings()
	initSliderConnections()
end

return SettingsUI
