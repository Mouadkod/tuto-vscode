--[[
	Low-poly decoration props, all built from blocks.
	Every builder takes a parent, a ground CFrame (the prop's base, facing -Z)
	and the shared rng, and returns the prop's Model.
]]

local Config = require(script.Parent.Config)
local Util = require(script.Parent.Util)

local Props = {}

local rgb = Config.rgb
local C = Config.COLORS
local V = Vector3.new
local CF = CFrame.new

Props.LEAF_PALETTES = {
	green = { rgb(76, 176, 52), rgb(58, 150, 44), rgb(96, 196, 64) },
	pink = { rgb(255, 128, 214), rgb(236, 98, 196), rgb(255, 164, 228) },
	purple = { rgb(168, 92, 236), rgb(140, 70, 214), rgb(196, 128, 255) },
	autumn = { rgb(200, 72, 88), rgb(170, 52, 70), rgb(226, 104, 112) },
}

function Props.tree(parent: Instance, cf: CFrame, rng, palette: string?, trunkColor: Color3?): Model
	local m = Util.model(parent, "Tree")
	local leaves = Props.LEAF_PALETTES[palette or "green"]
	local trunkH = rng.range(9, 15)
	Util.part(m, V(2.6, trunkH, 2.6), cf * CF(0, trunkH / 2, 0), trunkColor or rgb(122, 74, 40), { name = "Trunk" })
	local s = rng.range(9, 13)
	Util.part(m, V(s, s * 0.8, s), cf * CF(0, trunkH + s * 0.3, 0), leaves[1], { name = "Leaves", studs = true })
	for k = 1, rng.int(2, 3) do
		local ss = s * rng.range(0.5, 0.7)
		local off = V(rng.range(-s / 2, s / 2), trunkH + s * rng.range(0.3, 0.8), rng.range(-s / 2, s / 2))
		Util.part(m, V(ss, ss * 0.8, ss), cf * CF(off), leaves[k % #leaves + 1], { name = "Leaves", studs = true })
	end
	return m
end

function Props.pine(parent: Instance, cf: CFrame, rng): Model
	local m = Util.model(parent, "Pine")
	local h = rng.range(3, 5)
	Util.part(m, V(1.8, h, 1.8), cf * CF(0, h / 2, 0), rgb(110, 68, 38), { name = "Trunk" })
	local y = h
	local w = rng.range(8, 10)
	for i = 1, 4 do
		local layerH = 3
		Util.part(m, V(w, layerH, w), cf * CF(0, y + layerH / 2, 0), if i % 2 == 0 then C.leafDark else rgb(52, 156, 60), {
			name = "Layer",
			studs = true,
		})
		y += layerH
		w *= 0.72
	end
	return m
end

function Props.palm(parent: Instance, cf: CFrame, rng): Model
	local m = Util.model(parent, "Palm")
	local lean = rng.range(0.6, 1.2)
	local top = cf
	for i = 0, 5 do
		local seg = cf * CF(lean * i * 0.35 * i * 0.3, 1.5 + i * 3, 0)
		Util.part(m, V(2, 3.2, 2), seg, if i % 2 == 0 then rgb(150, 104, 58) else rgb(128, 86, 46), { name = "Trunk" })
		top = seg
	end
	for k = 0, 5 do
		local a = k * math.pi / 3 + rng.range(-0.2, 0.2)
		Util.part(m, V(1.6, 0.6, 9), top * CF(0, 1.6, 0) * CFrame.Angles(0, a, 0) * CFrame.Angles(-0.35, 0, 0) * CF(0, 0, -4.2), rgb(50, 170, 60), {
			name = "Frond",
		})
	end
	return m
end

function Props.cactus(parent: Instance, cf: CFrame, rng, scale: number?): Model
	local m = Util.model(parent, "Cactus")
	local s = scale or 1
	local green, light = rgb(104, 176, 70), rgb(138, 204, 92)
	local h = rng.range(8, 13) * s
	Util.part(m, V(2.6 * s, h, 2.6 * s), cf * CF(0, h / 2, 0), green, { name = "Stem" })
	Util.part(m, V(2.8, 0.6, 2.8) * s, cf * CF(0, h, 0), light, { name = "Top" })
	for side = -1, 1, 2 do
		if rng.next() < 0.75 then
			local y = h * rng.range(0.35, 0.6)
			local reach = 2.6 * s
			Util.part(m, V(reach, 1.8 * s, 1.8 * s), cf * CF(side * (1.3 * s + reach / 2), y, 0), green, { name = "Arm" })
			local up = h * rng.range(0.2, 0.35)
			Util.part(m, V(1.8, up, 1.8) * V(s, 1, s), cf * CF(side * (1.3 * s + reach - 0.9 * s), y + up / 2, 0), green, {
				name = "Arm",
			})
		end
	end
	return m
end

function Props.deadTree(parent: Instance, cf: CFrame, rng): Model
	local m = Util.model(parent, "DeadTree")
	local bark = rgb(104, 72, 48)
	local h = rng.range(8, 12)
	Util.part(m, V(1.6, h, 1.6), cf * CF(0, h / 2, 0), bark, { name = "Trunk" })
	for k = 1, 3 do
		local y = h * (0.45 + k * 0.15)
		local a = rng.range(0, math.pi * 2)
		local len = rng.range(3, 5)
		Util.part(m, V(0.8, len, 0.8), cf * CF(0, y, 0) * CFrame.Angles(0, a, 0) * CFrame.Angles(0, 0, 0.8) * CF(0, len / 2, 0), bark, {
			name = "Branch",
		})
	end
	return m
end

function Props.rock(parent: Instance, cf: CFrame, rng, color: Color3?): Model
	local m = Util.model(parent, "Rock")
	local base = color or rgb(128, 132, 140)
	for _ = 1, rng.int(1, 3) do
		local s = V(rng.range(2.5, 5), rng.range(1.5, 3.5), rng.range(2.5, 5))
		Util.part(m, s, cf * CF(rng.range(-2, 2), s.Y / 2 - 0.2, rng.range(-2, 2)) * CFrame.Angles(0, rng.range(0, 3), rng.range(-0.15, 0.15)), base:Lerp(C.white, rng.range(0, 0.15)), {
			name = "Stone",
		})
	end
	return m
end

-- Low hedge clump like the ones on the start field.
function Props.hedge(parent: Instance, cf: CFrame, rng): Model
	local m = Util.model(parent, "Hedge")
	local col = rgb(86, 188, 58)
	Util.part(m, V(14, 3, 9), cf * CF(0, 1.5, 0) * CFrame.Angles(0, rng.range(-0.4, 0.4), 0), col, { name = "Leaves", studs = true })
	Util.part(m, V(10, 3.4, 8), cf * CF(4, 1.7, -3) * CFrame.Angles(0, rng.range(-0.5, 0.5), 0), col:Lerp(C.white, 0.06), {
		name = "Leaves",
		studs = true,
	})
	return m
end

function Props.bush(parent: Instance, cf: CFrame, rng, color: Color3?): Model
	local m = Util.model(parent, "Bush")
	local s = rng.range(3, 5)
	Util.part(m, V(s, s * 0.8, s), cf * CF(0, s * 0.4, 0), color or rgb(70, 170, 52), { name = "Leaves", studs = true })
	return m
end

function Props.flower(parent: Instance, cf: CFrame, rng): Model
	local m = Util.model(parent, "Flower")
	local petals = rng.pick({ rgb(255, 255, 255), rgb(255, 120, 200), rgb(255, 220, 60), rgb(120, 200, 255) })
	Util.part(m, V(0.3, 1.4, 0.3), cf * CF(0, 0.7, 0), rgb(60, 150, 50), { name = "Stem", collide = false })
	Util.part(m, V(1, 0.5, 1), cf * CF(0, 1.5, 0), petals, { name = "Petals", collide = false })
	return m
end

function Props.reeds(parent: Instance, cf: CFrame, rng): Model
	local m = Util.model(parent, "Reeds")
	for _ = 1, rng.int(3, 5) do
		local h = rng.range(6, 12)
		Util.part(m, V(0.5, h, 0.5), cf * CF(rng.range(-1.5, 1.5), h / 2, rng.range(-1.5, 1.5)) * CFrame.Angles(rng.range(-0.1, 0.1), 0, rng.range(-0.1, 0.1)), rgb(48, 160, 64), {
			name = "Reed",
			collide = false,
		})
	end
	return m
end

function Props.crystal(parent: Instance, cf: CFrame, rng, color: Color3): Model
	local m = Util.model(parent, "Crystal")
	for _ = 1, rng.int(2, 4) do
		local h = rng.range(5, 12)
		Util.part(m, V(1.8, h, 1.8), cf * CF(rng.range(-2, 2), h * 0.4, rng.range(-2, 2)) * CFrame.Angles(rng.range(-0.3, 0.3), rng.range(0, 3), rng.range(-0.3, 0.3)), color, {
			name = "Shard",
			material = Enum.Material.Glass,
			transparency = 0.15,
		})
	end
	local glow = Instance.new("PointLight")
	glow.Color = color
	glow.Range = 14
	glow.Brightness = 1.5
	glow.Parent = m:FindFirstChildWhichIsA("BasePart")
	return m
end

function Props.mushroom(parent: Instance, cf: CFrame, rng, capColor: Color3): Model
	local m = Util.model(parent, "Mushroom")
	local h = rng.range(4, 9)
	Util.part(m, V(1.6, h, 1.6), cf * CF(0, h / 2, 0), rgb(250, 240, 220), { name = "Stem" })
	local w = h * 0.9
	Util.part(m, V(w, 1.6, w), cf * CF(0, h + 0.5, 0), capColor, { name = "Cap", studs = true })
	Util.part(m, V(w * 0.6, 1.2, w * 0.6), cf * CF(0, h + 1.9, 0), capColor, { name = "Cap" })
	return m
end

-- Stepped sandstone pyramid.
function Props.pyramid(parent: Instance, cf: CFrame, base: number, tiers: number): Model
	local m = Util.model(parent, "Pyramid")
	local step = base / (tiers * 2)
	for i = 0, tiers - 1 do
		local w = base - i * step * 2
		Util.part(m, V(w, 3, w), cf * CF(0, 1.5 + i * 3, 0), if i % 2 == 0 then rgb(214, 170, 104) else rgb(200, 156, 92), {
			name = "Tier",
		})
	end
	return m
end

-- Stepped sandstone ledge leaning against a wall; `cf` faces away from the wall.
function Props.terrace(parent: Instance, cf: CFrame, rng, length: number): Model
	local m = Util.model(parent, "Terrace")
	local depth = rng.range(10, 16)
	local h = 0
	for i = 0, rng.int(2, 3) do
		local th = rng.range(4, 7)
		local d = depth * (1 - i * 0.28)
		local l = length * (1 - i * 0.18)
		Util.part(m, V(l, th, d), cf * CF(0, h + th / 2, d / 2), if i % 2 == 0 then rgb(222, 184, 116) else rgb(206, 166, 98), {
			name = "Step",
		})
		h += th
	end
	return m
end

-- Wooden rail fence between two ground points.
function Props.fence(parent: Instance, a: Vector3, b: Vector3, height: number?)
	local h = height or 4
	local delta = b - a
	local len = delta.Magnitude
	local dir = delta.Unit
	local base = CFrame.lookAt(a, b)
	local posts = math.max(1, math.floor(len / 6 + 0.5))
	for i = 0, posts do
		local p = a + dir * (len * i / posts)
		Util.part(parent, V(0.9, h + 0.6, 0.9), CF(p + V(0, (h + 0.6) / 2, 0)), C.woodDark, { name = "Post" })
	end
	for _, y in { h * 0.4, h * 0.9 } do
		Util.part(parent, V(0.4, 0.6, len), base * CF(0, y, -len / 2), C.wood, { name = "Rail" })
	end
	-- Cross braces like the reference pens.
	for i = 0, posts - 1 do
		local segLen = len / posts
		local mid = base * CF(0, h * 0.65, -(i + 0.5) * segLen)
		local diag = math.sqrt(segLen * segLen + (h * 0.5) ^ 2)
		local tilt = math.atan2(h * 0.5, segLen)
		Util.part(parent, V(0.3, 0.45, diag), mid * CFrame.Angles(tilt, 0, 0), C.wood, { name = "Brace" })
		Util.part(parent, V(0.3, 0.45, diag), mid * CFrame.Angles(-tilt, 0, 0), C.wood, { name = "Brace" })
	end
end

-- Small wooden upgrade sign; `cf` faces the reader (front = -Z).
function Props.upgradeSign(parent: Instance, cf: CFrame, fromLevel: number, price: number): Model
	local m = Util.model(parent, "UpgradeSign")
	Util.part(m, V(0.8, 3.5, 0.8), cf * CF(0, 1.75, 0.4), C.woodDark, { name = "Post" })
	local tilt = cf * CF(0, 4.6, 0) * CFrame.Angles(math.rad(-15), 0, 0)
	Util.part(m, V(7.4, 4.4, 0.4), tilt * CF(0, 0, 0.25), C.wood, { name = "Frame" })
	local board = Util.part(m, V(6.8, 3.8, 0.3), tilt, rgb(34, 46, 104), { name = "Board" })
	Util.surfaceText(board, Enum.NormalId.Front, {
		{ text = "Upgrade Pen", color = C.white, stroke = C.black, weight = 1 },
		{ text = `Level {fromLevel} &gt; Level {fromLevel + 1}`, color = rgb(210, 230, 255), stroke = C.black, weight = 0.9 },
		{ text = `${price}`, color = rgb(90, 255, 90), stroke = rgb(0, 60, 0), weight = 1.7 },
	})
	m:SetAttribute("UpgradePrice", price)
	return m
end

function Props.gift(parent: Instance, cf: CFrame): Model
	local m = Util.model(parent, "FreeGift")
	Util.part(m, V(4, 3.4, 4), cf * CF(0, 1.7, 0), rgb(235, 50, 60), { name = "Box" })
	Util.part(m, V(4.4, 1, 4.4), cf * CF(0, 3.6, 0), rgb(255, 70, 80), { name = "Lid" })
	Util.part(m, V(4.5, 4.2, 0.8), cf * CF(0, 2.1, 0), rgb(255, 214, 40), { name = "Ribbon" })
	Util.part(m, V(0.8, 4.2, 4.5), cf * CF(0, 2.1, 0), rgb(255, 214, 40), { name = "Ribbon" })
	Util.part(m, V(1.6, 1.2, 1.6), cf * CF(0, 4.6, 0) * CFrame.Angles(0, math.pi / 4, 0), rgb(255, 214, 40), { name = "Bow" })
	return m
end

return Props
