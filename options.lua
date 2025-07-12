--- Copyright (c) 2025 Konvt
--- This file is licensed under the Mozilla Public License 2.0.
--- See the LICENSE file in the project root for license terms.
local util = require( 'scripts.utils.util' )

function init()
  Options = {
    ['defaults'] = {
      ['enable_cd'] = true,
      ['change_type'] = 'q',
      ['change_ammo'] = 'r',
    },
    --- @type boolean
    ['expecting_input'] = false,
  }
  Options['current'] = {
    ['enable_cd'] = { ['val'] = Options.defaults.enable_cd },
    ['change_type'] = {
      --- @type boolean
      ['selected'] = false,
      ['val'] = Options.defaults.change_type,
    },
    ['change_ammo'] = {
      --- @type boolean
      ['selected'] = false,
      ['val'] = Options.defaults.change_ammo,
    },
    ['existed_chars'] = { Options.defaults.change_type, Options.defaults.change_ammo },
  }

  Options.current.enable_cd.val = Options.defaults.enable_cd
  Options.current.change_type.val = Options.defaults.change_type
  Options.current.change_ammo.val = Options.defaults.change_ammo
  SetBool( 'savegame.mod.controls.enable_cd', Options.defaults.enable_cd )
  SetString( 'savegame.mod.controls.change_type', Options.defaults.change_type )
  SetString( 'savegame.mod.controls.change_ammo', Options.defaults.change_ammo )
  Options.current.existed_chars = {
    Options.defaults.change_type,
    Options.defaults.change_ammo,
  }
end

function tick()
  if Options.expecting_input then
    for i = 97, 122 do -- from 'a' to 'z'
      local character = string.char( i )
      if InputPressed( character ) then
        if Options.current.change_type.selected then
          if not util.existed_in( character,
                                  Options.current.existed_chars,
                                  { Options.current.change_type.val } ) then
            SetString( 'savegame.mod.controls.change_type', character )
          end
          Options.current.change_type.selected = false
        elseif Options.current.change_ammo.selected then
          if not util.existed_in( character,
                                  Options.current.existed_chars,
                                  { Options.current.change_ammo.val } ) then
            SetString( 'savegame.mod.controls.change_ammo', character )
          end
          Options.current.change_ammo.selected = false
        end
        Options.expecting_input = false
        Options.current.existed_chars = {
          Options.current.change_type.val,
          Options.current.change_ammo.val,
        }
      end
    end
  end
end

function draw()
  UiPush()
  UiAlign( 'center middle' )

  UiTranslate( UiCenter(), UiMiddle() - UiMiddle() / 3 )
  UiFont( 'bold.ttf', math.min( math.max( 48 * UiHeight() / 1080, 24 ), 96 ) )
  UiText( 'AC130-J airstrike' )

  UiTranslate( 0, 110 )
  UiColor( 1, 1, 1 )
  UiButtonImageBox( 'ui/common/box-outline-6.png', 6, 6 )
  UiFont( 'regular.ttf', math.min( math.max( 26 * UiHeight() / 1080, 13 ), 52 ) )

  Options.current.enable_cd.val = GetBool( 'savegame.mod.controls.enable_cd',
                                           Options.current.enable_cd.val )
  if UiTextButton( util.align_lr_fill( 'Enable cooldown:',
                                       tostring( Options.current.enable_cd.val ):upper(),
                                       30 ),
                   350, 40 ) then
    Options.current.enable_cd.val = not Options.current.enable_cd.val
    SetBool( 'savegame.mod.controls.enable_cd', Options.current.enable_cd.val )
  end
  UiTranslate( 0, 50 )

  Options.current.change_type.val = GetString( 'savegame.mod.controls.change_type',
                                               Options.current.change_type.val )
  if Options.expecting_input and Options.current.change_type.selected then
    UiTextButton( util.align_lr_fill( 'Change type:', '_[a-z key]_', 30 ), 350, 40 )
  elseif UiTextButton( util.align_lr_fill( 'Change type:',
                                           Options.current.change_type.val:upper(),
                                           30 ),
                       350, 40 ) then
    Options.expecting_input = true
    Options.current.change_type.selected = true
  end
  UiTranslate( 0, 50 )

  Options.current.change_ammo.val = GetString( 'savegame.mod.controls.change_ammo',
                                               Options.current.change_ammo.val )
  if Options.expecting_input and Options.current.change_ammo.selected then
    UiTextButton( util.align_lr_fill( 'Change ammo:', '_[a-z key]_', 30 ), 350, 40 )
  elseif UiTextButton( util.align_lr_fill( 'Change ammo:',
                                           Options.current.change_ammo.val:upper(),
                                           30 ),
                       350, 40 ) then
    Options.expecting_input = true
    Options.current.change_ammo.selected = true
  end
  UiTranslate( 0, 50 )

  if UiTextButton( 'Reset to default', 250, 40 ) then
    Options.current.enable_cd.val = Options.defaults.enable_cd
    Options.current.change_type.val = Options.defaults.change_type
    Options.current.change_ammo.val = Options.defaults.change_ammo
    SetBool( 'savegame.mod.controls.enable_cd', Options.defaults.enable_cd )
    SetString( 'savegame.mod.controls.change_type', Options.defaults.change_type )
    SetString( 'savegame.mod.controls.change_ammo', Options.defaults.change_ammo )
    Options.current.existed_chars = {
      Options.defaults.change_type,
      Options.defaults.change_ammo,
    }
  end
  UiTranslate( 0, 50 )
  if UiTextButton( 'Close', 250, 40 ) then
    Menu()
  end
  UiPop()
end
