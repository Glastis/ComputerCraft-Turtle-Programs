---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by glastis.
--- DateTime: 28-Nov-22 22:22
---

local args = {...}

local output_filename = 'trace.log'

local function remove_file(filename)
    fs.delete(filename)
end

local function overwrite_logs(message, filename)
    local file

    remove_file(filename)
    file = io.open(filename, 'w')
    file:write(message)
    file:close()
end

local function err_handle(err)
    print(err)
    overwrite_logs(err, output_filename)
end

local function is_file_exists(filename)
    local file

    file = io.open(filename, 'r')
    if file then
        file:close()
    end
    return file ~= nil
end

local function main(args_table)
    local success
    local error_message

    if #args_table == 0 then
        print('No arguments specified')
        return
    end
    if not is_file_exists(args_table[1]) then
        print('File ' .. args_table[1] .. ' does not exist.')
        return
    end
    print('Arguments: ', table.unpack(args_table))
    success, error_message = xpcall(shell.run, err_handle, table.unpack(args_table))
    print('Success: ' .. tostring(success))
    print('Error message: ' .. tostring(error_message))
end

main(args)