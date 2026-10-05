--[[
	The map's shell: checker floors, the tall checker walls with their grass
	caps, the grass plateau outside them, the dirt island underneath, and the
	Safe Zone line with its ground lettering.
]]

local Config = require(script.Parent.Config)
local Util = require(script.Parent.Util)

local Shell = {}

local TILE = Config.TILE
local H = Config.WALL_HEIGHT
local FACE = H - 2 -- height of the checker face below the grass cap
local HW = Config.HALF_WIDTH
local PH = Config.PLATEAU_HALF
local HUB = Config.HUB
local C = Config.COLORS

-- Normals for wall faces (see Util.checker: local +Y is the outward normal).
local FACING_POS_X = CFrame.Angles(0, 0, -math.pi / 2)
local FACING_NEG_X = CFrame.Angles(0, 0, math.pi / 2)
local FACING_POS_Z = CFrame.Angles(math.pi / 2, 0, 0)
local FACING_NEG_Z = CFrame.Angles(-math.pi / 2, 0, 0)

local function floor(parent: Instance, name: string, x0: number, x1: number, z0: number, z1: number, palette)
	Util.checker(parent, name, CFrame.new((x0 + x1) / 2, 0, (z0 + z1) / 2), x1 - x0, z1 - z0, TILE, palette)
end

-- A block of raised ground: dirt core with a grass cap on top.
local function highland(parent: Instance, name: string, a: Vector3, b: Vector3)
	local m = Util.model(parent, name)
	Util.box(m, Vector3.new(a.X, -1, a.Z), Vector3.new(b.X, H - 2, b.Z), C.dirtCore, { name = "Core" })
	Util.box(m, Vector3.new(a.X, H - 2, a.Z), Vector3.new(b.X, H, b.Z), C.grassTop, { name = "GrassCap" })
	return m
end

-- Thin vivid grass lip along the inner top edge of a wall.
local function lip(parent: Instance, a: Vector3, b: Vector3)
	Util.box(parent, a, b, C.grassTop, { name = "GrassLip", shadow = false })
end

local function sideWalls(parent: Instance, name: string, z0: number, z1: number, palette)
	local len = z1 - z0
	local zc = (z0 + z1) / 2
	Util.checker(parent, name .. "WallL", CFrame.new(-HW, FACE / 2, zc) * FACING_POS_X, FACE, len, TILE, palette)
	Util.checker(parent, name .. "WallR", CFrame.new(HW, FACE / 2, zc) * FACING_NEG_X, FACE, len, TILE, palette)
end

function Shell.build(map: Instance)
	local root = Util.folder(map, "Shell")
	local floors = Util.folder(root, "Floors")
	local walls = Util.folder(root, "Walls")
	local land = Util.folder(root, "Highlands")

	-- Dirt island under everything; its edges show below the plateau.
	Util.box(root, Vector3.new(-PH, -Config.GROUND_DEPTH, HUB.zBack - 80), Vector3.new(PH, -1, Config.END_Z + 80), C.dirtCore, {
		name = "Island",
	})

	-- Hub floor and walls.
	floor(floors, "HubFloor", -HUB.halfWidth, HUB.halfWidth, HUB.zBack, HUB.zFront, Config.CHECKER.grass)
	local hubLen = HUB.zFront - HUB.zBack
	local hubZc = (HUB.zBack + HUB.zFront) / 2
	local dirt = Config.CHECKER.dirt
	Util.checker(walls, "HubWallL", CFrame.new(-HUB.halfWidth, FACE / 2, hubZc) * FACING_POS_X, FACE, hubLen, TILE, dirt)
	Util.checker(walls, "HubWallR", CFrame.new(HUB.halfWidth, FACE / 2, hubZc) * FACING_NEG_X, FACE, hubLen, TILE, dirt)
	Util.checker(walls, "HubWallBack", CFrame.new(0, FACE / 2, HUB.zBack) * FACING_POS_Z, HUB.halfWidth * 2, FACE, TILE, dirt)
	-- The corridor walls end in two faces looking back into the hub.
	local jutW = HUB.halfWidth - HW
	Util.checker(walls, "HubJutL", CFrame.new(-(HW + jutW / 2), FACE / 2, HUB.zFront) * FACING_NEG_Z, jutW, FACE, TILE, dirt)
	Util.checker(walls, "HubJutR", CFrame.new(HW + jutW / 2, FACE / 2, HUB.zFront) * FACING_NEG_Z, jutW, FACE, TILE, dirt)

	highland(land, "HubLeft", Vector3.new(-PH, 0, HUB.zBack), Vector3.new(-(HUB.halfWidth + 1), 0, HUB.zFront))
	highland(land, "HubRight", Vector3.new(HUB.halfWidth + 1, 0, HUB.zBack), Vector3.new(PH, 0, HUB.zFront))
	highland(land, "HubBack", Vector3.new(-PH, 0, HUB.zBack - 80), Vector3.new(PH, 0, HUB.zBack - 1))
	lip(land, Vector3.new(-HUB.halfWidth - 1.5, H, HUB.zBack - 1.5), Vector3.new(-HUB.halfWidth + 0.5, H + 0.6, HUB.zFront))
	lip(land, Vector3.new(HUB.halfWidth - 0.5, H, HUB.zBack - 1.5), Vector3.new(HUB.halfWidth + 1.5, H + 0.6, HUB.zFront))
	lip(land, Vector3.new(-HUB.halfWidth, H, HUB.zBack - 1.5), Vector3.new(HUB.halfWidth, H + 0.6, HUB.zBack + 0.5))
	lip(land, Vector3.new(-HUB.halfWidth, H, HUB.zFront - 0.5), Vector3.new(-HW, H + 0.6, HUB.zFront + 1.5))
	lip(land, Vector3.new(HW, H, HUB.zFront - 0.5), Vector3.new(HUB.halfWidth, H + 0.6, HUB.zFront + 1.5))

	-- Corridor, section by section.
	for _, s in Config.SECTIONS do
		floor(floors, s.name .. "Floor", -HW, HW, s.z0, s.z1, Config.CHECKER[s.floor])
		sideWalls(walls, s.name, s.z0, s.z1, Config.CHECKER[s.wall])
	end
	highland(land, "CorridorLeft", Vector3.new(-PH, 0, HUB.zFront), Vector3.new(-(HW + 1), 0, Config.END_Z + 1))
	highland(land, "CorridorRight", Vector3.new(HW + 1, 0, HUB.zFront), Vector3.new(PH, 0, Config.END_Z + 1))
	highland(land, "FarEnd", Vector3.new(-HW - 1, 0, Config.END_Z + 1), Vector3.new(HW + 1, 0, Config.END_Z + 80))
	lip(land, Vector3.new(-HW - 1.5, H, HUB.zFront), Vector3.new(-HW + 0.5, H + 0.6, Config.END_Z + 1.5))
	lip(land, Vector3.new(HW - 0.5, H, HUB.zFront), Vector3.new(HW + 1.5, H + 0.6, Config.END_Z + 1.5))
	lip(land, Vector3.new(-HW, H, Config.END_Z - 0.5), Vector3.new(HW, H + 0.6, Config.END_Z + 1.5))
	Util.checker(walls, "EndWall", CFrame.new(0, FACE / 2, Config.END_Z) * FACING_NEG_Z, HW * 2, FACE, TILE, dirt)

	-- Safe Zone: glowing line across the corridor mouth, ground lettering on
	-- the hub side, and an invisible volume that gameplay code can query.
	local safe = Util.model(map, "SafeZone")
	Util.part(safe, Vector3.new(HW * 2, 0.2, 0.8), CFrame.new(0, 0.1, HUB.zFront), C.safeLine, {
		name = "SafeZoneLine",
		material = Enum.Material.Neon,
		collide = false,
		shadow = false,
	})
	-- Front face turned to the sky; text reads correctly when facing +Z from the hub.
	local letters = Util.part(safe, Vector3.new(64, 9, 0.1), CFrame.new(0, 0.06, HUB.zFront - 9) * CFrame.Angles(math.pi / 2, 0, 0), C.white, {
		name = "SafeZoneText",
		transparency = 1,
		collide = false,
		shadow = false,
	})
	Util.surfaceText(letters, Enum.NormalId.Front, {
		{ text = "🛡️ SAFE ZONE 🛡️", color = C.white, stroke = Config.rgb(40, 40, 60) },
	})
	local volume = Util.box(safe, Vector3.new(-HUB.halfWidth, 0, HUB.zBack), Vector3.new(HUB.halfWidth, H, HUB.zFront), C.white, {
		name = "SafeZoneVolume",
		transparency = 1,
		collide = false,
		shadow = false,
	})
	volume.CanQuery = true
	volume.CanTouch = true
	volume:SetAttribute("SafeZone", true)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "HubSpawn"
	spawn.Anchored = true
	spawn.Size = Vector3.new(16, 1, 16)
	spawn.CFrame = CFrame.new(0, 0.5, -70)
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.Duration = 0
	spawn.Parent = map
end

return Shell
