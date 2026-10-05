--[[
	Hub set pieces: market stalls, the trails NPC machine, the industrial sell
	machine, the Fuse Machine and the leaderboard boards.
	Each builder takes a ground CFrame whose -Z (look direction) is the front.
]]

local Config = require(script.Parent.Config)
local Util = require(script.Parent.Util)

local Machines = {}

local rgb = Config.rgb
local C = Config.COLORS
local V = Vector3.new
local CF = CFrame.new
local NEON = Enum.Material.Neon
local METAL = Enum.Material.DiamondPlate

local function light(part: Instance, color: Color3, range: number, brightness: number?)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = range
	l.Brightness = brightness or 2
	l.Parent = part
end

-- Market stall with a striped canopy and a glowing interaction circle beside it.
function Machines.stall(parent: Instance, cf: CFrame, opts: {
	name: string,
	title: string,
	titleColor: Color3,
	stripes: { Color3 },
	circleColor: Color3,
	circleOffset: Vector3,
}): Model
	local m = Util.model(parent, opts.name)
	local wood = rgb(236, 226, 206)
	local top = Util.part(m, V(11, 0.8, 5.5), cf * CF(0, 3.6, 0), wood, { name = "Counter" })
	Util.part(m, V(10.4, 2.6, 0.5), cf * CF(0, 2, -2.4), rgb(214, 200, 176), { name = "CounterFront" })
	for _, x in { -5, 5 } do
		for _, z in { -2.4, 2.4 } do
			Util.part(m, V(0.6, 3.2, 0.6), cf * CF(x, 1.6, z), rgb(200, 186, 160), { name = "Leg" })
		end
		Util.part(m, V(0.5, 9.5, 0.5), cf * CF(x, 4.75, 2.6), rgb(200, 186, 160), { name = "Pole" })
		Util.part(m, V(0.5, 8, 0.5), cf * CF(x, 4, -3.2), rgb(200, 186, 160), { name = "Pole" })
	end
	-- Canopy: stripes run front to back, sloping down toward the customer.
	local canopy = cf * CF(0, 9.2, -0.3) * CFrame.Angles(math.rad(-12), 0, 0)
	local n = 7
	local w = 12.4 / n
	for i = 0, n - 1 do
		local col = opts.stripes[i % #opts.stripes + 1]
		Util.part(m, V(w, 0.4, 8), canopy * CF(-6.2 + w * (i + 0.5), 0, 0), col, { name = "Canopy" })
		Util.part(m, V(w, 1.3, 0.3), canopy * CF(-6.2 + w * (i + 0.5), -0.75, -4), col, { name = "Valance" })
	end
	Util.billboard(top, {
		{ text = opts.title, color = opts.titleColor, stroke = C.black },
	}, 14, 3, 9)
	local circle = Util.glowCircle(m, 7.5, (cf * CF(opts.circleOffset)).Position, opts.circleColor, "Interaction")
	circle:SetAttribute("Interaction", opts.name)
	return m
end

-- Chunky dark machine/NPC with toxic-green glowing parts, next to the Trails Shop.
function Machines.trailsMachine(parent: Instance, cf: CFrame): Model
	local m = Util.model(parent, "TrailsMachine")
	local dark, mid, green = C.machineDark, C.machineMid, C.toxic
	Util.part(m, V(9, 1.6, 9), cf * CF(0, 0.8, 0), mid, { name = "Base", material = METAL })
	local body = Util.cylinder(m, 3.4, 8, cf * CF(0, 5.6, 0), dark, { name = "Body" })
	Util.cylinder(m, 3.7, 0.8, cf * CF(0, 3.6, 0), green, { name = "Ring", material = NEON })
	Util.cylinder(m, 3.7, 0.8, cf * CF(0, 7.4, 0), green, { name = "Ring", material = NEON })
	Util.cylinder(m, 2.6, 1.4, cf * CF(0, 10.3, 0), mid, { name = "Neck" })
	Util.ball(m, 2.6, cf * CF(0, 11.6, 0), green, { name = "Dome", material = NEON, transparency = 0.1 })
	for side = -1, 1, 2 do
		Util.part(m, V(2.8, 5.5, 3.6), cf * CF(side * 4.6, 4.4, 0), dark, { name = "SidePod" })
		Util.part(m, V(2.9, 0.6, 2.4), cf * CF(side * 4.6, 5.8, -0.7), green, { name = "Vent", material = NEON })
		Util.part(m, V(2.9, 0.6, 2.4), cf * CF(side * 4.6, 4.2, -0.7), green, { name = "Vent", material = NEON })
		Util.cylinder(m, 1, 2.2, cf * CF(side * 4.6, 8.2, 0), mid, { name = "Exhaust" })
	end
	Util.part(m, V(3.2, 1.2, 0.4), cf * CF(0, 6.4, -3.4), green, { name = "Eyes", material = NEON })
	light(body, green, 18, 2.5)
	return m
end

-- Industrial selling machine: dark body, toxic-green tank, screen and a toothy glowing mouth.
function Machines.sellMachine(parent: Instance, cf: CFrame): Model
	local m = Util.model(parent, "SellMachine")
	local s = 1.5
	local function at(x: number, y: number, z: number)
		return cf * CF(x * s, y * s, z * s)
	end
	local function sz(x: number, y: number, z: number)
		return V(x * s, y * s, z * s)
	end
	local dark, lime, green = rgb(24, 24, 28), C.lime, C.toxic

	for _, x in { -5, 5 } do
		for _, z in { -3, 3 } do
			Util.part(m, sz(2, 1, 2), at(x, 0.5, z), dark, { name = "Foot" })
			Util.part(m, sz(1.4, 0.4, 0.2), at(x, 0.6, z - 1.05), green, { name = "FootLight", material = NEON })
		end
	end
	Util.part(m, sz(13, 11, 8), at(0, 6.5, 0), dark, { name = "Body" })
	Util.part(m, sz(14, 1, 9), at(0, 12.5, 0), rgb(40, 40, 46), { name = "Roof" })
	-- Screen with a lime frame.
	local screen = Util.part(m, sz(9.6, 3.6, 0.3), at(0, 9.6, -4.1), rgb(10, 40, 12), { name = "Screen" })
	Util.surfaceText(screen, Enum.NormalId.Front, {
		{ text = "S E L L", color = green, weight = 1.4 },
		{ text = "EGGS &amp; PETS", color = lime, weight = 1 },
	})
	Util.part(m, sz(10.6, 0.5, 0.4), at(0, 11.65, -4.15), lime, { name = "Frame", material = NEON })
	Util.part(m, sz(10.6, 0.5, 0.4), at(0, 7.55, -4.15), lime, { name = "Frame", material = NEON })
	Util.part(m, sz(0.5, 4.6, 0.4), at(-5.05, 9.6, -4.15), lime, { name = "Frame", material = NEON })
	Util.part(m, sz(0.5, 4.6, 0.4), at(5.05, 9.6, -4.15), lime, { name = "Frame", material = NEON })
	-- Mouth: black opening framed in lime, white teeth, glowing conveyor tongue.
	Util.part(m, sz(8, 5.6, 0.3), at(0, 4, -4.1), rgb(6, 6, 8), { name = "Mouth" })
	Util.part(m, sz(9, 0.5, 0.4), at(0, 7, -4.15), lime, { name = "MouthFrame", material = NEON })
	Util.part(m, sz(0.5, 6, 0.4), at(-4.25, 4, -4.15), lime, { name = "MouthFrame", material = NEON })
	Util.part(m, sz(0.5, 6, 0.4), at(4.25, 4, -4.15), lime, { name = "MouthFrame", material = NEON })
	for i = 0, 4 do
		-- Wedges flipped upside down so the points hang from the top of the mouth.
		Util.wedge(m, sz(0.4, 1.4, 1.5), at(-3.2 + i * 1.6, 6.05, -4.3) * CFrame.Angles(0, math.pi / 2, math.pi), C.white, {
			name = "Tooth",
		})
	end
	local inner = Util.part(m, sz(6.4, 4, 0.3), at(0, 3.4, -3.95), green, { name = "Glow", material = NEON })
	Util.wedge(m, sz(6.4, 1, 3.6), at(0, 0.5, -5.9) * CFrame.Angles(0, math.pi, 0), green, {
		name = "Conveyor",
		material = NEON,
	})
	light(inner, green, 24, 3)
	-- Tank and pipes on top.
	Util.cylinder(m, 3.4, 0.8, at(0, 13.4, 0), dark, { name = "TankBase" })
	Util.cylinder(m, 3, 5, at(0, 16.2, 0), green, { name = "Tank", material = NEON, transparency = 0.15 })
	Util.cylinder(m, 3.4, 0.8, at(0, 19, 0), dark, { name = "TankCap" })
	-- Pipe arcs out of the tank and drops down onto the roof (offsets in real studs).
	Util.arc(m, cf * CF(-6, 24.3, 0), 3.2, 1.3 * s, 1.3 * s, 0, math.pi, 8, rgb(48, 48, 54), { name = "Pipe" })
	Util.part(m, V(1.3 * s, 4.8, 1.3 * s), cf * CF(-9.2, 21.9, 0), rgb(48, 48, 54), { name = "Pipe" })
	for side = -1, 1, 2 do
		Util.cylinder(m, 0.9 * s, 11 * s, at(side * 7.2, 6.5, 2.5), rgb(52, 54, 60), { name = "SidePipe" })
		Util.cylinder(m, 1.1 * s, 0.5 * s, at(side * 7.2, 4, 2.5), green, { name = "PipeRing", material = NEON })
		Util.cylinder(m, 1.1 * s, 0.5 * s, at(side * 7.2, 9, 2.5), green, { name = "PipeRing", material = NEON })
		Util.part(m, sz(0.3, 6, 0.3), at(side * 6.7, 6, -4.2), green, { name = "Strip", material = NEON })
	end
	return m
end

-- Sci-fi Fuse Machine with a glowing question-mark chamber.
function Machines.fuseMachine(parent: Instance, cf: CFrame): Model
	local m = Util.model(parent, "FuseMachine")
	local s = 1.5
	local function at(x: number, y: number, z: number)
		return cf * CF(x * s, y * s, z * s)
	end
	local function sz(x: number, y: number, z: number)
		return V(x * s, y * s, z * s)
	end
	local blue, dark, metal, cyan = C.fuseBlue, rgb(40, 44, 60), rgb(70, 76, 96), C.cyan

	Util.part(m, sz(22, 1, 12), at(0, 0.5, 0), metal, { name = "Base", studs = true })
	-- Main chamber.
	Util.part(m, sz(11, 11, 9), at(4, 6.5, 0), blue, { name = "Chamber", studs = true })
	Util.part(m, sz(10, 10, 0.6), at(4, 6.5, -4.4), dark, { name = "ChamberFrame" })
	local glass = Util.part(m, sz(8.4, 8.4, 0.4), at(4, 6.5, -4.7), rgb(214, 236, 255), {
		name = "Display",
		material = NEON,
	})
	Util.surfaceText(glass, Enum.NormalId.Front, {
		{ text = "?", color = rgb(30, 90, 220), stroke = rgb(255, 255, 255) },
	})
	light(glass, rgb(170, 220, 255), 22, 3)
	Util.part(m, sz(0.8, 7, 0.5), at(9.7, 6.5, -4.4), cyan, { name = "SideLight", material = NEON })
	-- Top dome.
	Util.cylinder(m, 4.6 * s, 1.6 * s, at(4, 12.8, 0), dark, { name = "Dome" })
	Util.cylinder(m, 4.8 * s, 0.4 * s, at(4, 12.2, 0), cyan, { name = "DomeRing", material = NEON })
	Util.cylinder(m, 3.2 * s, 1.4 * s, at(4, 14.3, 0), dark, { name = "DomeTop", studs = true })
	Util.part(m, sz(2, 0.6, 0.4), at(4, 12.8, -3.5), cyan, { name = "DomeLight", material = NEON })
	-- Thick curved pipe from the dome over to the side module (offsets in real studs).
	Util.arc(m, cf * CF(-1.5, 15, 0), 7.5, 2.2 * s, 2.2 * s, 0, math.pi, 14, dark, { name = "Pipe" })
	Util.arc(m, cf * CF(-1.5, 15, 0), 7.5, 2.4 * s, 0.6 * s, math.pi * 0.4, math.pi * 0.6, 3, metal, { name = "PipeBand" })
	-- Side module with heart lights.
	Util.part(m, sz(6, 8, 7), at(-6, 5, 0), blue, { name = "Module", studs = true })
	Util.part(m, sz(2.2, 5.6, 0.4), at(-6, 5.4, -3.6), dark, { name = "HeartPanel" })
	for i = 0, 2 do
		Util.part(m, sz(1.2, 1.2, 0.3), at(-6, 3.6 + i * 1.8, -3.85), rgb(255, 60, 80), { name = "Heart", material = NEON })
	end
	Util.part(m, sz(5, 2, 4), at(-6, 1.9, -5), dark, { name = "Step" })
	Util.part(m, sz(2, 0.6, 0.3), at(-6, 2.2, -7.05), rgb(255, 60, 60), { name = "StepLight", material = NEON })
	-- Control console with a star screen and an antenna.
	Util.part(m, sz(4, 8.5, 5), at(-10.6, 5.25, -1), metal, { name = "Console" })
	local star = Util.part(m, sz(3.2, 4, 0.3), at(-10.6, 6, -3.6), rgb(40, 140, 255), { name = "StarScreen", material = NEON })
	Util.surfaceText(star, Enum.NormalId.Front, {
		{ text = "★", color = C.white },
		{ text = "★", color = rgb(255, 120, 200), weight = 0.6 },
	})
	Util.cylinder(m, 0.25 * s, 6 * s, at(-11.6, 12.5, -1), dark, { name = "Antenna" })
	Util.ball(m, 0.5 * s, at(-11.6, 15.6, -1), cyan, { name = "AntennaTip", material = NEON })

	local anchor = Util.part(m, V(1, 1, 1), at(4, 15.5, 0), C.white, {
		name = "LabelAnchor",
		transparency = 1,
		collide = false,
		shadow = false,
	})
	Util.billboard(anchor, {
		{ text = "Fuse Machine", color = rgb(60, 210, 255), stroke = rgb(10, 30, 80), weight = 1.3 },
		{ text = "0/3", color = C.white, stroke = C.black, weight = 1 },
	}, 18, 5, 4)
	m:SetAttribute("Interaction", "FuseMachine")
	return m
end

-- Leaderboard board. `cf` is the centre of the board face, front = -Z.
function Machines.leaderboard(parent: Instance, cf: CFrame, title: string, color: Color3, stat: string): Model
	local m = Util.model(parent, "Leaderboard_" .. title:gsub(" ", ""))
	local w, h = 21, 34
	Util.part(m, V(w, h, 1), cf * CF(0, 0, 0.5), color, { name = "Frame" })
	Util.part(m, V(w + 1.2, 1.2, 2), cf * CF(0, h / 2 + 0.6, 0), color:Lerp(C.black, 0.25), { name = "Cap" })
	local header = Util.part(m, V(w - 1.6, 5, 0.3), cf * CF(0, h / 2 - 3.6, -0.15), color:Lerp(C.white, 0.15), {
		name = "Header",
		material = NEON,
	})
	Util.surfaceText(header, Enum.NormalId.Front, {
		{ text = `🏆 {title} 🏆`, color = C.white, stroke = color:Lerp(C.black, 0.6) },
	})
	local body = Util.part(m, V(w - 1.6, h - 8.4, 0.3), cf * CF(0, -2.7, -0.15), rgb(26, 30, 52), { name = "Rows" })
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Rows"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 30
	gui.LightInfluence = 0
	gui.Parent = body
	local rows = 10
	for i = 1, rows do
		local row = Instance.new("Frame")
		row.Name = "Row" .. i
		row.BorderSizePixel = 0
		row.BackgroundColor3 = if i % 2 == 1 then rgb(255, 255, 255) else color:Lerp(C.white, 0.7)
		row.Size = UDim2.new(0.94, 0, 1 / rows, -6)
		row.Position = UDim2.new(0.03, 0, (i - 1) / rows, 3)
		row.Parent = gui
		local rankColor = if i == 1 then rgb(255, 196, 0) elseif i == 2 then rgb(170, 176, 190) elseif i == 3 then rgb(205, 127, 50) else rgb(60, 64, 90)
		Util.label(row, `#{i}`, rankColor, UDim2.fromScale(0.02, 0.1), UDim2.fromScale(0.16, 0.8))
		Util.label(row, "---", rgb(40, 44, 70), UDim2.fromScale(0.2, 0.1), UDim2.fromScale(0.48, 0.8)).Name = "PlayerName"
		Util.label(row, `0 {stat}`, rgb(40, 44, 70), UDim2.fromScale(0.68, 0.1), UDim2.fromScale(0.3, 0.8)).Name = "Value"
	end
	m:SetAttribute("Leaderboard", title)
	return m
end

return Machines
