---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by glastis.
--- DateTime: 26-Nov-22 20:09
---

local sides = require 'sides'
local move = require 'move'
local parsing = require 'parsing'

local storage = {}

-------------------------------------------------------------------[[
---------------------------------------------------------------------
----                    PRIVATE FUNCTIONS                        ----
---------------------------------------------------------------------
-------------------------------------------------------------------]]

local function _convert_side_to_suck_function(side)
    if side <= 3 then
        return turtle.suck
    elseif side == sides.up then
        return turtle.suckUp
    elseif side == sides.down then
        return turtle.suckDown
    else
        print("Error: _convert_side_to_suck_function: side '" .. side .. "' is invalid")
        return nil
    end
end

local function _parse_inventory(side, step, from_slot, to_slot, f_condition, callback, callback_args)
    local inventory
    local on_success
    local inventory_info

    inventory = peripheral.wrap(sides.labels[side])
    if inventory == nil then
        print("Error: _parse_inventory: side '" .. side .. "' is invalid")
        return
    end
    inventory_info = {}
    inventory_info.from_slot = from_slot
    inventory_info.to_slot = to_slot
    inventory_info.step = step
    inventory_info.inventory_size = inventory.size()
    if callback then
        if not callback_args then
            callback_args = {}
        end
        table.insert(callback_args, 1, callback)
    end
    on_success = function(slot, callback, ...)
        return true
    end
    if callback then
        return parsing.parse_inventory(f_condition, inventory.getItemDetail, inventory_info, false, on_success, callback_args)
    end
    return parsing.parse_inventory(f_condition, inventory.getItemDetail, inventory_info, true, on_success, callback_args)

end

-------------------------------------------------------------------[[
---------------------------------------------------------------------
----                    PUBLIC FUNCTIONS                         ----
---------------------------------------------------------------------
-------------------------------------------------------------------]]

--[[
---- Suck from the specified side. If no side is specified, suck from the front.
----
---- @param side   The side to suck from. If no side is specified, suck from the front.
---- @param amount The amount of items to suck. If no amount is specified, suck 1 item.
---- @return       The amount of items sucked.
--]]
local function suck(side, amount)
    local ret

    if not side then
        side = sides.front
    end
    move.rotate(side)
    ret = sides.suck[side](amount)
    return ret
end
storage.suck = suck

local function suck_item(item, amount, side)

end

local function is_storage_empty(side)
    return not _parse_inventory(side, 1, 1, 9, function(details)
        return details ~= nil
    end)
end
storage.is_storage_empty = is_storage_empty

return storage