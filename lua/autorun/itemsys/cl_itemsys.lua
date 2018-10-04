net.Receive("rd_items:GUI", function()
	local info = net.ReadTable()
	local ent = net.ReadEntity()
	--Create gui based on table
	--TODO: Separate this into its own file
	local shopframe = vgui.Create("DFrame")
	shopframe:SetSize(600, 300)
	shopframe:SetTitle("")
	shopframe:Center()
	shopframe:MakePopup()
	shopframe:SetAlpha(0)
	shopframe:AlphaTo(255, .25, 0)
	shopframe.Close = function(self)
		self:AlphaTo(0, .25, 0, function()
			gui.EnableScreenClicker(false)
			shopframe:Remove()
		end)
	end
	
	local namelabel = vgui.Create("DLabel", shopframe)
	namelabel:SetFont("Trebuchet24")
	namelabel:SetSize(600, 30)
	namelabel:SetPos(90, 35)
	namelabel:SetText(info.name)
	
	local personmdlpanel = vgui.Create("SpawnIcon", shopframe)
	personmdlpanel:SetPos(20, 40)
	personmdlpanel:SetSize(64, 64)
	personmdlpanel:SetModel(ent:GetModel())
	personmdlpanel:SetToolTip("")
	
	local desc = vgui.Create("DLabel", shopframe)
	desc:SetPos(20, 100)
	desc:SetSize(600, 30)
	desc:SetFont("Trebuchet24")
	desc:SetText(info.descriptions[math.random(1, #info.descriptions)])
	
	local scroll = vgui.Create("DScrollPanel", shopframe)
	scroll:SetPos(200, 150)
	scroll:SetSize(380, 130)
	
	local iconlayout = vgui.Create("DIconLayout", scroll)
	iconlayout:Dock(FILL)
	
	if info.items and next(info.items) ~= nil then
		for i,v in pairs(info.items) do
			local itemTable = rd_items.GetItem(i)
			if itemTable then
				local it = iconlayout:Add("DPanel")
				it:SetSize(380, 50)

				local ic = vgui.Create("SpawnIcon", it)
				ic:SetSize(46, 46)
				ic:SetPos(2, 2)
				ic:SetToolTip("Click to buy item!")
				ic:SetModel(itemTable.rd_model)

				local itemname = vgui.Create("DLabel", it)
				itemname:SetPos(50, 0)
									itemname:SetSize(200, 20)
				itemname:SetDark(1)
				itemname:SetFont("Trebuchet18")
				itemname:SetText(itemTable.rd_name .. " (¢" .. string.Comma(tostring(v)) .. ")")

				local itemdesc = vgui.Create("DLabel", it)
				itemdesc:SetPos(50, 10)
									itemdesc:SetSize(200, 20)
				itemdesc:SetDark(1)
				itemdesc:SetFont("Trebuchet18")
				itemdesc:SetText(itemTable.rd_desc)

				ic.DoClick = function(self)
					local m = DermaMenu()
					m:AddOption("Buy x1", function()
						net.Start("rd_items:BuyItem")
						net.WriteString(i)
						net.WriteEntity(ent)
						net.WriteInt(1, 32)
						net.SendToServer()
					end)
					m:AddOption("Buy Multiple", function()
						Derma_StringRequest(
							"Shopkeeper",
							"How many " .. itemTable.rd_name .. "s do you want to buy?",
							"",
							function(result)
								local n = tonumber(result) or 5
								Derma_Query(
									"Are you sure you want to buy " .. tostring(n) .. "x " .. itemTable.rd_name .. " for ¢" .. string.Comma(tostring(n * v)) .. "?",
									"Shopkeeper",
									"Yes",
									function()
										net.Start("rd_items:BuyItem")
										net.WriteString(i)
										net.WriteEntity(ent)
										net.WriteInt(n, 32)
										net.SendToServer()
									end,
									"No",
									function() end --Do nothing.
								)
							end,
							function()end
						)
					end)
					m:Open()
				end
			end
		end
	end
end)