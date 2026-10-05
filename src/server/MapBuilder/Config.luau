--[[
	Every dimension of the map lives here, in studs.

	Axes: the corridor runs along +Z. X = 0 is the centre line.
	The hub (spawn, pens, shops) is the closed end at negative Z, the Safe Zone
	line sits at Z = 0, and the play area runs from there to the portal at END_Z.
	Floor tops are at Y = 0, wall tops at Y = WALL_HEIGHT.
]]

local Config = {}

Config.TILE = 12 -- checker square size for floors and walls
Config.WALL_HEIGHT = 62 -- 60 studs of checker face plus a 2 stud grass cap
Config.HALF_WIDTH = 100 -- corridor is 200 studs wide between the walls
Config.OUTER_HALF = 200 -- wall blocks are solid from |X| = 100 to 200
Config.PLATEAU_HALF = 380 -- grass plateau on top of the walls reaches this far out
Config.GROUND_DEPTH = 24 -- thickness of the dirt island under everything

Config.HUB = {
	zBack = -300,
	zFront = 0, -- the Safe Zone line
	halfWidth = 170, -- the hub is wider than the corridor
}

-- Corridor sections, in order from the Safe Zone to the portal.
Config.SECTIONS = {
	{ name = "StartField", z0 = 0, z1 = 156, floor = "grass", wall = "dirt" },
	{ name = "Stripe", z0 = 156, z1 = 168, floor = "stripe", wall = "dirt" }, -- pale band across the field
	{ name = "EggField", z0 = 168, z1 = 420, floor = "grass", wall = "dirt" },
	{ name = "Desert", z0 = 420, z1 = 840, floor = "sand", wall = "sandstone" },
	{ name = "Forest", z0 = 840, z1 = 1176, floor = "forest", wall = "dirt" },
	{ name = "Fantasy", z0 = 1176, z1 = 1488, floor = "fantasy", wall = "mauve" },
	{ name = "PortalEnd", z0 = 1488, z1 = 1620, floor = "cloud", wall = "dirt" },
}
Config.END_Z = 1620

local function rgb(r: number, g: number, b: number)
	return Color3.fromRGB(r, g, b)
end
Config.rgb = rgb

-- Two-tone checker palettes: { light, dark }
Config.CHECKER = {
	grass = { rgb(104, 222, 62), rgb(92, 206, 52) },
	stripe = { rgb(184, 232, 120), rgb(172, 222, 108) },
	forest = { rgb(84, 196, 58), rgb(74, 182, 50) },
	sand = { rgb(242, 220, 158), rgb(232, 208, 144) },
	fantasy = { rgb(238, 160, 224), rgb(224, 144, 212) },
	cloud = { rgb(236, 242, 255), rgb(216, 228, 252) },
	dirt = { rgb(196, 128, 78), rgb(178, 112, 66) },
	sandstone = { rgb(226, 192, 122), rgb(210, 174, 104) },
	mauve = { rgb(178, 116, 132), rgb(160, 102, 118) },
}

Config.COLORS = {
	grassTop = rgb(64, 230, 50),
	dirtCore = rgb(150, 96, 58),
	wood = rgb(160, 92, 48),
	woodDark = rgb(112, 62, 30),
	leaf = rgb(70, 170, 50),
	leafDark = rgb(48, 140, 40),
	safeLine = rgb(255, 70, 110),
	machineDark = rgb(36, 38, 44),
	machineMid = rgb(62, 66, 76),
	toxic = rgb(120, 255, 40),
	lime = rgb(205, 240, 40),
	cyan = rgb(40, 210, 255),
	fuseBlue = rgb(40, 86, 210),
	white = rgb(255, 255, 255),
	black = rgb(0, 0, 0),
}

return Config
