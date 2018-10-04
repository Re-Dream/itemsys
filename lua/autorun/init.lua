--use pdata instead of netdata if used on different than redream

local PLAYER = FindMetaTable("Player")
if not PLAYER.GetNetData or not PLAYER.SetNetData then
	PLAYER.GetNetData = PLAYER.GetPData
	PLAYER.SetNetData = PLAYER.SetPData
end
