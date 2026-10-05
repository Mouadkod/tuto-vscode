--[[
	Decoration for the play corridor, section by section, plus the scenery on
	the plateau outside the walls. Props hug the walls so the centre route
	(|X| < 40) stays open.
]]

local Config = require(script.Parent.Config)
local Util = require(script.Parent.Util)
local Props = require(script.Parent.Props)

local Biomes = {}

local rgb = Config.rgb
local C = Config.COLORS
local V = Vector3.new
local CF = CFrame.new
local HW = Config.HALF_WIDTH
local H = Config.WALL_HEIGHT

local function section(name: string)
	for _, s in Config.SECTIONS do
		if s.name == name then
			return s
		end
	end
	error("unknown section " .. name)
end

local function yaw(rng): CFrame
	return CFrame.Angles(0, rng.range(0, math.pi * 2), 0)
end

-- Random X near one of the walls, keeping clear of the centre route.
local function sideX(rng, inner: number?, outer: number?): number
	local x = rng.range(inner or 55, outer or (HW - 8))
	return if rng.next() < 0.5 then -x else x
end

-- Invisible volume marking where gameplay code may spawn eggs.
local function eggZone(parent: Instance, s)
	local zone = Util.box(parent, V(-HW + 10, 0, s.z0 + 6), V(HW - 10, 1, s.z1 - 6), C.white, {
		name = s.name .. "EggZone",
		transparency = 1,
		collide = false,
		shadow = false,
	})
	zone:SetAttribute("EggZone", s.name)
end

local function startField(parent: Instance, rng)
	local f = Util.folder(parent, "StartField")
	Props.hedge(f, CF(-35, 0, 115), rng)
	Props.hedge(f, CF(62, 0, 92) * CFrame.Angles(0, 0.5, 0), rng)
	Props.rock(f, CF(-62, 0, 62), rng)
	for _ = 1, 8 do
		Props.flower(f, CF(rng.range(-90, 90), 0, rng.range(20, 150)), rng)
	end
end

local function eggField(parent: Instance, rng)
	local s = section("EggField")
	local f = Util.folder(parent, s.name)
	-- Little cluster by the left wall, as in the reference.
	local sign = Util.model(f, "WoodSign")
	Util.part(sign, V(0.7, 3, 0.7), CF(-84, 1.5, 340), C.woodDark, { name = "Post" })
	local board = Util.part(sign, V(5, 2.4, 0.4), CF(-84, 3.6, 340) * CFrame.Angles(0, -math.pi / 2, 0), rgb(214, 120, 40), { name = "Board" })
	Util.surfaceText(board, Enum.NormalId.Front, { { text = "Desert ➜", color = C.white, stroke = C.black } })
	Props.reeds(f, CF(-95, 0, 352), rng)
	Props.reeds(f, CF(-96, 0, 330), rng)
	Props.rock(f, CF(-74, 0, 362), rng, rgb(150, 170, 150))
	Props.mushroom(f, CF(-78, 0, 330), rng, rgb(240, 70, 70))
	for _ = 1, 6 do
		Props.flower(f, CF(rng.range(-95, -70), 0, rng.range(320, 380)), rng)
		Props.flower(f, CF(rng.range(70, 95), 0, rng.range(200, 400)), rng)
	end
	Props.bush(f, CF(88, 0, 260), rng)
	Props.bush(f, CF(-90, 0, 230), rng)
	eggZone(f, s)

	-- "Titanic Egg" banner spanning the corridor between the wall tops.
	local banner = Util.model(f, "TitanicEggBanner")
	local z = s.z1 - 12
	Util.part(banner, V(HW * 2 + 6, 3, 3), CF(0, H - 4, z), rgb(150, 70, 60), { name = "Beam" })
	local board = Util.part(banner, V(110, 14, 1.5), CF(0, H - 12, z), rgb(170, 64, 64), { name = "Board" })
	Util.part(banner, V(112, 15, 1.2), CF(0, H - 12, z + 0.3), rgb(120, 40, 40), { name = "BoardFrame" })
	local text = {
		{
			text = '<font color="#b24bff">???</font> <font color="#2f6bff">Ti</font><font color="#1fd0ff">ta</font><font color="#3ce36b">ni</font><font color="#ffd400">c</font> <font color="#ff4b4b">Egg</font>',
			color = C.white,
			stroke = rgb(30, 20, 40),
			weight = 1.6,
		},
		{ text = "Spawns In: --:--", color = C.white, stroke = rgb(30, 20, 40), weight = 1 },
	}
	Util.surfaceText(board, Enum.NormalId.Front, text)
	Util.surfaceText(board, Enum.NormalId.Back, text)
end

local function desert(parent: Instance, rng)
	local s = section("Desert")
	local f = Util.folder(parent, s.name)
	local z0 = s.z0
	Props.pyramid(f, CF(-58, 0, z0 + 50), 36, 4)

	-- Sunken-looking arena outline drawn on the sand in the middle.
	local outline = rgb(214, 186, 128)
	local function frame(x0: number, x1: number, za: number, zb: number, w: number)
		local y = 0.05
		Util.box(f, V(x0, -0.2, za), V(x1, y, za + w), outline, { name = "SandLine", shadow = false })
		Util.box(f, V(x0, -0.2, zb - w), V(x1, y, zb), outline, { name = "SandLine", shadow = false })
		Util.box(f, V(x0, -0.2, za), V(x0 + w, y, zb), outline, { name = "SandLine", shadow = false })
		Util.box(f, V(x1 - w, -0.2, za), V(x1, y, zb), outline, { name = "SandLine", shadow = false })
	end
	frame(-40, 40, z0 + 40, z0 + 110, 2)
	frame(-28, 28, z0 + 52, z0 + 98, 1.2)

	-- Oasis pond on the right.
	local pond = Util.model(f, "Oasis")
	Util.part(pond, V(26, 0.4, 16), CF(66, 0.1, z0 + 180), rgb(60, 170, 255), {
		name = "Water",
		material = Enum.Material.Glass,
		transparency = 0.2,
		collide = false,
	})
	for _, o in { V(-14, 0, 0), V(14, 0, 0), V(0, 0, -9), V(0, 0, 9) } do
		Props.rock(pond, CF(V(66, 0, z0 + 180) + o), rng, rgb(200, 170, 120))
	end
	Props.palm(pond, CF(84, 0, z0 + 190), rng)

	-- Stepped sandstone formations against the walls (each steps out along its local +Z).
	Props.terrace(f, CF(-HW, 0, z0 + 150) * CFrame.Angles(0, math.pi / 2, 0), rng, 50)
	Props.terrace(f, CF(-HW, 0, z0 + 300) * CFrame.Angles(0, math.pi / 2, 0), rng, 34)
	Props.terrace(f, CF(HW, 0, z0 + 330) * CFrame.Angles(0, -math.pi / 2, 0), rng, 44)
	Props.terrace(f, CF(HW, 0, z0 + 70) * CFrame.Angles(0, -math.pi / 2, 0), rng, 26)

	for _, p in { V(-88, 0, 35), V(86, 0, 100), V(-80, 0, 220), V(84, 0, 280), V(-70, 0, 370), V(60, 0, 380), V(-90, 0, 120), V(92, 0, 240) } do
		Props.cactus(f, CF(V(0, 0, z0) + p) * yaw(rng), rng)
	end
	for _ = 1, 10 do
		Props.rock(f, CF(sideX(rng, 50), 0, z0 + rng.range(20, 380)) * yaw(rng), rng, rgb(196, 160, 110))
	end
	for _ = 1, 5 do
		Props.deadTree(f, CF(sideX(rng, 60), 0, z0 + rng.range(30, 360)) * yaw(rng), rng)
	end
	for _ = 1, 8 do
		Props.bush(f, CF(sideX(rng, 50), 0, z0 + rng.range(20, 380)), rng, rgb(150, 170, 80))
	end
	-- Palms and blue crystals where the desert meets the next biome.
	Props.palm(f, CF(-82, 0, s.z1 - 22), rng)
	Props.palm(f, CF(-66, 0, s.z1 - 12), rng)
	Props.palm(f, CF(80, 0, s.z1 - 30), rng)
	Props.crystal(f, CF(-52, 0, s.z1 - 10), rng, rgb(80, 200, 255))
	Props.crystal(f, CF(50, 0, s.z1 - 14), rng, rgb(80, 200, 255))
	eggZone(f, s)
end

local function forest(parent: Instance, rng)
	local s = section("Forest")
	local f = Util.folder(parent, s.name)
	local z = s.z0 + 12
	while z < s.z1 - 10 do
		for side = -1, 1, 2 do
			local x = side * rng.range(62, 90)
			if rng.next() < 0.6 then
				Props.tree(f, CF(x, 0, z + rng.range(-6, 6)) * yaw(rng), rng, "green")
			else
				Props.pine(f, CF(x, 0, z + rng.range(-6, 6)) * yaw(rng), rng)
			end
		end
		z += rng.range(22, 32)
	end
	for _ = 1, 14 do
		Props.bush(f, CF(sideX(rng, 40, 70), 0, rng.range(s.z0 + 10, s.z1 - 10)), rng)
	end
	for _ = 1, 8 do
		Props.rock(f, CF(sideX(rng, 45), 0, rng.range(s.z0 + 10, s.z1 - 10)) * yaw(rng), rng)
	end
	for _ = 1, 16 do
		Props.flower(f, CF(sideX(rng, 38), 0, rng.range(s.z0, s.z1)), rng)
	end
	eggZone(f, s)
end

local function fantasy(parent: Instance, rng)
	local s = section("Fantasy")
	local f = Util.folder(parent, s.name)
	local z = s.z0 + 14
	local trunk = rgb(150, 70, 120)
	while z < s.z1 - 10 do
		for side = -1, 1, 2 do
			local palette = if rng.next() < 0.5 then "pink" else "purple"
			Props.tree(f, CF(side * rng.range(60, 90), 0, z + rng.range(-6, 6)) * yaw(rng), rng, palette, trunk)
		end
		z += rng.range(24, 34)
	end
	for _ = 1, 10 do
		local col = rng.pick({ rgb(90, 220, 255), rgb(190, 110, 255), rgb(255, 110, 210) })
		Props.crystal(f, CF(sideX(rng, 42, 70), 0, rng.range(s.z0 + 10, s.z1 - 10)), rng, col)
	end
	for _ = 1, 8 do
		local col = rng.pick({ rgb(255, 80, 180), rgb(170, 80, 255), rgb(80, 200, 255) })
		Props.mushroom(f, CF(sideX(rng, 40, 85), 0, rng.range(s.z0 + 10, s.z1 - 10)), rng, col)
	end
	for _ = 1, 16 do
		Props.flower(f, CF(sideX(rng, 38), 0, rng.range(s.z0, s.z1)), rng)
	end
	eggZone(f, s)
end

-- Rainbow arch, standing on the plateau.
local function rainbow(parent: Instance, base: CFrame, radius: number)
	local colors = {
		rgb(255, 60, 60),
		rgb(255, 150, 40),
		rgb(255, 230, 50),
		rgb(70, 220, 80),
		rgb(60, 150, 255),
		rgb(110, 80, 230),
		rgb(190, 90, 240),
	}
	local m = Util.model(parent, "Rainbow")
	for i, col in colors do
		Util.arc(m, base, radius - (i - 1) * 2.4, 2.4, 2, 0, math.pi, 22, col, {
			name = "Band",
			collide = false,
			shadow = false,
		})
	end
	return m
end

-- Trees and props on top of the walls so the canyon reads from above.
local function plateau(parent: Instance, rng)
	local f = Util.folder(parent, "Plateau")
	local function themeAt(z: number): string
		for _, s in Config.SECTIONS do
			if z >= s.z0 and z < s.z1 then
				return s.name
			end
		end
		return if z < 0 then "Hub" else "PortalEnd"
	end
	local z = Config.HUB.zBack - 60
	while z < Config.END_Z + 60 do
		for side = -1, 1, 2 do
			for _ = 1, 2 do
				local inner = if z < 0 then Config.HUB.halfWidth + 12 else HW + 12
				local x = side * rng.range(inner, Config.PLATEAU_HALF - 10)
				local cf = CF(x, H, z + rng.range(-15, 15)) * yaw(rng)
				local theme = themeAt(z)
				local roll = rng.next()
				if theme == "Desert" then
					if roll < 0.5 then
						Props.cactus(f, cf, rng, 1.3)
					elseif roll < 0.75 then
						Props.palm(f, cf, rng)
					else
						Props.deadTree(f, cf, rng)
					end
				elseif theme == "Fantasy" then
					Props.tree(f, cf, rng, if roll < 0.5 then "pink" else "purple", rgb(150, 70, 120))
				elseif theme == "PortalEnd" then
					Props.crystal(f, cf, rng, if roll < 0.5 then rgb(90, 220, 255) else rgb(200, 110, 255))
				elseif roll < 0.45 then
					Props.tree(f, cf, rng, "green", if rng.next() < 0.4 then rgb(170, 60, 70) else nil)
				elseif roll < 0.75 then
					Props.pine(f, cf, rng)
				elseif roll < 0.88 then
					Props.rock(f, cf, rng)
				else
					Props.tree(f, cf, rng, "autumn")
				end
			end
		end
		z += rng.range(36, 48)
	end
	-- Two rainbows over the far plateau, visible from the hub.
	rainbow(f, CF(-260, H, 300), 40)
	rainbow(f, CF(250, H, 260), 34)
end

function Biomes.build(map: Instance, rng)
	local play = Util.folder(map, "PlayArea")
	startField(play, rng)
	eggField(play, rng)
	desert(play, rng)
	forest(play, rng)
	fantasy(play, rng)
	plateau(map, rng)
end

return Biomes
