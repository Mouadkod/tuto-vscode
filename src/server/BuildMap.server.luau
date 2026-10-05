--[[
	Builds the map when the server starts, unless a baked copy is already in
	Workspace (see README: open build/StealAnEggMap.rbxl, or run the builder
	once from the Studio command bar and keep the result).
]]

local Lighting = game:GetService("Lighting")
local ServerScriptService = game:GetService("ServerScriptService")

if workspace:FindFirstChild("Map") then
	return
end

local MapBuilder = require(ServerScriptService.MapBuilder.MapBuilder)
MapBuilder.build(workspace, Lighting, workspace.Terrain)
