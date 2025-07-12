--- Copyright (c) 2025 Konvt
--- This file is licensed under the Mozilla Public License 2.0.
--- See the LICENSE file in the project root for license terms.
function init()
  RegisterTool( 'gunship', 'Gunship Airstrike', 'MOD/vox/airstrike.vox' )
  SetBool( 'game.tool.gunship.enabled', true )

  Modules = {
    ['camera'] = require( 'scripts.handlers.camera' ),
    ['fog'] = require( 'scripts.handlers.fog' ),
    ['plane'] = require( 'scripts.handlers.plane' ),
    ['model'] = require( 'scripts.handlers.model' ),

    ['loadout'] = require( 'scripts.types.loadout' ),
    ['projectile'] = require( 'scripts.types.projectile' ),
    ['sound'] = require( 'scripts.types.sound' ),
    ['timer'] = require( 'scripts.types.timer' ),
  }

  This = {
    ['view'] = Modules.camera.CameraHandler:new( 0.5, 12 ),
    ['mist'] = Modules.fog.FogHandler:new( Modules.fog.FogParams:new( 80, 300, 1, 5 ) ),
    ['aircraft'] = Modules.plane.PlaneHandler:new(
      Transform( Vec( 100, 100, 0 ), QuatRotateQuat( Quat(), QuatEuler( -90, -90, 0 ) ) ),
      Modules.sound.LoopSound:new( LoadLoop( 'MOD/sounds/planeloop.ogg' ) ),
      0.05 ),
    ['tool'] = Modules.model.ModelHandler:new(
      Modules.sound.Sound:new( LoadSound( 'MOD/sounds/radiobeep.ogg' ) ), 1 ),
    --- @type table<string, boolean>
    ['airraid'] = { ['activated'] = false },
    ['arsenal'] = Modules.loadout.Loadout:new(
      LoadSound( 'MOD/sounds/switch.ogg' ),
      {
        Modules.loadout.Slot:new( require( 'scripts.prefabs.25mm' ) ),
        Modules.loadout.Slot:new( require( 'scripts.prefabs.40mm' ) ),
        Modules.loadout.Slot:new( require( 'scripts.prefabs.105mm' ) ),
        Modules.loadout.Slot:new( require( 'scripts.prefabs.missile' ) ),
        Modules.loadout.Slot:new( require( 'scripts.prefabs.emitter' ) ),
      }
    ),
    ['prjctle_mgr'] = require( 'scripts.prefabs.projectile_mgr' ),
    ['option'] = {
      ['enable_cd'] = GetBool( 'savegame.mod.controls.enable_cd', true ),
      ['default_cd'] = 0.05,
      ['keys'] = {
        ['change_type'] = GetString( 'savegame.mod.controls.change_type', 'q' ),
        ['change_ammo'] = GetString( 'savegame.mod.controls.change_ammo', 'r' ),
      },
    },
  }

  SetBool( 'savegame.mod.controls.enable_cd', This.option.enable_cd )
  SetString( 'savegame.mod.controls.change_type', This.option.keys.change_type )
  SetString( 'savegame.mod.controls.change_ammo', This.option.keys.change_ammo )
end

--- @param dt DeltaTime
function tick( dt )
  This.prjctle_mgr:update( dt, { This.tool.body } )

  if GetString( 'game.player.tool' ) == 'gunship' and GetPlayerVehicle() == 0 then
    SetBool( 'game.input.locktool', This.view.is_airborne )
    This.airraid.activated = true

    if InputPressed( This.option.keys.change_type ) then
      PlaySound( This.arsenal.switch_sound, GetCameraTransform().pos, 0.4 )
      This.arsenal:next_equipment()
    end
    if InputPressed( This.option.keys.change_ammo ) then
      PlaySound( This.arsenal.switch_sound, GetCameraTransform().pos, 0.2 )
      This.arsenal:equipment():next_ammo()
    end
    if InputPressed( 'rmb' ) then
      This.view.is_airborne = not This.view.is_airborne
      This.mist.is_dirty = true
    end
    if InputPressed( 'esc' ) then This.view.is_airborne = false end
    if This.view.is_airborne then
      This.view:switch_to( This.aircraft )
    end

    This.view.aim_point = This.view.is_airborne
      and This.view.look_at( This.aircraft.barrel )
      or This.view.player_look_at()
    if not This.aircraft.firelight_timer:expired() then
      PointLight( This.aircraft.barrel.pos, 1, 1, 1 )
      This.aircraft.firelight_timer:update( dt )
    end

    if InputDown( 'usetool' ) then
      local current_wp = This.arsenal:equipment()
      --- @cast current_wp Slot
      if current_wp.cooldown:expired() or not current_wp.cooldown:active() then
        local barrel_end = TransformToParentPoint( This.aircraft.barrel, Vec( 0, -1, -2 ) )
        local dir = VecSub( This.view.aim_point, barrel_end )
        current_wp:ammo():fire( barrel_end, dir, current_wp.weapon.shot_snd )
        --- @type number
        local factor = 1
        if This.option.enable_cd then factor = current_wp.weapon.interval_factor end
        current_wp.cooldown = Modules.timer.CountdownTimer:new( factor * This.option.default_cd ):unwrap()
        This.aircraft.firelight_timer:reset()
      end
    end

    This.tool:render_radio( dt ):render_plane( This.aircraft.itself )
    This.aircraft:update()
  else
    This.airraid.activated = false
    This.view.is_airborne = false
    This.tool.activated = false
    This.tool.startup_timer:reset()
  end

  if This.mist.is_dirty then
    if This.view.is_airborne then
      This.mist.custom:apply()
    else
      This.mist.game:apply()
    end
    This.mist.is_dirty = false
  end
  for i = 1, #This.arsenal.slot do
    This.arsenal.slot[i].cooldown:update( dt )
  end
end

function draw()
  if This.view.is_airborne and GetPlayerVehicle() == 0 then
    local current_slot = This.arsenal:equipment()
    --- @cast current_slot Slot
    UiPush()
    UiTranslate( UiCenter(), UiMiddle() )
    UiColor( 1, 1, 1, 0.5 )
    UiAlign( 'center middle' )
    UiImage( current_slot.weapon.crosshair_path )
    UiPop()

    UiPush()
    UiTranslate( UiCenter(), UiMiddle() + UiMiddle() / 2 + 50 )
    UiColor( 1, 0, 0 )
    UiFont( 'bold.ttf', math.min( math.max( 26 * UiHeight() / 1080, 13 ), 52 ) )
    if current_slot.cooldown:active()
      and not current_slot.cooldown:expired()
      and current_slot.cooldown:period() >= 0.3 then
      UiColor( 0.66, 0.66, 0.66 )
      UiAlign( 'right' )
      UiTranslate( -5, 0 )
      UiText( 'CD' )
      UiColor( 0.66, 0.66, 0.66 )
      UiAlign( 'left' )
      UiTranslate( 10, 0 )
      UiText( tostring( math.ceil( current_slot.cooldown:present() ) ) .. ' s' )
    else
      UiColor( 1, 1, 1 )
      UiAlign( 'right' )
      UiTranslate( -5, 0 )
      UiText( current_slot.weapon.name )
      UiColor( 0.2, 0.8, 0.2 )
      UiAlign( 'left' )
      UiTranslate( 10, 0 )
      UiText( 'ARMED' )
    end
    UiPop()
  end
  if This.airraid.activated and GetPlayerVehicle() == 0 then
    UiPush()
    UiColor( 0.4, 0.4, 0.4 )
    UiAlign( 'left' )
    UiFont( 'bold.ttf', math.min( math.max( 26 * UiHeight() / 1080, 13 ), 52 ) )
    UiTextOutline( 0, 0, 0, 1, 0.1 )

    UiPush()
    UiTranslate( UiCenter() - UiCenter() * 0.9, UiHeight() - UiHeight() * 0.05 )
    UiColor( 1, 1, 1 )
    UiText( '[' .. This.option.keys.change_ammo:upper() .. '] CHANGE AMMO' )
    UiTranslate( 0, -30 )
    UiText( '[' .. This.option.keys.change_type:upper() .. '] CHANGE TYPE' )
    UiTranslate( 0, -30 )
    UiText( 'RIGHT-CLICK TO PLANE-VIEW' )
    UiPop()

    UiPush()
    UiTranslate( UiCenter() + UiCenter() * 0.7, UiHeight() - UiHeight() * 0.05 )
    for i = #This.arsenal.slot, 1, -1 do
      local slot = This.arsenal.slot[i]
      --- @cast slot Slot
      UiTranslate( 0, -30 )
      UiPush()

      local is_selected = slot == This.arsenal:equipment()
      if is_selected then UiColor( 1, 1, 1 ) end

      local text = slot.weapon.name
      if is_selected and #slot.weapon.magazine > 1 then
        text = ('%s [%s]'):format( text, slot:ammo().name )
      end

      UiText( text )
      UiPop()
    end
    UiPop()
  end
end
