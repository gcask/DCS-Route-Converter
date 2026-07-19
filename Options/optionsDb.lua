-- SPDX-License-Identifier: MIT
--[[
MIT License

Copyright (c) 2026 gcask <53709079+gcask@users.noreply.github.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.]]

local io = require('io')
local lfs = require('lfs')
local net = require('net')
local Tools	= require('tools')

local function routeToHornetDTC(theatre, route)
    local navPts = {}
    for i,wpt in ipairs(route) do
        local navPoint = {
            wypt_num = #navPts+1,
            y = wpt.y,
            x = wpt.x,
            note = wpt.name,
            text_note = string.sub(wpt.name, 1, 6),
            alt = wpt.alt,
            altitudeType = wpt.alt_type == "BARO" and 1 or 2
        }

        navPts[#navPts+1] = navPoint
    end
    return {
        type = "FA-18C_hornet",
        data = {
            terrain = theatre,
            type = "FA-18C_hornet",
            WYPT = {
                mirror_NAV_PTS = true, -- Disable copy by default.
                NAV_PTS = navPts
            }
        }
    }, 'FA18C'
end

local function routeToViperDTC(theatre, route)
    local navPts = {}
    for i,wpt in ipairs(route) do
        local navPoint = {
            number = #navPts+1,
            y = wpt.y,
            x = wpt.x,
            note = wpt.name,
            alt = wpt.alt,
            altitudeType = wpt.alt_type == "BARO" and 1 or 2
        }

        navPts[#navPts+1] = navPoint
    end
    return {
        type = "F-16C_50",
        data = {
            terrain = theatre,
            type = "F-16C_50",
            MPD = {
                mirror_NAV_PTS = true, -- Disable copy by default.
                NAV_PTS = navPts
            }
        }
    }, 'F16C'
end

local converters = {
    Hornet = routeToHornetDTC,
    Viper = routeToViperDTC,
}

local function showDialog(dlg)
    local routeToolPresetsPath = lfs.writedir() .. [[Config/RouteToolPresets/]]
    
    local enableConvertButton = function()
        dlg.routeConverterConvertButton:setEnabled(true)
    end

    dlg.routeConverterRoutesComboList:addChangeCallback(enableConvertButton)

    local populatePresets = function(combo)
        local theatre = combo:getText()
        local presets = Tools.safeDoFile(routeToolPresetsPath..theatre..'.lua', false).presets or {}
        dlg.routeConverterRoutesComboList:clear()
        dlg.routeConverterConvertButton:setEnabled(false)
        for name,_ in pairs(presets) do
            local item = dlg.routeConverterRoutesComboList:newItem(name)
            if not dlg.routeConverterRoutesComboList:getSelectedItem() then
                dlg.routeConverterRoutesComboList:selectItem(item)
                enableConvertButton()
            end
        end
    end

    dlg.routeConverterTheatresComboList:addChangeCallback(populatePresets)

    for filename in lfs.dir(routeToolPresetsPath) do
        if lfs.attributes(routeToolPresetsPath .. filename, 'mode') == 'file' then
            local theatre = string.match(filename, '(.*)%.lua$')
            if theatre then
                local item = dlg.routeConverterTheatresComboList:newItem(theatre)
                if not dlg.routeConverterTheatresComboList:getSelectedItem() then
                    dlg.routeConverterTheatresComboList:selectItem(item)
                    populatePresets(dlg.routeConverterTheatresComboList)
                end
            end
        end
    end

    dlg.routeConverterConvertButton:addChangeCallback(function()
        local theatre = dlg.routeConverterTheatresComboList:getText()
        local preset = dlg.routeConverterRoutesComboList:getText()

        local presets = Tools.safeDoFile(routeToolPresetsPath..theatre..'.lua', false).presets or {}
        if presets[preset] then
            local converter = converters[dlg.routeConverterFormatsComboList:getText()]
            local converted, prefix = converter(theatre, presets[preset])
            local dtcPath = string.format("%sDTC/%s-%s-%s.dtc", lfs.writedir(), prefix, theatre, preset)
            local dtcFile = io.open(dtcPath, "w")

            if dtcFile then
                dtcFile:write(net.lua2json(converted))
                dtcFile:close()
                dlg.routeConverterConvertStatus:setText("Written to " .. dtcPath)
            end
        end
    end)

    local defaultFormat = dlg.routeConverterFormatsComboList:newItem("Hornet")
    dlg.routeConverterFormatsComboList:newItem("Viper")

    dlg.routeConverterFormatsComboList:selectItem(defaultFormat)
end

return {
	callbackOnShowDialog  = showDialog,

    -- Fake data to make it work.
    routeConverterTheatres = "",
    routeConverterRoutes = "",
    routeConverterFormats = "",
}