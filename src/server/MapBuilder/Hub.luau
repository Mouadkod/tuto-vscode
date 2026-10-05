--[[
	The hub behind the Safe Zone line: pens down both sides and across the
	back with a clear walkway through the middle, the Trails Shop on the left,
	the Sell stall, sell machine and Fuse Machine on the right, and the three
	leaderboards on the left wall end facing back into the hub.

	"Left" and "right" are as seen standing on the start field looking into
	the hub (facing -Z): left is -X, right is +X.
]]

local Config = require(script.Parent.Config)
local Util = require(script.Parent.Util)
local Props = require(script.Parent.Props)
local Machines = require(script.Parent.Machines)

local Hub = {}

local rgb = Config.rgb
local C = Config.COLORS
local V = Vector3.new
local CF = CFrame.new
local HUB = Config.HUB

local function facing(pos: Vector3, dir: Vector3): CFrame
	return CFrame.lookAt(pos, pos + dir)
end

-- Fenced pen; `cf` is the pen centre with -Z pointing out through the gate.
local function pen(parent: Instance, id: number, cf: CFrame, w: number, d: number)
	local m = Util.model(parent, "Pen" .. id)
	local fence = Util.folder(m, "Fence")
	local function pt(x: number, z: number)
		return (cf * CF(x, 0, z)).Position
	end
	local gate = 12
	Props.fence(fence, pt(-w / 2, -d / 2), pt(-gate / 2, -d / 2))
	Props.fence(fence, pt(gate / 2, -d / 2), pt(w / 2, -d / 2))
	Props.fence(fence, pt(w / 2, -d / 2), pt(w / 2, d / 2))
	Props.fence(fence, pt(w / 2, d / 2), pt(-w / 2, d / 2))
	Props.fence(fence, pt(-w / 2, d / 2), pt(-w / 2, -d / 2))
	-- Where pets stand; invisible, for gameplay code.
	local slot = Util.part(m, V(w - 4, 1, d - 4), cf * CF(0, 0.5, 0), C.white, {
		name = "PenArea",
		transparency = 1,
		collide = false,
		shadow = false,
	})
	slot:SetAttribute("PenId", id)
	slot:SetAttribute("Level", 1)
	Props.upgradeSign(m, cf * CF(w / 2 - 6, 0, -d / 2 - 3.5), 1, 50)
	return m
end

function Hub.build(map: Instance, rng)
	local hub = Util.folder(map, "Hub")

	-- Pens.
	local pens = Util.folder(hub, "Pens")
	local id = 0
	local sideX = HUB.halfWidth - 33 -- pen centre, 5 studs off the side wall
	for _, z in { -80, -125, -170, -215 } do
		id += 1
		pen(pens, id, facing(V(-sideX, 0, z), V(1, 0, 0)), 40, 56)
	end
	for _, z in { -95, -140, -185, -230 } do
		id += 1
		pen(pens, id, facing(V(sideX, 0, z), V(-1, 0, 0)), 40, 56)
	end
	for _, x in { -64, 0, 64 } do
		id += 1
		pen(pens, id, facing(V(x, 0, HUB.zBack + 28), V(0, 0, 1)), 56, 40)
	end

	-- Left side: Trails Shop, its NPC machine, a free gift.
	local shops = Util.folder(hub, "Shops")
	Machines.stall(shops, facing(V(-86, 0, -18), V(1, 0, 0.6).Unit), {
		name = "TrailsShop",
		title = "TRAILS SHOP",
		titleColor = rgb(255, 222, 40),
		stripes = { rgb(255, 255, 255), rgb(255, 226, 70) },
		circleColor = rgb(255, 236, 60),
		circleOffset = V(0, 0, -10),
	})
	Machines.trailsMachine(shops, facing(V(-58, 0, -14), V(0, 0, 1)))
	local giftSpot = V(-124, 0, -30)
	Props.gift(shops, facing(giftSpot, V(1, 0, 0)))
	local giftCircle = Util.glowCircle(shops, 5.5, giftSpot, rgb(80, 255, 90), "FreeGiftCircle")
	Util.billboard(giftCircle, { { text = "FREE!", color = rgb(90, 255, 90), stroke = rgb(0, 60, 0) } }, 8, 2.5, 8)

	-- Right side: Sell stall, sell machine, Fuse Machine.
	Machines.stall(shops, facing(V(84, 0, -24), V(-1, 0, 0.6).Unit), {
		name = "SellShop",
		title = "SELL",
		titleColor = rgb(255, 40, 40),
		stripes = { rgb(235, 30, 40), rgb(255, 255, 255) },
		circleColor = rgb(70, 255, 120),
		circleOffset = V(0, 0, -10),
	})
	Machines.sellMachine(shops, facing(V(HUB.halfWidth - 20, 0, -50), V(-1, 0, 0)))
	Machines.fuseMachine(shops, facing(V(128, 0, -17), V(0, 0, -1)))

	-- Leaderboards on the left wall end, facing back into the hub.
	local boards = Util.folder(hub, "Leaderboards")
	local boardY = 3 + 17
	Machines.leaderboard(boards, CF(-158, boardY, -1), "TOP CASH", rgb(60, 220, 70), "$")
	Machines.leaderboard(boards, CF(-135, boardY, -1), "TOP SPEED", rgb(40, 180, 255), "")
	Machines.leaderboard(boards, CF(-112, boardY, -1), "TOP BLAST", rgb(255, 210, 30), "")

	-- A few small bushes and flowers; the centre stays open.
	local deco = Util.folder(hub, "Decor")
	for _, p in { V(-160, 0, -40), V(160, 0, -255), V(-160, 0, -255), V(-100, 0, -290), V(100, 0, -290) } do
		Props.bush(deco, CF(p), rng)
	end
	for _ = 1, 10 do
		local side = if rng.next() < 0.5 then -1 else 1
		Props.flower(deco, CF(side * rng.range(95, 105), 0, rng.range(-240, -100)), rng)
	end
end

return Hub
