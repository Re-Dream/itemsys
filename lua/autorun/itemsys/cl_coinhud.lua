local lerpCoins = 0
local lastCoins = 0

hook.Add("HUDPaint", "CoinsHud", function()
    lerpCoins = Lerp(0.05, lerpCoins, LocalPlayer():GetCoins())

    local hudColor
    if lastCoins < lerpCoins then
        hudColor = Color(255, 100, 100)
    else
        hudColor = Color(100, 255, 100)
    end

    draw.DrawText("¢" .. string.Comma(tostring(math.floor(lerpCoins))), "Trebuchet24", ScrW() - 50, ScrH() / 2 - 32, hudColor, 2)

    lastCoins = LocalPlayer():GetCoins()
end)