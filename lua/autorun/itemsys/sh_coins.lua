local PLAYER = FindMetaTable("Player")

function PLAYER:GetCoins()
	if not self:GetNetData("Coins") then
		return 0	
	end
	return self:GetNetData("Coins")	
end

local function cmsg(x)
	Msg("[COINS] ")
	local args = {x}
	table.insert(args, "\n")
	MsgC(Color(255,255,255),unpack(args))
end

if SERVER then
	function PLAYER:SetCoins(number)
		self:SetNetData("Coins", number)	
	end
	
	function PLAYER:TakeCoins(number, reason)
		local commaString = string.Comma(tostring(number))
		self:SetNetData("Coins", math.max(self:GetCoins() - number, 0))
		if reason then
			cmsg("Took " .. commaString .. " coins from " .. self:GetName() .. " (" .. reason .. ")")
		else
			cmsg("Took " .. commaString .. " coins from " .. self:GetName())
		end
	end
	
	function PLAYER:GiveCoins(number, reason)
		local commaString = string.Comma(tostring(number))
		self:SetNetData("Coins", math.max(self:GetCoins() + math.abs(number), 0))
		if reason then
			cmsg("Gave " .. commaString .. " coins to " .. self:GetName() .. " (" .. reason .. ")")
		else
			cmsg("Gave " .. commaString .. " coins to " .. self:GetName())
		end
	end
end