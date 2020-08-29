-- Requirements
--  GNU coreutils
--  GNU findutils
-- TODO: create a validator for these requirements.


local kConfigFileName = 'wsp.json'
local isp = vim.inspect

local function isp(x)
  print(vim.inspect(x))
end

local function dirname(f)
  return vim.fn.system('dirname ' .. f .. ' | xargs realpath')
end

local function abspath(path)
  return vim.fn.system('realpath ' .. path)
end


local function fzf_select_index(list)
  -- local t = {}
  -- for i, s in ipairs(list) do
  --   t[i] = string.format('%d %s', i-1, s)
  -- end
  -- local input = table.concat(t, '\n')

  vim.fn['fzf#run']({
    source = list,
    sink = 'echo'
  })
  -- vim.fn.termopen('fzf --witb-nth 2..', input)
  -- return vim.fn.system('fzf --witb-nth 2..', input)
end


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

local ui = require('wsp_ui')

function wsp.test()
  print('WSP_TEST\n')

  wsp.init()

  -- isp(wsp.config)
  -- for _, d in ipairs(wsp.config.dirs) do
  --   print(abspath(d))
  -- end

  -- isp(vim.api.nvim_get_keymap('t'))

  vim.fn['fzf#run']({
    source = 'ls',
    window = {
      width = 0.8,
      height = 0.5,
    },
    sink = function(x)
      vim.fn.append(vim.fn.line('$'), 'hello ' ..  x)
    end
  })

  -- ui.open_window()
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

--]]

