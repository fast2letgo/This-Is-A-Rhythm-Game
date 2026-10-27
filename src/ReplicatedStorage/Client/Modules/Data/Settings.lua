return {	
	{
		Name = "Inputs",
		Settings = {		
			Keybinds = {
				Name = "Keybinds",
				Type = "Keybinds",
				CurrentKeybinds = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.K, Enum.KeyCode.L}
			}
		}
	},

	{
		Name = "Notes",
		Settings = {
			Upscroll = {
				Name = "Upscroll",
				Type = "Toggle",
				CurrentState = false
			},
			
			ScrollSpeed = {
				Name = "Scroll Speed",
				Type = "Slider",

				CurrentValue = 1.2,

				Min = 0.2, 
				Max = 2,
				Step = .05,
				Decimals = 2,
			},

			NoteSize = {
				Name = "Note Size",
				Type = "Slider",

				CurrentValue = .65,

				Min = 0.5, 
				Max = 1,
				Step = .05,
				Decimals = 2,
			},

			HoldTransparency = {
				Name = "Hold Note Transparency",
				Type = "Slider",

				CurrentValue = 0.5,

				Min = 0,
				Max = 0.9,
				Step = .05,
				Decimals = 2,
			},
			
			HoldWidth = {
				Name = "Hold Note Width",
				Type = "Slider",

				CurrentValue = 0.5,

				Min = 0.1,
				Max = 1,
				Step = .05,
				Decimals = 2,
			},
		}
	},
	
	{
		Name = "Audio",
		Settings = {
			SongVolume = {
				Name = "Song Volume",
				Type = "Slider",
				CurrentValue = 50,
				Min = 0,
				Max = 100,
				Step = 1,
			}
		}
	}
}