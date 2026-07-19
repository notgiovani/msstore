return function(Window)
	local function CloneReference(Object)
		if MSstore and MSstore.Environment.cloneref then
			return MSstore.Environment.cloneref(Object)
		else
			return Object
		end
	end

	local Services = setmetatable({}, {
		__index = function(self, Name)
			return CloneReference(game:GetService(Name))
		end
	})

	local Library = MSstore.Interface.Library
	local SaveManager = MSstore.Interface.SaveManager
	local ThemeManager = MSstore.Interface.ThemeManager

	local Toggles = Library.Toggles
	local Options = Library.Options

	local SettingsTab = Window:AddTab("Settings", "settings")
	local MenuGroup = SettingsTab:AddLeftGroupbox("Menu")

	MenuGroup:AddToggle("KeybindMenuOpen", {
		Default = Library.KeybindFrame.Visible,
		Text = "Open Keybind Menu",
		Callback = function(value)
			Library.KeybindFrame.Visible = value
		end,
	})
	MenuGroup:AddToggle("ShowCustomCursor", {
		Text = "Custom Cursor",
		Default = false,
		Callback = function(Value)
			Library.ShowCustomCursor = Value
		end,
	})

	MenuGroup:AddDropdown("UILibrary", {
		Text = "UI Style",
		Values = {
			"Obsidian",
			"Linoria"
		},
		Default = (MSstore.UILibrary == "Linoria" and 2 or 1),
		Callback = function(Value)
			if MSstore.Environment.writefile and MSstore.Environment.readfile then
				if not MSstore.Environment.isfile("MSstore/UserData.json") then
					local Data = {
						TotalExecutions = 0,
						UILibrary = "Obsidian"
					}
					MSstore.Environment.writefile("MSstore/UserData.json", Services.HttpService:JSONEncode(Data))
				end

				local UserData = MSstore.Environment.readfile("MSstore/UserData.json")
				local Decoded = Services.HttpService:JSONDecode(UserData)
				Decoded.UILibrary = Value

				if not Decoded.UILibrary then
					Decoded.UILibrary = "Obsidian"
				end

				MSstore.TotalExecutions = Decoded.TotalExecutions
				MSstore.UILibrary = Decoded.UILibrary

				MSstore.Environment.writefile("MSstore/UserData.json", Services.HttpService:JSONEncode(Decoded))
			end
		end
	})

	MenuGroup:AddDropdown("DPIDropdown", {
		Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
		Default = "100%",

		Text = "DPI Scale",

		Callback = function(Value)
			Value = Value:gsub("%%", "")
			local DPI = tonumber(Value)

			Library:SetDPIScale(DPI)
		end,
	})
	MenuGroup:AddDivider()
	MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

	MenuGroup:AddButton("Unload", function()
		Library:Unload()
	end)

	Library.ToggleKeybind = Options.MenuKeybind

	ThemeManager:SetLibrary(Library)
	SaveManager:SetLibrary(Library)
	SaveManager:IgnoreThemeSettings()
	SaveManager:SetIgnoreIndexes({"UILibrary"})
	ThemeManager:SetFolder("MSstore")
	SaveManager:SetFolder("MSstore/" .. MSstore.SavePath)
	SaveManager:BuildConfigSection(SettingsTab)
	ThemeManager:ApplyToTab(SettingsTab)
	SaveManager:LoadAutoloadConfig()
end
