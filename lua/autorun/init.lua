--use pdata instead of netdata if used on different than redream

local PLAYER = FindMetaTable("Player")
if not PLAYER.GetNetData then
	PLAYER.GetNetData = PLAYER.GetPData
end

if SERVER then
	if not PLAYER.SetNetData then
		PLAYER.SetNetData = PLAYER.SetPData
	end
	
	local function includeCSLuaFile(x)
		include(x)
		AddCSLuaFile(x)
	end
	
	includeCSLuaFile("itemsys/sh_itemsys.lua")
	AddCSLuaFile("itemsys/cl_itemsys.lua")
	includeCSLuaFile("itemsys/sh_coins.lua")
	AddCSLuaFile("itemsys/cl_coinhud.lua")
	include("itemsys/sv_npcspawner.lua")
	local npcs, _ = file.Find("autorun/itemsys/npcs/*", "LUA")
	local items, _ = file.Find("autorun/itemsys/items/*", "LUA")
	for i,v in pairs(npcs) do
		includeCSLuaFile("autorun/itemsys/npcs/" .. v)
	end
	for i,v in pairs(items) do
		includeCSLuaFile("autorun/itemsys/items/" .. v)
	end
	--todo: init all npcs
end

if CLIENT then
	include("itemsys/sh_coins.lua")
	include("itemsys/sh_itemsys.lua")
	include("itemsys/cl_coinhud.lua")
	include("itemsys/cl_itemsys.lua")
	local npcs, _ = file.Find("autorun/itemsys/npcs/*", "LUA")
	local items, _ = file.Find("autorun/itemsys/items/*", "LUA")
	for i,v in pairs(npcs) do
		include("autorun/itemsys/npcs/" .. v)
	end
	for i,v in pairs(items) do
		include("autorun/itemsys/items/" .. v)
	end
end
