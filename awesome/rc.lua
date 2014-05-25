-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

vicious = require("vicious")

-- Load Debian menu entries
require("debian.menu")

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, there were errors during startup!",
                         text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
        local in_error = false
        awesome.add_signal("debug::error", function (err)
                -- Make sure we don't go into an endless error loop
            if in_error then return end
            in_error = true

                    naughty.notify({ preset = naughty.config.presets.critical,
                                             title = "Oops, an error happened!",
                                             text = err })
            in_error = false
            end)
end

-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")

-- Function that spawns terminal for an application
-- I am using urxvt
function spawn_terminal(geometry)
        local term = "urxvt -geometry " .. geometry
        return term
end

-- Only executes a command
function exec(command)
        return terminal .. " -e " .. command
end

-- Only for window-spawning commands
function execw(prog, wsize)
        if wsize == nil then
                size = terminal_size
        else
                size = wsize
        end
        return spawn_terminal(size) .. " -e " .. prog        
end

terminal_size = "100x30"
terminal = spawn_terminal(terminal_size)

editor = os.getenv("EDITOR") or "gvim"
editor_size = "140x40"
editor_cmd = execw(editor, editor_size)

filemanager = "ranger"
filemanager_size = "140x50"
filemanager_cmd = execw(filemanager, filemanager_size)

torrent = "rtorrent"
torrent_size= "140x40"
torrent_cmd = execw(torrent, torrent_size)

browser = "/usr/bin/x-www-browser"

main_screen = mouse.screen

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
        awful.layout.suit.floating,
        awful.layout.suit.tile,
        awful.layout.suit.tile.left,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.tile.top,
        awful.layout.suit.fair,
        awful.layout.suit.fair.horizontal,
        awful.layout.suit.spiral,
        awful.layout.suit.spiral.dwindle,
        awful.layout.suit.max,
        awful.layout.suit.max.fullscreen,
        awful.layout.suit.magnifier
}

--[[tags = {
            names = {"main", "chrome", "skype", "media", "tmp"},
            layout = {layouts[1], layouts[1], layouts[1], layouts[8]}
}--]]

tags = {}
for s = 1, screen.count() do
        -- Each screen has its own tag table.
        --tags[s] = awful.tag(tags.names, s, tags.layout)
        tags[s] = awful.tag({1, 2, 3, 4, 5, 6, 7, 8, 9}, s)
end

mysettingsmenu = {
        { "alsamixer", execw("alsamixer")},
        { "awm manual", execw("man awesome")},
        { "edit awm config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
        { "restart awm", awesome.restart },
        { "quit awm", awesome.quit }
}

mynetworkmenu = {
        {"chromium", "chromium"},
        {"iceweasel", "iceweasel"},
        {"filezilla", "filezilla"},
        {"skype", "skype"},
        {"rtorrent", torrent_cmd}
}

mymediamenu = {
        {"steam", "steam"},
        {"vlc", "vlc"},
        {"cmus", execw("cmus")}
}

mydevmenu = {
        {"git", "git-cola"}
}

mycmusmenu = awful.menu({items = {
        {"play", exec("cmus-remote -p")},
        {"pause", exec("cmus-remote -u")},
        {"next", exec("cmus-remote -n")},
        {"prev", exec("cmus-remote -r")},
        {"repeat", exec("cmus-remote -R")},
        {"shuffle", exec("cmus-remote -S")}}
})

mymainmenu = awful.menu({ items = {
        -- { "awesome", myawesomemenu }, -- beautiful.awesome_icon },
        -- { "Debian", debian.menu.Debian_menu.Debian },
        -- { "open terminal", terminal }
        { "net", mynetworkmenu },
        { "media", mymediamenu },
        { "dev", mydevmenu},
        { "fm", filemanager_cmd },
        { "keepassx", "keepassx" },
        { "libreoffice", "libreoffice" },
        { "virtualbox", "virtualbox" },
        { "edit", editor_cmd },
        { "settings", mysettingsmenu }}
})

mylauncher = awful.widget.launcher({ 
        image = image(beautiful.awesome_icon),
        menu = mymainmenu
})

function col(color, text)
        return "<span color='" .. color .. "'>" .. text .. "</span>"
end

-- Network usage widget
netwidget = widget({ type = "textbox" })
vicious.register(netwidget, vicious.widgets.net, 'd <span color="#CC9393">${eth0 down_kb}</span> kB/s | u <span color="#7F9F7F">${eth0 up_kb}</span> kB/s ', 3)

-- Cpu widget
cpuwidget = widget({ type = "textbox" })
--cpuwidget:set_color('#AECF96')
vicious.register(cpuwidget, vicious.widgets.cpu, col("#AECF96", "cpu: $1%") .. " | ")

-- Mem widget
memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem, col("#AECF96", "mem: $1% ($2MB/$3MB)") .. " | ", 13)

-- FS widget
fswidget = widget({ type = "textbox" })
vicious.register(fswidget, vicious.widgets.fs, col("#AECF96", "/ ${/ used_gb}/${/ size_gb} GB") .. " | " .. col("#AECF96", "/home ${/home used_gb}/${/home size_gb} GB") .. " | ")

-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

-- Cmus widget
--musicicon = widget({ type = "imagebox" })
--musicicon.image = image(beautiful.widget.music)

cmus_widget = widget({ type = "textbox" })
vicious.register(cmus_widget, vicious.widgets.cmus,
        function (widget, args)
                if args["{status}"] == "Stopped" then
                        return " - "
                elseif args["{status}"] == "N/A" and args["{artist}"] and args["{title}"] then
                        return ""
                else
                        return col("#CC9393", args["{status}"]) ..': '.. args["{artist}"]..' - '.. args["{title}"] .. ' | '
                end
        end
)

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
        awful.button({ }, 1, awful.tag.viewonly),
        awful.button({ modkey }, 1, awful.client.movetotag),
        awful.button({ }, 3, awful.tag.viewtoggle),
        awful.button({ modkey }, 3, awful.client.toggletag),
        awful.button({ }, 4, awful.tag.viewnext),
        awful.button({ }, 5, awful.tag.viewprev)
)

mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                         awful.button({ }, 1, function (c)
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  client.focus = c
                                                  c:raise()
                                              end),
                         awful.button({ }, 3, function ()
                                                  if instance then
                                                      instance:hide()
                                                      instance = nil
                                                  else
                                                      instance = awful.menu.clients({ width=250 })
                                                  end
                                              end),
                         awful.button({ }, 4, function ()
                                                  awful.client.focus.byidx(1)
                                                  if client.focus then client.focus:raise() end
                                              end),
                         awful.button({ }, 5, function ()
                                                  awful.client.focus.byidx(-1)
                                                  if client.focus then client.focus:raise() end
                                              end))

-- I want to create only layouts for each screen, no widgets.
for s = 1, screen.count() do
        -- Create a promptbox for each screen
        mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
        -- Create an imagebox widget which will contains an icon indicating which layout we're using.
        -- We need one layoutbox per screen.
        mylayoutbox[s] = awful.widget.layoutbox(s)
        mylayoutbox[s]:buttons(awful.util.table.join(
                awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end))
        )
        -- Create a taglist widget
        mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

        -- Create a tasklist widget
        mytasklist[s] = awful.widget.tasklist(
                function(c)
                        return awful.widget.tasklist.label.currenttags(c, s)
                end, 
                mytasklist.buttons
        )

        -- Create the wibox
        mywibox[s] = awful.wibox({ position = "bottom", screen = s })
        -- Add widgets to the wibox - order matters
        -- Also, we are adding widgets only for the main screen.
        mywibox[s].widgets = {
                {
                        mytaglist[s],
                        layout = awful.widget.layout.horizontal.leftright
                },
                mylayoutbox[s],
                s == main_screen and mytextclock or nil,
                s == main_screen and mysystray or nil,
                mytasklist[s],
                layout = awful.widget.layout.horizontal.rightleft
        }
        
        if s == main_screen then
                mytempwibox = awful.wibox({ position = "top", screen = s })
                mytempwibox.widgets = {
                        {
                                mylauncher,
                                layout = awful.widget.layout.horizontal.leftright
                        },
                        netwidget,
                        memwidget,
                        cpuwidget,
                        fswidget,
                        cmus_widget,
                        layout = awful.widget.layout.horizontal.rightleft
                }
        end
end

root.buttons(awful.util.table.join(
        awful.button({ }, 3, function () mymainmenu:toggle() end)
        --awful.button({ }, 4, awful.tag.viewnext),
        --awful.button({ }, 5, awful.tag.viewprev)
))

globalkeys = awful.util.table.join(
        -- Switch between tags
        awful.key({ modkey          }, "Left",   awful.tag.viewprev       ),
        awful.key({ modkey          }, "Right",  awful.tag.viewnext       ),
        awful.key({ modkey          }, "Escape", awful.tag.history.restore),

        -- Switch screens
        awful.key({ modkey }, "Tab",
                function ()
                        awful.screen.focus_relative(1)
                end
        ),
        awful.key({ modkey, "Shift" }, "Tab",
                function ()
                        awful.screen.focus_relative(-1)
                end
        ),

        -- Switch windows
        awful.key({ "Mod1" }, "Tab",
                function ()
                        awful.client.focus.byidx(1)
                        if client.focus then client.focus:raise() end
                end
        ),
        awful.key({ "Mod1", "Shift" }, "Tab",
                function ()
                        awful.client.focus.byidx(-1)
                        if client.focus then client.focus:raise() end
                end
        ),

        -- Toggle the AwesomeWM menu
        awful.key({ modkey  }, "w", function () mymainmenu:toggle({keygrabber=true}) end),
        -- Toggle the CMUS player menu
        awful.key({ modkey }, "e", function () mycmusmenu:toggle({keygrabber=true}) end),


        --[[ Layout manipulation
        awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
        awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
        awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
        --]]    

        --[[    
        awful.key({ modkey           }, "Tab",
                function ()
                        awful.client.focus.history.previous()
                        if client.focus then
                                client.focus:raise()
                        end
                end
        ),--]]
                    
        -- Standard program
        -- Spawn the predefined terminal
        awful.key({ modkey }, "Return", function () awful.util.spawn(terminal) end),
        
        -- AwesomeWM restart
        awful.key({ modkey, "Control" }, "r", awesome.restart),
            
        -- AwesomeWM quit
        awful.key({ modkey, "Control"   }, "q", awesome.quit),

        -- Enlarge the actual window
        awful.key({ modkey }, "l",     function () awful.tag.incmwfact( 0.05)    end),

        -- Reduce the actual window
        awful.key({ modkey }, "h",     function () awful.tag.incmwfact(-0.05)    end),
       
        --[[
        awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
        awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
        awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
        awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
        --]]
            
        -- Layout switch
        awful.key({ modkey }, "space", function () awful.layout.inc(layouts, -1) end),
        --awful.key({ modkey, "Shift" }, "space", function ()  awful.layout.inc(layouts, 1) end)

        -- Screen switch
        -- Moves every window to the other screen, switches the main screen and restarts awesome
        --[[awful.key({ modkey }, "s",
                function ()
                        for c in awful.client.cycle(function (x) return true end) do
                                awful.client.movetoscreen(c)
                        end


                        if screen.count() > 1 then
                                awful.util.spawn_with_shell("xrandr --auto", mouse.screen)
                        elseif screen.count() == 1 then
                                awful.util.spawn_with_shell("xrandr --auto", mouse.screen)
                                awful.util.spawn_with_shell("xrandr --output HDMI-0 --primary && xrandr --output DVI-I-0 --right-of-HDMI-0", mouse.screen)
                        end
                        

                        --awesome.restart()
                end
        ),
        --]]
        awful.key({modkey}, "s",
                function ()
                        naughty.notify({
                                title = "Current screen",
                                text = tostring(mouse.screen),
                                timeout = 2,
                                screen = mouse.screen,
                                position = "bottom_right"
                        })
                end
        ),

        -- Prompt
        --awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end)

        --[[
        awful.key({ modkey }, "x",
                function ()
                      awful.prompt.run({ prompt = "Run Lua code: " },
                      mypromptbox[mouse.screen].widget,
                      awful.util.eval, nil,
                      awful.util.getdir("cache") .. "/history_eval")
                  end)
        --]]
        
        -- Spawn file manager
        awful.key({ modkey, "Shift" }, "f",
                function ()
                       awful.util.spawn_with_shell(filemanager_cmd, mouse.screen) 
                end
        ),

        -- Spawn editor
        awful.key({ modkey, "Shift" }, "e",
                function ()
                        awful.util.spawn_with_shell(editor_cmd, mouse.screen)
                end
        ),

        -- Spawn web browser
        awful.key({ modkey, "Shift" }, "w",
                function ()
                        awful.util.spawn_with_shell(browser, mouse.screen)
                end
        ),

        -- Edit AwesomeWM config
        awful.key({ modkey, "Control" }, "e",
                function ()
                        awful.util.spawn_with_shell(editor_cmd .. " " ..awful.util.getdir("config").."/rc.lua", mouse.screen)
                end
        ),

        -- Edit VIM (~/.vim/vimrc) config
        awful.key({ modkey, "Control" }, "v",
                function ()
                        awful.util.spawn_with_shell(editor_cmd .. " " .. "~/.vim/vimrc", mouse.screen)
                end
        )
)

clientkeys = awful.util.table.join(
        -- Make a window fullscreened and remove its titlebar
        awful.key({ modkey }, "f",
                function (c)
                        if c.titlebar and not c.fullscreen then
                                awful.titlebar.remove(c)
                        end

                        if c.fullscreen and not c.titlebar then
                                awful.titlebar.add(c, { modkey = modkey })
                        end

                        c.fullscreen = not c.fullscreen
                end),

        awful.key({ modkey }, "t",
                function (c)
                        if c.titlebar then awful.titlebar.remove(c)
                        else awful.titlebar.add(c, { modkey = modkey }) end
                end
        ),

        -- Kill the window process
        awful.key({ modkey, "Shift"   }, "q",      function (c) c:kill()                         end),
        
        -- ???
        awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
        awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
        
        -- Move to another screen
        awful.key({ modkey }, "o",
                function (c)
                        if c.maximized_horizontal then
                                c.maximized_horizontal = not c.maximized_horizontal
                        end

                        if c.maximized_vertical then
                                c.maximized_vertical = not c.maximized_vertical
                        end

                        awful.client.movetoscreen(c)
                        
                end
        ),
        --awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
        --awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),

        -- Minimize, maximize the actual window
        awful.key({ modkey      }, "n",      function (c) c.minimized = not c.minimized    end),    
        awful.key({ modkey      }, "m",
        function (c)
                c.maximized_horizontal = not c.maximized_horizontal
                c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
        keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
        globalkeys = awful.util.table.join(globalkeys,
            awful.key({ modkey }, "#" .. i + 9,
                      function ()
                            local screen = mouse.screen
                            if tags[screen][i] then
                                awful.tag.viewonly(tags[screen][i])
                            end
                      end),
            awful.key({ modkey, "Control" }, "#" .. i + 9,
                      function ()
                          local screen = mouse.screen
                          if tags[screen][i] then
                              awful.tag.viewtoggle(tags[screen][i])
                               end
                      end),
            awful.key({ modkey, "Shift" }, "#" .. i + 9,
                      function ()
                          if client.focus and tags[client.focus.screen][i] then
                              awful.client.movetotag(tags[client.focus.screen][i])
                          end
                      end),
            awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                      function ()
                          if client.focus and tags[client.focus.screen][i] then
                              awful.client.toggletag(tags[client.focus.screen][i])
                          end
                      end))
end

clientbuttons = awful.util.table.join(
        awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
        awful.button({ modkey }, 1, awful.mouse.client.move),
        awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)

-- Rules
awful.rules.rules = {
        -- All clients will match this rule.
        { 
                rule = { },
                properties = { 
                        border_width = beautiful.border_width,
                        border_color = beautiful.border_normal,
                        focus = true,
                        keys = clientkeys,
                        size_hints_honor = false,
                        buttons = clientbuttons
                }
        },
        {
                rule = {
                        class = "Chromium"
                },
                properties = {
                        floating = false
                }
        },
        { 
                rule_any = { 
                        class = { 
                                "URxvt", 
                                "Keepassx",
                                "Gvim",
                                "Skype"
                        }   
                },
                properties = {
                        floating = true
                },
                callback = function (c)
                        awful.placement.centered(c, nil)
                end
        },
        {
                rule = {
                        class = "pinentry"
                },
                properties = {
                        floating = true
                }
        },
        {
                rule = {
                        class = "gimp"
                },
                properties = {
                        floating = true
                }
        },
        -- Set Firefox to always map on tags number 2 of screen 1.
        -- { rule = { class = "Firefox" },
        --   properties = { tag = tags[1][2] } },
}

-- Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
        -- Add a titlebar
        awful.titlebar.add(c, { modkey = modkey })

        -- Enable sloppy focus
        c:add_signal("mouse::enter", function(c)
            if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                and awful.client.focus.filter(c) then
                client.focus = c
            end
        end)

        if not startup then
            -- Set the windows at the slave,
            -- i.e. put it at the end of others instead of setting it master.
            -- awful.client.setslave(c)

            -- Put windows in a smart way, only if they does not set an initial position.
            if not c.size_hints.user_position and not c.size_hints.program_position then
                awful.placement.no_overlap(c)
                awful.placement.no_offscreen(c)
            end
        end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
