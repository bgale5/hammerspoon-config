-- Auto reload config change
function reloadConfig()
  -- hs.notify.new({title="Hammerspoon", informativeText="Reloading Config"}):send()
  hs.reload()
end

configWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

superKey = {"cmd", "ctrl"}
superKey2 = {"cmd", "ctrl", "shift"}

-- Caffeine behaviour

-- systemIdle: screen idles, system doesn't sleep
-- displayIdle: screen doesn't idle
caffeineSleepLevel = "systemIdle"

caffeine = hs.menubar.new()
function setCaffieneDisplay(state)
  if state then
    caffeine:setIcon("menu-icons/Active@2x.png")
  else
    caffeine:setIcon("menu-icons/Inactive@2x.png")
  end
end

function caffeineClicked()
  local newState = not hs.caffeinate.get(caffeineSleepLevel)
  -- Use set instead of toggle so that we get access to acAndBattery flag
  hs.caffeinate.set(caffeineSleepLevel, newState, true)
  setCaffieneDisplay(newState)
end

if caffeine then
  caffeine:setClickCallback(caffeineClicked)
  setCaffieneDisplay(hs.caffeinate.get(caffeineSleepLevel))
end

function tell(applicationName, cmd)
  hs.applescript(string.format('tell Application "%s" to %s', applicationName, cmd))
end

-- Automate application launching
function newWindow(applicationName, f)
  local app = hs.application.get(applicationName)
  if app then
    app:activate()
    f(app)
  else
    hs.application.open(applicationName)
  end
end

function newTerminalWindow()
  newWindow("iTerm", function() 
    tell("iTerm", "create window with default profile")
  end)
end

function newBrowserWindow()
  newWindow("libreWolf", function(app)
    app:selectMenuItem({"File", "New Window"})
  end)
end

function newFinderWindow()
  -- Finder is always running, so we don't have to worry about launching it
  local app = hs.application.get("Finder")
  app:activate()
  tell("Finder", "make new Finder window")
end

-- Keybindinds
hs.hotkey.bind(superKey, "T", newTerminalWindow)
hs.hotkey.bind(superKey, "B", newBrowserWindow)
hs.hotkey.bind(superKey, "F", newFinderWindow)

hs.hotkey.bind(superKey2, "S", hs.caffeinate.systemSleep)

-- Spotify Controls 
hs.hotkey.bind(superKey, "]", hs.spotify.next)
hs.hotkey.bind(superKey, "[", hs.spotify.previous)
hs.hotkey.bind(superKey, "\\", hs.spotify.playpause)

hs.hotkey.bind(superKey2, "\\", function()
  hs.notify.new({
    title = hs.spotify.getCurrentArtist(), 
    informativeText = hs.spotify.getCurrentTrack(),
    -- withdrawAfter = 0
  }):send()
end)
