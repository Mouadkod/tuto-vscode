--[[
	Entry point: builds the whole map under a Model named "Map".

		local MapBuilder = require(game.ServerScriptService.MapBuilder.MapBuilder)
		MapBuilder.build(workspace, game.Lighting, workspace.Terrain)

	Order from the closed end to the far end (+Z):
	hub with pens and shops -> Safe Zone line -> start field -> pale stripe ->
	egg field -> desert -> forest -> fantasy -> portal.
]]

local Util = require(script.Parent.Util)
local Shell = require(script.Parent.Shell)
local Hub = require(script.Parent.Hub)
local Biomes = require(script.Parent.Biomes)
local Portal = require(script.Parent.Portal)
local Environment = require(script.Parent.Environment)

local MapBuilder = {}

MapBuilder.SEED = 20261005

function MapBuilder.build(parent: Instance, lighting: Lighting?, terrain: Terrain?): Model
	local old = parent:FindFirstChild("Map")
	if old then
		old:Destroy()
	end
	local map = Instance.new("Model")
	map.Name = "Map"
	local rng = Util.rng(MapBuilder.SEED)
	Shell.build(map)
	Hub.build(map, rng)
	Biomes.build(map, rng)
	Portal.build(map, rng)
	-- Parent last so the whole map replicates in one go.
	map.Parent = parent
	if lighting then
		Environment.apply(lighting, terrain)
	end
	return map
end

return MapBuilder
