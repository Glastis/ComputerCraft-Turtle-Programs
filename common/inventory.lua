---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by glastis.
--- DateTime: 21-Nov-22 22:24
---

local sides = require 'sides'
local move = require 'move'

local inventory = {}


local _max_inventory_size = turtle.getInventorySize()


-------------------------------------------------------------------[[
---------------------------------------------------------------------
----                    PRIVATE FUNCTIONS                        ----
---------------------------------------------------------------------
-------------------------------------------------------------------]]

--[[
---- Iterate over the inventory and run a given function on each slot. If the function returns true,
---- the iteration stops, or if a callback is given, the callback is
---- called with the slot number as argument. In both cases, the function select the slot.
----
---- @param f_condition  function to run on each slot
---- @param from_slot    number, the slot to start the iteration from
---- @param to_slot      number, the slot to end the iteration
---- @param step         number, the step to use for the iteration
---- @param callback     function, optional, called with the slot number as argument
---- @param callback_arg table, the arguments to pass to the callback
---- @return boolean     true if the condition is met, false otherwise
--]]
local function _parse_inventory_and_select_in_range(f_condition, from_slot, to_slot, step, callback, callback_args)
    local i
    local detail

    if step == 0 then
        print("Error: _parse_inventory_and_select_in_range: step cannot be 0")
        return false
    end
    while i <= _max_inventory_size and i > 0 and
            ((step > 0) and from_slot <= to_slot or (step < 0) and from_slot >= to_slot) do
        detail = turtle.getItemDetail(i)
        if f_condition(detail) then
            turtle.select(i)
            if not callback then
                return true
            end
            if callback_args then
                callback(i, callback_args)
            else
                callback(i)
            end
        end
        i = i + step
    end
    return false
end

local function _select_item_in_slot_range(item_name, from_slot, to_slot, step)
    return _parse_inventory_and_select_in_range(function(detail)
                                                    return detail and detail.name == item_name
                                                end, from_slot, to_slot, step)
end

local function _select_empty_in_slot_range(from_slot, to_slot, step)
    return _parse_inventory_and_select_in_range(function(detail)
                                                    return not detail
                                                end, from_slot, to_slot, step)
end

local function _convert_side_to_drop_function(side)
    if side < 3 then
        return turtle.drop
    elseif side == sides.up then
        return turtle.dropUp
    elseif side == sides.down then
        return turtle.dropDown
    else
        print("Error: _convert_side_to_drop_function: side '" .. side .. "' is invalid")
        return nil
    end
end

-------------------------------------------------------------------[[
---------------------------------------------------------------------
----                     PUBLIC FUNCTIONS                        ----
---------------------------------------------------------------------
-------------------------------------------------------------------]]

--[[
---- Select the first slot with the given item.
----
---- @param item_name   string, eg: "minecraft:stone"
---- @return            boolean, true if the item was found
--]]
local function select_item(item_name)
    return _select_item_in_slot_range(item_name, 1, _max_inventory_size, 1)
end
inventory.select_item = select_item

--[[
---- Select the first empty slot.
----
---- @return            boolean, true if an empty slot was found
--]]
local function select_first_empty_slot()
    return _select_empty_in_slot_range(1, _max_inventory_size, 1)
end

--[[
---- Select the first empty slot.
----
---- @return            boolean, true if an empty slot was found
--]]

local function select_last_empty_slot()
    return _select_empty_in_slot_range(_max_inventory_size, 1, -1)
end

--[[
---- Select the first slot with the first item found in the given list.
----
---- @param item_list   table, eg: {"minecraft:stone", "minecraft:dirt"}
---- @return            boolean, true if an item was found
--]]
local function select_first_item_in_list(item_list)
    local i
    local detail

    i = 1
    while i <= _max_inventory_size do
        detail = turtle.getItemDetail(i)
        if detail and table.contains(item_list, detail.name) then
            return true
        end
        i = i + 1
    end
    return false
end

--[[
---- Merge the same items in the inventory to save space.
--]]
local function defragment_inventory()
    local i
    local detail

    i = 1
    while i <= _max_inventory_size do
        detail = turtle.getItemDetail(i)
        if not detail then
            if not _parse_inventory_and_select_in_range(function(condition_detail)
                return item_detail ~= nil
            end, max_inventory_size, i + 1, -1) then
                return true
            end
            turtle.transferTo(i)
        end
        while turtle.getItemSpace(i) > 0 and _select_item_in_slot_range(detail.name, _max_inventory_size, i + 1, -1) do
            turtle.transferTo(i)
        end
        i = i + 1
    end
    return true
end
inventory.defragment_inventory = defragment_inventory

--[[
---- Drop the content of the given slot in the given direction.
----
---- @param slot        number, the slot to drop
---- @param side        number, the side to drop the items on
--]]
local function drop_slot_to_side(slot, side)
    turtle.select(slot)
    if turtle.getItemCount() == 0 then
        return true
    end
    move.rotate(side)
    return _convert_side_to_drop_function(side)()
end
inventory.drop_slot_to_side = drop_slot_to_side

--[[
---- Drop all items with given name from the inventory.
----
---- @param item_name   string, eg: "minecraft:stone"
---- @param side        number, eg: sides.front
---- @return            boolean, true if the item was found
--]]
local function drop_item(item_name, side)
    return _parse_inventory_and_select_in_range(function(detail)
        return detail and detail.name == item_name
    end, 1, _max_inventory_size, 1, drop_slot_to_side, {side})
end

--[[
---- Drop all items in list from the inventory.
----
---- @param item_list   table, eg: {"minecraft:stone", "minecraft:dirt"}
---- @param side        number, eg: sides.front
---- @return            boolean, true if all items were dropped
--]]
local function drop_item_list(item_list, side)
    return _parse_inventory_and_select_in_range(function(detail)
        return detail and table.contains(item_list, detail.name)
    end, 1, _max_inventory_size, 1, drop_slot_to_side, {side})
end
inventory.drop_item_list = drop_item_list

return inventory