-- Requirements
--  GNU coreutils
--  GNU findutils
-- TODO: create a validator for these requirements.


local kConfigFileName = 'wsp.json'
local isp = vim.inspect

local function isp(x)
  print(vim.inspect(x))
end

local function remove_newlines(s)
  return string.gsub(s, '\n', '')
end

local function dirname(f)
  return remove_newlines(vim.fn.system('dirname ' .. f .. ' | xargs realpath'))
end

-- Converts a path that is relative to refdir to absolute path.
local function abspath(refdir, relpath)
  return remove_newlines(vim.fn.system(
           {'sh', '-c', 'cd ' .. refdir .. ' && realpath ' .. relpath }))
end

-- Converts an absolute or relative path to a relative path with reference to refdir.
local function relpath(refdir, path)
  return vim.fn.system({
    'realpath', '--relative-to=', refdir, path
  })
end

local function map(f, list)
  if (f == nil or list == nil) then
    return nil
  end
  local new_list = {}
  for i,v in ipairs(list) do
    new_list[i] = f(v)
  end
  return new_list
end

local function in_quotes(s)
  return '\'' .. s .. '\''
end


local ui = require('wsp_ui')

-- -------------------------------------------------------------------------- --

local wsp = {
  root_dir = nil,
  config = nil,
}

function wsp.is_active()
  return wsp_config == nil
end

function wsp.init()
  -- Find config file and root directory.
  paths = vim.fn.findfile(kConfigFileName, vim.fn.getcwd() .. ';', -1)
  if #paths == 0 then
    return
  end
  config_file = paths[1]
  wsp.root_dir = dirname(config_file)
  print('config_file = ' .. config_file)
  print('root_dir = ' .. wsp.root_dir)
  config_json = vim.fn.join(vim.fn.readfile(config_file), '\n')
  wsp.config = vim.fn.json_decode(config_json)

  wsp.config.dirs = map(
    function(d) return abspath(wsp.root_dir, d) end,
    wsp.config.dirs)

  wsp.config.dirs_exclude = map(
    function(d) return abspath(wsp.root_dir, d) end,
    wsp.config.dirs_exclude)

  isp(wsp.config)
end

-- Creates a new workspace in directory.
function wsp.new(dir)
  default_file = vim.g.wsp_plugin_dir .. '/resources' .. '/default_wsp.json'
  config = vim.fn.json_decode(vim.fn.join(vim.fn.readfile(default_file), '\n'))
  -- Modify config if needed.
  config_str = vim.fn.json_encode(config) .. '\n'
  vim.fn.writefile({config_str}, dir .. '/' .. kConfigFileName, 'b')
  print('workspace created at ' .. dir)
end


function wsp.all_files()
  cmd = table.concat({
    'find',
    table.concat(wsp.config.dirs, ' '),
    '-type f',
    '\\(',
    table.concat(map(function(s) return '-not -path '.. in_quotes(s) end,
                 wsp.config.paths_exclude), ' '),
    '\\)',
    '\\(',
    table.concat(map(function(s) return '-name '.. in_quotes(s) end,
                 wsp.config.files), ' -or '),
    '\\)',
  }, ' ')
  print('cmd = ', cmd)
  vim.fn['fzf#run']({
    source = cmd,
    window = {
      width = 0.8,
      height = 0.5,
    },
    sink = 'edit'
    -- sink = function(x)
    --   vim.fn.append(vim.fn.line('$'), 'hello ' ..  x)
    -- end
  })
end

function wsp.test()
  print('WSP_TEST\n')
  wsp.init()
  wsp.all_files()
end

return wsp

--[[

WORKFLOW

* Reload this module and run test() function.
:lua basics.reload'wsp'.test()


NOTES

* Create a new workspace in a directory
  - create new wsp.json file with default settings

* List workspace files
  - FZF listing of files in a floating window
  - Navigate and open a file

* Navigation within a file. See outline of code in fzf.

--]]

