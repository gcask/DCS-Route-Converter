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

declare_plugin("Route Converter", {
	installed = true,
	dirName = current_mod_path,
	developerName = _("gcask"),
	developerLink = _("https://github.com/gcask/DCS-Route-Converter"),
	displayName = _("DCS Route Converter"),
	version = "1.0.0",
	state = "installed",
	info = _("Route tool/DTC conversion utility."),
	binaries = {},
    load_immediate = false,
	Options = {
		{ name = "Route Tool/DTC Converter", nameId = "RouteConverter", dir = "Options", allow_in_simulation = true },
	},
})

plugin_done()