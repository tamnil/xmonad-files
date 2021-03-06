import XMonad
import XMonad.Util.EZConfig
import XMonad.Util.EZConfig(additionalKeysP)
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.EwmhDesktops as E  -- Extended Window Manager Hints
import XMonad.Actions.CycleWS
import XMonad.Actions.WindowBringer
import XMonad.Actions.PhysicalScreens
import XMonad.Actions.GroupNavigation
import XMonad.Layout.Gaps
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Layout.MouseResizableTile
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Circle
import XMonad.Util.Run   -- for spawnPipe and hPutStrLn
import XMonad.Util.NamedWindows
import XMonad.Util.Run
import XMonad.Layout.MultiColumns
import XMonad.Hooks.EwmhDesktops as D
import XMonad.Wallpaper
import XMonad.Actions.SpawnOn
import XMonad.Hooks.SetWMName

import qualified Data.Map as M
import qualified XMonad.StackSet as W -- to shift and float windows
import XMonad.Config.Gnome



main = xmonad
    $ withUrgencyHook LibNotifyUrgencyHook
    -- $  ewmh def{ handleEventHook = handleEventHook def <+> D.fullscreenEventHook }
    $ gnomeConfig
      { modMask = mod4Mask -- use the Windows button as mod
      , manageHook = manageHook gnomeConfig <+> myManageHook <+> manageDocks
      , borderWidth = 5
      , focusedBorderColor = "#3299cd"
      , normalBorderColor = "#2b2b2b"
      -- , handleEventHook =  handleEventHook def <+> E.fullscreenEventHook 
     -- , handleEventHook    = fullscreenEventHook
     -- , workspaces = ["1:chrome","2:emacs","3:console","4:server","5:mail","6:other","7:","8:","9:","10:" ]
      , workspaces = myWorkspaces
      , terminal = "gnome-terminal"
      , layoutHook = myLayout
      , focusFollowsMouse = True
      , logHook = historyHook <+> myLogHook
      , XMonad.keys       = Main.keys
        }
        `additionalKeysP` 
              [
              ("M-<Left>",    prevWS )
             , ("M-<Right>",   nextWS )
             , ("M-S-<Left>",  shiftToPrev )
             , ("M-S-<Right>", shiftToNext )
                ] 

    -- myManageHook = composeAll . concat $
    --     [ [ className   =? c --> doFloat           | c <- myFloats]
    --     , [ title       =? t --> doFloat           | t <- myOtherFloats]
    --     , [ className   =? c --> doF (W.shift "2") | c <- webApps]
    --     , [ className   =? c --> doF (W.shift "3") | c <- ircApps]
    --     ]
    --   where myFloats      = ["MPlayer", "Gimp"]
    --         myOtherFloats = ["alsamixer"]
    --         webApps       = ["Firefox-bin", "Opera"] -- open on desktop 2
    --         ircApps       = ["Ksirc"]                -- open on desktop 3

myWorkspaces = ["1:term","2:web-1","3:web-2","4:code","5:xtra","6:media","7:virt","8:games","9:music","0:temp"]  -- ++ map show [9..14]



-- myStartupHook = setWMName "LG3D"
--                 -- >> spawnHere "gnome-settings-daemon"
--                 -- >> spawnHere "nm-applet"
--                 >> spawnHere "feh --bg-scale $HOME/.xmonad/background.png"
                -- >> spawnHere "xcompmgr"
                -- >> spawnHere "python $HOME/bin/dropbox.py start"
                -- >> spawnHere "$HOME/.xmonad/passbackups.sh"
                -- >> spawnHere "$HOME/.xmonad/keymappings.sh"
                -- >> spawnHere "sleep 15; $HOME/.xmonad/brightness.sh"
--                 >> spawnOn nine nvidiaMenu
--                 >> spawnOn four myMusic
-- --                >> spawnOn four myIm
--                 >> spawnOn three myTerminal
-- --                >> spawnOn two myEditorInit
--                 >> spawnOn one myInternet
--

myLogHook :: X ()
myLogHook = do ewmhDesktopsLogHook
               return ()

myLayout = avoidStruts (
   -- |||   
     multiCol [1 ,1  ] 2 0.01 0.5
    -- ||| multiCol [1] 2 0.01 0.5
    |||  tabbed shrinkText tabConfig   
    ||| mouseResizableTile
    ||| ThreeColMid 1 (3/100) (1/2) 
    ||| Full
    -- ||| Tall 1 (3/100) (1/2) 
    -- ||| Mirror (Tall 1 (3/100) (1/2)) 
    -- ||| ThreeCol 1 (3/100) (1/2)
    -- ||| spiral (6/7)
    
    ) 
    |||   noBorders (fullscreenFull Full)
    

-- Colors for text and backgrounds of each tab when in "Tabbed" layout.
tabConfig = defaultTheme {
    activeBorderColor = "#7C7C7C",
    activeTextColor = "#CEFFAC",
    activeColor = "#000000",
    inactiveBorderColor = "#7C7C7C",
    inactiveTextColor = "#EEEEEE",
    inactiveColor = "#000000"
}
myManageHook = composeAll
    [ 
    -- className =? "Chromium"       --> doShift "2:web"
    -- , className =? "Google-chrome"  --> doShift "2:web"
     resource  =? "desktop_window" --> doIgnore
    , className =? "Galculator"     --> doFloat
    , className =? "Steam"          --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "gpicview"       --> doFloat
    , className =? "MPlayer"        --> doFloat
    , className =? "Keepassx"        --> doFloat
    , className =? "VirtualBox"     --> doShift "7:virt"
    -- , className =? "Spotify"          --> doShift "9:music"
    , className =? "stalonetray"    --> doIgnore
    , isFullscreen --> (doF W.focusDown <+> doFullFloat)
    ]


-- keys --

keys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
keys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    -- launching and killing programs
    [ ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf) -- %! Launch terminal
    , ((modMask .|. shiftMask, xK_c     ), kill) -- %! Close the focused window

    , ((modMask,               xK_space ), sendMessage NextLayout) -- %! Rotate through the available layout algorithms
    , ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf) -- %!  Reset the layouts on the current workspace to default

    , ((modMask,               xK_n     ), refresh) -- %! Resize viewed windows to the correct size

    -- move focus up or down the window stack
    , ((modMask,               xK_Tab   ), windows W.focusDown) -- %! Move focus to the next window
    , ((modMask .|. shiftMask, xK_Tab   ), windows W.focusUp  ) -- %! Move focus to the previous window
    , ((modMask,               xK_j     ), windows W.focusDown) -- %! Move focus to the next window
    , ((modMask,               xK_k     ), windows W.focusUp  ) -- %! Move focus to the previous window
    , ((modMask,               xK_m     ), windows W.focusMaster  ) -- %! Move focus to the master window
    -- modifying the window order
    , ((modMask,               xK_Return), windows W.swapMaster) -- %! Swap the focused window and the master window
    , ((modMask .|. shiftMask, xK_j     ), windows W.swapDown  ) -- %! Swap the focused window with the next window
    , ((modMask .|. shiftMask, xK_k     ), windows W.swapUp    ) -- %! Swap the focused window with the previous window

    -- resizing the master/slave ratio
    , ((modMask,               xK_h     ), sendMessage Shrink) -- %! Shrink the master area
    , ((modMask,               xK_l     ), sendMessage Expand) -- %! Expand the master area

    -- floating layer support
    , ((modMask,               xK_t     ), withFocused $ windows . W.sink) -- %! Push window back into tiling

    -- increase or decrease number of windows in the master area
    , ((modMask              , xK_comma ), sendMessage (IncMasterN 1)) -- %! Increment the number of windows in the master area
    , ((modMask              , xK_period), sendMessage (IncMasterN (-1))) -- %! Deincrement the number of windows in the master area

    , ((modMask		     , xK_p), spawn myLauncher)
    , ((modMask .|. shiftMask, xK_g     ), gotoMenu)
    , ((modMask .|. shiftMask, xK_b     ), bringMenu)
    -- quit, or restart
    
        -- Restart xmonad.
    , ((modMask              , xK_q), restart "xmonad" True)

    , ((modMask              , xK_BackSpace), nextMatch History (return True))

    ]
    ++
    -- mod-[1..9] %! itch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [ xK_1, xK_2, xK_3, xK_4, xK_5, xK_6, xK_7, xK_8, xK_9, xK_0]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
    -- mod-{w,e,r} %! Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r} %! Move client to screen 1, 2, or 3
    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [1,2,0]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

myLauncher = "$(synapse)"

data LibNotifyUrgencyHook = LibNotifyUrgencyHook deriving (Read, Show)

instance UrgencyHook LibNotifyUrgencyHook where
    urgencyHook LibNotifyUrgencyHook w = do
        name     <- getName w
        Just idx <- fmap (W.findTag w) $ gets windowset

        safeSpawn "notify-send" [show name, "workspace " ++ idx]
