---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by glastis.
--- DateTime: 20-Nov-22 16:36
---

local fuel = {}

local fuel_list = {}
fuel_list[#fuel_list + 1] = "minecraft:coal"
fuel_list[#fuel_list + 1] = "minecraft:charcoal"
fuel_list[#fuel_list + 1] = "minecraft:lava_bucket"
fuel_list[#fuel_list + 1] = "minecraft:coal_block"

--[[
---- Get the amount of fuel stored in the turtle's "battery"
----
---- @return number
--]]
local function getFuelLevel()
    return turtle.getFuelLevel()
end
fuel.getFuelLevel = getFuelLevel


--[[
---- Get the maximum amount of fuel that can be stored in the turtle
----
---- @return number
--]]
local function getMaxFuelLevel()
    return turtle.getFuelLimit()
end
fuel.getMaxFuelLevel = getMaxFuelLevel

--[[
---- Return the fuel level in percent
----
---- @return number between 0 and 100
--]]
local function getFuelPercentage()
    return math.floor((getFuelLevel() / getMaxFuelLevel()) * 100)
end
fuel.getFuelPercentage = getFuelPercentage


--[[
---- Refuel the turtle using fuel from the inventory
----
---- @param amount  The amount of fuel to refuel, if nil, refuel until full 95%
---- @return bool   true if refuel reached the target_percentage, false otherwise.
--]]
local function refuel(target_percentage)
    local i
    local item_data
    local amount_used

    i = 1
    if not target_percentage then
        target_percentage = 95
    end
    while i <= 16 and getFuelPercentage() < target_percentage  do
        item_data = turtle.getItemDetail(i)
        if item_data and table.contains(fuel_list, item_data.name) then
            turtle.select(i)
            amount_used = 0
            while getFuelPercentage() < target_percentage and amount_used < item_data.count do
                turtle.refuel(1)
                amount_used = amount_used + 1
            end
        end
        i = i + 1
    end
    return getFuelPercentage() >= target_percentage
end
fuel.refuel = refuel

--[[
---- Check the fuel level and refuel if needed
----
---- @param minimum_percentage      Fuel percentage to reach before refueling. If nil, start refueling at 20%.
---- @param target_percentage       The target percentage of fuel to reach. If nil, refuel until 95% full.
---- @return bool                   true if refuel reached the target_percentage, false otherwise.
--]]
local function checkFuel(minimum_percentage, target_percentage)
    if not minimum_percentage then
        minimum_percentage = 20
    end
    if getFuelPercentage() < minimum_percentage then
        return refuel(target_percentage)
    end
    return true
end
fuel.checkFuel = checkFuel

return fuel