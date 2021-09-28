--[[
--
-- Maintained by ElaraJade (keys)
-- Repostiory : https://www.github.com/shireishi/CustomHighlight.nvim/
-- Initial Creation Date : September 27th 2021.
--
]]--

local function getX (c)
    local command = io.popen('xrdb -query | grep ' .. c .. ' -m 1 | cut -f 2')
    local color = command:read("*l")
    return color
end

local xr = {
    fg = getX('foreground');
    bg = getX('background');
    black = getX('color0');
    red = getX('color1');
    green = getX('color2');
    yellow = getX('color3');
    blue = getX('color4');
    purple = getX('color5');
    cyan = getX('color6');
    white = getX('color7');
    light_black = getX('color8');
    light_red = getX('color9');
    light_green = getX('color10');
    light_yellow = getX('color11');
    light_blue = getX('color12');
    light_purple = getX('color13');
    light_cyan = getX('color14');
    light_white = getX('color15');
    none = 'NONE';
}

function xr.highlight(group, color)
    local style = color.style and 'gui=' .. color.style or 'gui=NONE'
    local fg = color.fg and 'guifg=' .. color.fg or 'guifg=NONE'
    local bg = color.bg and 'guibg=' .. color.bg or 'guibg=NONE'
    local sp = color.sp and 'guisp=' .. color.sp or ''
    vim.api.nvim_command('highlight ' .. group .. ' ' .. style .. ' ' .. fg .. ' ' .. bg .. ' '..sp)
end

function xr.groups(group, regex)
    vim.api.nvim_command('syn match ' .. group .. ' "' .. regex ..'"')
end

function xr.load_syntax()
    local syntax = {
        endOfFile = {fg = xr.red, style='bold'};
        url = {fg = xr.purple, style='italic,underline'};
        header = {fg = xr.red, style='bolditalic'};
        header2 = {fg = xr.green, style='italic'};
        TableStart = {fg = xr.yellow, style='bold'};
        TableEnd = {fg = xr.yellow, style='bold'};
        bold = {style='bold'};
        italic = {style='italic'};
        list = {fg = xr.red};
        altList = {fg = xr.blue, style='italic'};
        comment = {fg = xr.light_black, style='italic'};
        inlineExcl = {fg = xr.light_black, style='bold'};
        indication = {fg = xr.blue, style='italic'};
        indicationName = {fg = xr.blue, style='bold'};
    }
    return syntax
end

function xr.load_regex()
    local regex = {
        endOfFile = "EOF";
        url = "http.*";
        header2 = "##.*";
        header = "#.*";
        TableStart = "{";
        TableEnd = "}";
        bold = "\\*\\*.*\\*\\*";
        italic = "\\*.*\\*";
        list = "- .*";
        altList = "\\* .*";
        comment = "--.*";
        inlineExcl = "`.*`";
        indicationName = ".*: ";
        indication = ":.*";
    }
    return regex
end

local async_load_plugin

async_load_plugin = vim.loop.new_async(vim.schedule_wrap(function ()
    local syntax = xr.load_syntax()
    local regex = xr.load_regex()
        for group, reg in pairs(regex) do
        xr.groups(group, reg)
    end
    for group, color in pairs(syntax) do
        xr.highlight(group, color)
    end

    async_load_plugin:close()
end))

function xr.start()

    local filetype = vim.fn.expand('%:e')
    if filetype ~= 'crdnl' then
        return
    end

    local regex = xr.load_regex()
    local syntax = xr.load_syntax()
    for group, reg in pairs(regex) do
        xr.groups(group, reg)
    end

    for group, color in pairs(syntax) do
        xr.highlight(group, color)
    end
    async_load_plugin:send()
end

return xr
