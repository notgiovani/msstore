if MSstore then
	return 
end
getgenv().MSstore = {
	Legit = true
}

local GameList = {
	[2440500124] = "Doors"
}

local BaseUrl = "https://raw.githubusercontent.com/notgiovani/msstore/refs/heads/main/"
getgenv().MSstore = {
	Environment = loadstring(game:HttpGet(BaseUrl .. "Components/Environment.luau"))(),
	ESPLibrary = loadstring(game:HttpGet(BaseUrl .. "Components/ESP.luau"))(),

	Legit = true,
}

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
	if not Decoded.TotalExecutions then
		Decoded.TotalExecutions = 0    
	end

	Decoded.TotalExecutions = Decoded.TotalExecutions + 1

	if not Decoded.UILibrary then
		Decoded.UILibrary = "Obsidian"
	end

	MSstore.TotalExecutions = Decoded.TotalExecutions
	MSstore.UILibrary = Decoded.UILibrary

	MSstore.Environment.writefile("MSstore/UserData.json", Services.HttpService:JSONEncode(Decoded))
end

MSstore.Interface = loadstring(game:HttpGet(BaseUrl .. "Components/Interface.luau"))()

local CurrentGame = GameList[game.GameId]
if CurrentGame then
	loadstring(game:HttpGet(BaseUrl .. "Games/" .. CurrentGame .. "/Loader.luau"))()
else
	loadstring(game:HttpGet(BaseUrl .. "Games/Universal/Loader.luau"))()
end
