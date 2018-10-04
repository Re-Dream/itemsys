rd_items = {}
rd_items.Items = {}

--npc different genders
rd_items.GenderTable = {
	["models/alyx.mdl"           ] = "female";
	["models/barney.mdl"         ] = "male";
	["models/player/p2_chell.mdl"] = "female";
	["models/mossman.mdl"        ] = "female";
	["models/player/odessa.mdl"  ] = "male";
	["models/gman.mdl"           ] = "male";
	["models/barney.mdl"         ] = "male";
	["models/eli.mdl"            ] = "male";
	["models/monk.mdl"           ] = "male";
	["models/odessa.mdl"         ] = "male";
}

rd_items.Sounds = {
	["explode"] = {
		"ambient/explosions/explode_1.wav",
		"ambient/explosions/explode_2.wav",
		"ambient/explosions/explode_3.wav",
		"ambient/explosions/explode_4.wav",
		"ambient/explosions/explode_5.wav",
		"ambient/explosions/explode_6.wav",
		"ambient/explosions/explode_7.wav",
		"ambient/explosions/explode_8.wav",
		"ambient/explosions/explode_9.wav"
	}	
}

rd_items.VoiceLines = {
	["male"] = {
		["talk"] = {
			"vo/npc/male01/hi01.wav",
			"vo/npc/male01/hi02.wav"
		},
		["hurt"] = {
			"vo/trainyard/male01/cit_hit01.wav",
			"vo/trainyard/male01/cit_hit02.wav",
			"vo/trainyard/male01/cit_hit03.wav",
			"vo/trainyard/male01/cit_hit04.wav",
			"vo/trainyard/male01/cit_hit05.wav"
		}
	},
	["female"] = {
		["talk"] = {
			"vo/npc/female01/hi01.wav",
			"vo/npc/female01/hi02.wav"
		},
		["hurt"] = {
			"vo/trainyard/female01/cit_hit01.wav",
			"vo/trainyard/female01/cit_hit02.wav",
			"vo/trainyard/female01/cit_hit03.wav",
			"vo/trainyard/female01/cit_hit04.wav",
			"vo/trainyard/female01/cit_hit05.wav"
		}	
	}
}

rd_items.Msg = function(...)
	Msg("[Redream Items] ")
	print(...)
end

rd_items.GetItem = function(ItemClass)
    return rd_items.Items[ItemClass]
end

rd_items.NewItem = function(ItemClass, ItemName, ItemDescription, Model)
	local item = {}
	item["rd_class"] = ItemClass
	item["rd_name"] = ItemName
	item["rd_desc"] = ItemDescription or "No description specified."
	item["rd_model"] = Model or "models/error.mdl"
	rd_items.Items[ItemClass] = item; --If you want to override it you can.
	return item
end

local EMeta = FindMetaTable("Entity")
function EMeta:GetGender()
	local mdl = self:GetModel()
	if mdl:lower():find("female") then
		return "female"
	elseif mdl:lower():find("male") then
		return "male"
	end
	
	if rd_items.GenderTable[mdl] then
		return rd_items.GenderTable[mdl]
	end
	
	return "unknown"
end

if SERVER then
	rd_items.NPCSpawns = {}
	rd_items.NPCSpawns["redream_waterlands_3"] = {}

	util.AddNetworkString("rd_items:BuyItem")
	util.AddNetworkString("rd_items:RequestInventory")
	util.AddNetworkString("rd_items:GUI")

	hook.Add("PlayerInitialSpawn", "rd_items:PlayerInitialSpawn", function(ply)
		ply.Inventory = {}
	end)

	net.Receive("rd_items:BuyItem", function(Length, Entity)
		local item = net.ReadString()
		local keeper = net.ReadEntity()
		local amnt = math.abs(net.ReadInt(32) or 1)
		local ply = Entity
		
		local itemtable = rd_items.GetItem(item)-- or nil
		local shop = keeper.Shop.items
		local price = shop[item]
		if not itemtable or not shop then
			rd_items.Msg("prevented " .. ply:GetName() .. " from buying item (item doesnt exist or keeper doesnt sell item???)")
			return
		end
		
		if ply:GetCoins() >= price * amnt then
			rd_items.Msg("successful purchase " .. tostring(ply) .. " " .. tostring(amnt) .. "x " .. item)

			if not ply.Inventory then
				rd_items.Msg("wat??? no inventory for " .. tostring(ply))
				ply.Inventory = {}
			end

			if not ply.Inventory[item] then
				ply.Inventory[item] = amnt
			else
				ply.Inventory[item] = ply.Inventory[item] + amnt
			end

			ply:TakeCoins(price * amnt, "successful purchase")
		end
	end)
end
