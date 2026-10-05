--[[
	The visual endpoint at the far end of the corridor: a stepped platform,
	a glowing ringed portal with crystal pillars, a rainbow arch, a ringed
	planet and tall light beams that show from across the map.
]]

local Config = require(script.Parent.Config)
local Util = require(script.Parent.Util)
local Props = require(script.Parent.Props)

local Portal = {}

local rgb = Config.rgb
local V = Vector3.new
local CF = CFrame.new
local NEON = Enum.Material.Neon

function Portal.build(map: Instance, rng)
	local s = Config.SECTIONS[#Config.SECTIONS]
	local m = Util.model(map, "Portal")
	local zc = Config.END_Z - 35 -- portal plane
	local cyan, purple, pink, blue = rgb(60, 230, 255), rgb(170, 80, 255), rgb(255, 90, 210), rgb(70, 120, 255)

	-- Stepped platform.
	local stepColors = { rgb(232, 226, 255), rgb(206, 196, 252), rgb(240, 236, 255) }
	for i = 0, 2 do
		local half = 62 - i * 11
		Util.box(m, V(-half, i * 2, s.z0 + 40 + i * 15), V(half, (i + 1) * 2, Config.END_Z), stepColors[i + 1], {
			name = "Step",
		})
		Util.box(m, V(-half, (i + 1) * 2 - 0.3, s.z0 + 40 + i * 15 - 0.4), V(half, (i + 1) * 2, s.z0 + 40 + i * 15 + 0.6), cyan, {
			name = "StepEdge",
			material = NEON,
			shadow = false,
		})
	end
	local top = 6

	-- Ring portal facing back down the corridor.
	local center = CF(0, top + 34, zc)
	Util.arc(m, center, 32, 4, 4, 0, math.pi * 2, 44, cyan, { name = "RingOuter", material = NEON })
	Util.arc(m, center, 28, 3, 3.4, 0, math.pi * 2, 40, purple, { name = "RingMid", material = NEON })
	Util.arc(m, center, 24.6, 2.6, 3, 0, math.pi * 2, 36, pink, { name = "RingInner", material = NEON })
	local disc = Util.part(m, V(0.8, 47, 47), center * CFrame.Angles(0, math.pi / 2, 0), purple, {
		name = "PortalSurface",
		shape = Enum.PartType.Cylinder,
		material = Enum.Material.ForceField,
		collide = false,
	})
	Util.part(m, V(0.6, 46, 46), center * CF(0, 0, 1) * CFrame.Angles(0, math.pi / 2, 0), blue, {
		name = "PortalGlow",
		shape = Enum.PartType.Cylinder,
		material = NEON,
		transparency = 0.45,
		collide = false,
	})
	local glow = Instance.new("PointLight")
	glow.Color = purple
	glow.Range = 60
	glow.Brightness = 5
	glow.Parent = disc
	disc:SetAttribute("Portal", true)
	Util.part(m, V(5, 5, 5), center * CF(0, 36.5, 0) * CFrame.Angles(0, 0, math.pi / 4), rgb(255, 230, 60), {
		name = "Star",
		material = NEON,
	})

	-- Crystal pillars either side.
	for side = -1, 1, 2 do
		local x = side * 42
		Util.part(m, V(9, 70, 9), CF(x, top + 35, zc), rgb(80, 60, 190), { name = "Pillar", material = Enum.Material.Glass, transparency = 0.1 })
		Util.part(m, V(3, 66, 9.4), CF(x, top + 35, zc), cyan, { name = "PillarCore", material = NEON })
		Util.part(m, V(12, 8.6, 12), CF(x, 4.3, zc), rgb(200, 190, 250), { name = "PillarBase" })
		Util.part(m, V(8, 8, 8), CF(x, top + 74, zc) * CFrame.Angles(math.pi / 4, 0, math.pi / 4), pink, {
			name = "PillarGem",
			material = NEON,
		})
		-- Sky beams so the end is visible from the hub.
		Util.cylinder(m, 2.2, 300, CF(x, top + 78 + 150, zc), if side < 0 then cyan else pink, {
			name = "SkyBeam",
			material = NEON,
			transparency = 0.55,
			collide = false,
			shadow = false,
		})
		for k = 1, 3 do
			Props.crystal(m, CF(side * rng.range(66, 90), 0, zc + rng.range(-20, 25)), rng, if k % 2 == 0 then cyan else purple)
		end
	end
	Util.cylinder(m, 3, 300, CF(0, top + 80 + 150, zc + 6), purple, {
		name = "SkyBeam",
		material = NEON,
		transparency = 0.6,
		collide = false,
		shadow = false,
	})

	-- Rainbow arch behind the portal.
	local colors = {
		rgb(255, 60, 60),
		rgb(255, 150, 40),
		rgb(255, 230, 50),
		rgb(70, 220, 80),
		rgb(60, 150, 255),
		rgb(110, 80, 230),
		rgb(190, 90, 240),
	}
	for i, col in colors do
		Util.arc(m, CF(0, top, zc + 18), 64 - (i - 1) * 2.8, 2.8, 2, 0, math.pi, 32, col, {
			name = "Rainbow",
			material = NEON,
			collide = false,
		})
	end

	-- Ringed planet floating up and to the left.
	local planet = CF(-52, top + 96, zc - 4)
	Util.ball(m, 10, planet, rgb(130, 70, 230), { name = "Planet", collide = false })
	Util.ball(m, 4, planet * CF(-6, 5, -6), rgb(190, 120, 255), { name = "PlanetSpot", collide = false })
	Util.arc(m, planet * CFrame.Angles(math.rad(70), math.rad(20), 0), 16, 1.6, 3, 0, math.pi * 2, 28, cyan, {
		name = "PlanetRing",
		material = NEON,
		collide = false,
	})

	-- Neon gateway arches over the approach.
	for i, col in { pink, cyan, purple } do
		Util.arc(m, CF(0, 0, s.z0 + i * 12), 30, 2, 2, 0, math.pi, 24, col, {
			name = "Gateway",
			material = NEON,
			collide = false,
		})
	end

	-- Floating blocks around the portal.
	for _ = 1, 10 do
		local col = rng.pick({ cyan, purple, pink, rgb(255, 230, 60) })
		Util.part(m, V(1, 1, 1) * rng.range(2, 4), CF(rng.range(-80, 80), rng.range(20, 80), zc + rng.range(-30, 10)) * CFrame.Angles(rng.range(0, 3), rng.range(0, 3), rng.range(0, 3)), col, {
			name = "FloatingCube",
			material = NEON,
			collide = false,
		})
	end
end

return Portal
