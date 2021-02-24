#===============================================================================
# SpeedCalcAbility handlers
#===============================================================================
BattleHandlers::SpeedCalcAbility.add(:CHLOROPHYLL,
  proc { |ability,battler,mult|
    w = battler.battle.pbWeather
    next mult*2 if w==PBWeather::Sun || w==PBWeather::HarshSun
  }
)

BattleHandlers::SpeedCalcAbility.add(:QUICKFEET,
  proc { |ability,battler,mult|
    next (mult*1.5).round if battler.pbHasAnyStatus?
  }
)

BattleHandlers::SpeedCalcAbility.add(:SANDRUSH,
  proc { |ability,battler,mult|
    w = battler.battle.pbWeather
    next mult*2 if w==PBWeather::Sandstorm
  }
)

BattleHandlers::SpeedCalcAbility.add(:SLOWSTART,
  proc { |ability,battler,mult|
    next mult/2 if battler.turnCount<=5
  }
)

BattleHandlers::SpeedCalcAbility.add(:SLUSHRUSH,
  proc { |ability,battler,mult|
    w = battler.battle.pbWeather
    next mult*2 if w==PBWeather::Hail
  }
)

BattleHandlers::SpeedCalcAbility.add(:STARSPRINT,
  proc { |ability,battler,mult|
    w = battler.battle.pbWeather
    next mult*2 if w==PBWeather::Starstorm
  }
)

BattleHandlers::SpeedCalcAbility.add(:SURGESURFER,
  proc { |ability,battler,mult|
    next mult*2 if battler.battle.field.terrain==PBBattleTerrains::Electric
    next mult*2 if w==PBWeather::Storm
  }
)

BattleHandlers::SpeedCalcAbility.add(:SWIFTSWIM,
  proc { |ability,battler,mult|
    w = battler.battle.pbWeather
    next mult*2 if w==PBWeather::Rain || w==PBWeather::HeavyRain
  }
)

BattleHandlers::SpeedCalcAbility.add(:UNBURDEN,
  proc { |ability,battler,mult|
    next mult*2 if battler.effects[PBEffects::Unburden] && battler.item==0
  }
)

#===============================================================================
# WeightCalcAbility handlers
#===============================================================================

BattleHandlers::WeightCalcAbility.add(:HEAVYMETAL,
  proc { |ability,battler,w|
    next w*2
  }
)

BattleHandlers::WeightCalcAbility.add(:LIGHTMETAL,
  proc { |ability,battler,w|
    next [w/2,1].max
  }
)

#===============================================================================
# AbilityOnHPDroppedBelowHalf handlers
#===============================================================================

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:EMERGENCYEXIT,
  proc { |ability,battler,battle|
    next false if battler.effects[PBEffects::SkyDrop]>=0 || battler.inTwoTurnAttack?("0CE")   # Sky Drop
    # In wild battles
    if battle.wildBattle?
      next false if battler.opposes? && battle.pbSideBattlerCount(battler.index)>1
      next false if !battle.pbCanRun?(battler.index)
      battle.pbShowAbilitySplash(battler,true)
      battle.pbHideAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} fled from battle!",battler.pbThis)) { pbSEPlay("Battle flee") }
      battle.decision = 3   # Escaped
      next true
    end
    # In trainer battles
    next false if battle.pbAllFainted?(battler.idxOpposingSide)
    next false if !battle.pbCanSwitch?(battler.index)   # Battler can't switch out
    next false if !battle.pbCanChooseNonActive?(battler.index)   # No Pokémon can switch in
    battle.pbShowAbilitySplash(battler,true)
    battle.pbHideAbilitySplash(battler)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s {2} activated!",battler.pbThis,battler.abilityName))
    end
    battle.pbDisplay(_INTL("{1} went back to {2}!",
       battler.pbThis,battle.pbGetOwnerName(battler.index)))
    if battle.endOfRound   # Just switch out
      battle.scene.pbRecall(battler.index) if !battler.fainted?
      battler.pbAbilitiesOnSwitchOut   # Inc. primordial weather check
      next true
    end
    newPkmn = battle.pbGetReplacementPokemonIndex(battler.index)   # Owner chooses
    next false if newPkmn<0   # Shouldn't ever do this
    battle.pbRecallAndReplace(battler.index,newPkmn)
    battle.pbClearChoice(battler.index)   # Replacement Pokémon does nothing this round
    next true
  }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.copy(:EMERGENCYEXIT,:WIMPOUT)

#===============================================================================
# StatusCheckAbilityNonIgnorable handlers
#===============================================================================

BattleHandlers::StatusCheckAbilityNonIgnorable.add(:COMATOSE,
  proc { |ability,battler,status|
    next false if !isConst?(battler.species,PBSpecies,:KOMALA)
    next true if status.nil? || status==PBStatuses::SLEEP
  }
)

#===============================================================================
# StatusImmunityAbility handlers
#===============================================================================

BattleHandlers::StatusImmunityAbility.add(:FLOWERVEIL,
  proc { |ability,battler,status|
    next true if battler.pbHasType?(:GRASS)
  }
)

BattleHandlers::StatusImmunityAbility.add(:IMMUNITY,
  proc { |ability,battler,status|
    next true if status==PBStatuses::POISON
  }
)

BattleHandlers::StatusImmunityAbility.add(:INSOMNIA,
  proc { |ability,battler,status|
    next true if status==PBStatuses::SLEEP
  }
)

BattleHandlers::StatusImmunityAbility.copy(:INSOMNIA,:SWEETVEIL,:VITALSPIRIT)

BattleHandlers::StatusImmunityAbility.add(:LEAFGUARD,
  proc { |ability,battler,status|
    w = battler.battle.pbWeather
    next true if w==PBWeather::Sun || w==PBWeather::HarshSun
  }
)

BattleHandlers::StatusImmunityAbility.add(:LIMBER,
  proc { |ability,battler,status|
    next true if status==PBStatuses::PARALYSIS
  }
)

BattleHandlers::StatusImmunityAbility.add(:MAGMAARMOR,
  proc { |ability,battler,status|
    next true if status==PBStatuses::FROZEN
  }
)

BattleHandlers::StatusImmunityAbility.add(:WATERVEIL,
  proc { |ability,battler,status|
    next true if status==PBStatuses::BURN
  }
)

BattleHandlers::StatusImmunityAbility.copy(:WATERVEIL,:WATERBUBBLE)

#===============================================================================
# StatusImmunityAbilityNonIgnorable handlers
#===============================================================================

BattleHandlers::StatusImmunityAbilityNonIgnorable.add(:COMATOSE,
  proc { |ability,battler,status|
    next true if isConst?(battler.species,PBSpecies,:KOMALA)
  }
)

BattleHandlers::StatusImmunityAbilityNonIgnorable.add(:SHIELDSDOWN,
  proc { |ability,battler,status|
    next true if isConst?(battler.species,PBSpecies,:MINIOR) && battler.form<7
  }
)

#===============================================================================
# StatusImmunityAllyAbility handlers
#===============================================================================

BattleHandlers::StatusImmunityAllyAbility.add(:FLOWERVEIL,
  proc { |ability,battler,status|
    next true if battler.pbHasType?(:GRASS)
  }
)

BattleHandlers::StatusImmunityAbility.add(:SWEETVEIL,
  proc { |ability,battler,status|
    next true if status==PBStatuses::SLEEP
  }
)

#===============================================================================
# AbilityOnStatusInflicted handlers
#===============================================================================

BattleHandlers::AbilityOnStatusInflicted.add(:SYNCHRONIZE,
  proc { |ability,battler,user,status|
    next if !user || user.index==battler.index
    case status
    when PBStatuses::POISON
      if user.pbCanPoisonSynchronize?(battler)
        battler.battle.pbShowAbilitySplash(battler)
        msg = nil
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s {2} poisoned {3}!",battler.pbThis,battler.abilityName,user.pbThis(true))
        end
        user.pbPoison(nil,msg,(battler.statusCount>0))
        battler.battle.pbHideAbilitySplash(battler)
      end
    when PBStatuses::BURN
      if user.pbCanBurnSynchronize?(battler)
        battler.battle.pbShowAbilitySplash(battler)
        msg = nil
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s {2} burned {3}!",battler.pbThis,battler.abilityName,user.pbThis(true))
        end
        user.pbBurn(nil,msg)
        battler.battle.pbHideAbilitySplash(battler)
      end
    when PBStatuses::PARALYSIS
      if user.pbCanParalyzeSynchronize?(battler)
        battler.battle.pbShowAbilitySplash(battler)
        msg = nil
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
             battler.pbThis,battler.abilityName,user.pbThis(true))
        end
        user.pbParalyze(nil,msg)
        battler.battle.pbHideAbilitySplash(battler)
      end
    end
  }
)

#===============================================================================
# StatusCureAbility handlers
#===============================================================================

BattleHandlers::StatusCureAbility.add(:IMMUNITY,
  proc { |ability,battler|
    next if battler.status!=PBStatuses::POISON
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:INSOMNIA,
  proc { |ability,battler|
    next if battler.status!=PBStatuses::SLEEP
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} woke it up!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.copy(:INSOMNIA,:VITALSPIRIT)

BattleHandlers::StatusCureAbility.add(:LIMBER,
  proc { |ability,battler|
    next if battler.status!=PBStatuses::PARALYSIS
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:MAGMAARMOR,
  proc { |ability,battler|
    next if battler.status!=PBStatuses::FROZEN
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:OBLIVIOUS,
  proc { |ability,battler|
    next if battler.effects[PBEffects::Attract]<0 &&
            (battler.effects[PBEffects::Taunt]==0 || !NEWEST_BATTLE_MECHANICS)
    battler.battle.pbShowAbilitySplash(battler)
    if battler.effects[PBEffects::Attract]>=0
      battler.pbCureAttract
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battler.battle.pbDisplay(_INTL("{1} got over its infatuation.",battler.pbThis))
      else
        battler.battle.pbDisplay(_INTL("{1}'s {2} cured its infatuation status!",
           battler.pbThis,battler.abilityName))
      end
    end
    if battler.effects[PBEffects::Taunt]>0 && NEWEST_BATTLE_MECHANICS
      battler.effects[PBEffects::Taunt] = 0
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battler.battle.pbDisplay(_INTL("{1}'s Taunt wore off!",battler.pbThis))
      else
        battler.battle.pbDisplay(_INTL("{1}'s {2} made its taunt wear off!",
           battler.pbThis,battler.abilityName))
      end
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:OWNTEMPO,
  proc { |ability,battler|
    next if battler.effects[PBEffects::Confusion]==0
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureConfusion
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1} snapped out of its confusion.",battler.pbThis))
    else
      battler.battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",
         battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:WATERVEIL,
  proc { |ability,battler|
    next if battler.status!=PBStatuses::BURN
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.copy(:WATERVEIL,:WATERBUBBLE)

#===============================================================================
# StatLossImmunityAbility handlers
#===============================================================================

BattleHandlers::StatLossImmunityAbility.add(:BIGPECKS,
  proc { |ability,battler,stat,battle,showMessages|
    next false if stat!=PBStats::DEFENSE
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",battler.pbThis,PBStats.getName(stat)))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",battler.pbThis,
           battler.abilityName,PBStats.getName(stat)))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:CLEARBODY,
  proc { |ability,battler,stat,battle,showMessages|
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.copy(:CLEARBODY,:WHITESMOKE)

BattleHandlers::StatLossImmunityAbility.add(:FLOWERVEIL,
  proc { |ability,battler,stat,battle,showMessages|
    next false if !battler.pbHasType?(:GRASS)
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:HYPERCUTTER,
  proc { |ability,battler,stat,battle,showMessages|
    next false if stat!=PBStats::ATTACK
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",battler.pbThis,PBStats.getName(stat)))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",battler.pbThis,
           battler.abilityName,PBStats.getName(stat)))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:KEENEYE,
  proc { |ability,battler,stat,battle,showMessages|
    next false if stat!=PBStats::ACCURACY
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",battler.pbThis,PBStats.getName(stat)))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",battler.pbThis,
           battler.abilityName,PBStats.getName(stat)))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

#===============================================================================
# StatLossImmunityAbilityNonIgnorable handlers
#===============================================================================

BattleHandlers::StatLossImmunityAbilityNonIgnorable.add(:FULLMETALBODY,
  proc { |ability,battler,stat,battle,showMessages|
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbilityNonIgnorableSandy.add(:UNSHAKEN,
  proc { |ability,battler,stat,battle,showMessages|
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)
#===============================================================================
# StatLossImmunityAllyAbility handlers
#===============================================================================

BattleHandlers::StatLossImmunityAllyAbility.add(:FLOWERVEIL,
  proc { |ability,bearer,battler,stat,battle,showMessages|
    next false if !battler.pbHasType?(:GRASS)
    if showMessages
      battle.pbShowAbilitySplash(bearer)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s stat loss!",
           bearer.pbThis,bearer.abilityName,battler.pbThis(true)))
      end
      battle.pbHideAbilitySplash(bearer)
    end
    next true
  }
)

#===============================================================================
# AbilityOnStatGain handlers
#===============================================================================

# There aren't any!

#===============================================================================
# AbilityOnStatLoss handlers
#===============================================================================

BattleHandlers::AbilityOnStatLoss.add(:COMPETITIVE,
  proc { |ability,battler,stat,user|
    next if user && !user.opposes?(battler)
    battler.pbRaiseStatStageByAbility(PBStats::SPATK,2,battler)
  }
)

BattleHandlers::AbilityOnStatLoss.add(:DEFIANT,
  proc { |ability,battler,stat,user|
    next if user && !user.opposes?(battler)
    battler.pbRaiseStatStageByAbility(PBStats::ATTACK,2,battler)
  }
)

#===============================================================================
# PriorityChangeAbility handlers
#===============================================================================

BattleHandlers::PriorityChangeAbility.add(:GALEWINGS,
  proc { |ability,battler,move,pri|
    next pri+1 if battler.hp==battler.totalhp && isConst?(move.type,PBTypes,:FLYING)
  }
)

BattleHandlers::PriorityChangeAbility.add(:PRANKSTER,
  proc { |ability,battler,move,pri|
    if move.statusMove?
      battler.effects[PBEffects::Prankster] = true
      next pri+1
    end
  }
)

BattleHandlers::PriorityChangeAbility.add(:TRIAGE,
  proc { |ability,battler,move,pri|
    next pri+3 if move.healingMove?
  }
)

#===============================================================================
# PriorityBracketChangeAbility handlers
#===============================================================================

BattleHandlers::PriorityBracketChangeAbility.add(:STALL,
  proc { |ability,battler,subPri,battle|
    next -1 if subPri==0
  }
)

#===============================================================================
# PriorityBracketUseAbility handlers
#===============================================================================

# There aren't any!

#===============================================================================
# AbilityOnFlinch handlers
#===============================================================================

BattleHandlers::AbilityOnFlinch.add(:STEADFAST,
  proc { |ability,battler,battle|
    battler.pbRaiseStatStageByAbility(PBStats::SPEED,1,battler)
  }
)

#===============================================================================
# MoveBlockingAbility handlers
#===============================================================================

BattleHandlers::MoveBlockingAbility.add(:DAZZLING,
  proc { |ability,bearer,user,targets,move,battle|
    next false if battle.choices[user.index][4]<=0
    next false if !bearer.opposes?(user)
    ret = false
    targets.each do |b|
      next if !b.opposes?(user)
      ret = true
    end
    next ret
  }
)

BattleHandlers::MoveBlockingAbility.copy(:DAZZLING,:QUEENLYMAJESTY)

#===============================================================================
# MoveImmunityTargetAbility handlers
#===============================================================================

BattleHandlers::MoveImmunityTargetAbility.add(:BULLETPROOF,
  proc { |ability,user,target,move,type,battle|
    next false if !move.bombMove?
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
         target.pbThis,target.abilityName,move.name))
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FLASHFIRE,
  proc { |ability,user,target,move,type,battle|
    next false if user.index==target.index
    next false if !isConst?(type,PBTypes,:FIRE)
    battle.pbShowAbilitySplash(target)
    if !target.effects[PBEffects::FlashFire]
      target.effects[PBEffects::FlashFire] = true
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose!",target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose because of its {2}!",
           target.pbThis(true),target.abilityName))
      end
    else
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           target.pbThis,target.abilityName,move.name))
      end
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:LIGHTNINGROD,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:ELECTRIC,PBStats::SPATK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:MOTORDRIVE,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:ELECTRIC,PBStats::SPEED,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SAPSIPPER,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:GRASS,PBStats::ATTACK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SOUNDPROOF,
  proc { |ability,user,target,move,type,battle|
    next false if !move.soundMove?
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} blocks {3}!",target.pbThis,target.abilityName,move.name))
    end
    battle.pbHideAbilitySplash(target)
    next true

  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:STORMDRAIN,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:WATER,PBStats::SPATK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:WATERCOMPACTION,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:WATER,PBStats::SPDEF,2,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:TELEPATHY,
  proc { |ability,user,target,move,type,battle|
    next false if move.statusMove?
    next false if user.index==target.index || target.opposes?(user)
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon!",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon with {2}!",
         target.pbThis,target.abilityName))
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:VOLTABSORB,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:ELECTRIC,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:LEGENDARMOR,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:DRAGON,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:UNTAINTED,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityAbility(user,target,move,type,:DARK,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:CORRUPTION,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityAbility(user,target,move,type,:FAIRY,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:DIMENSIONBLOCK,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityAbility(user,target,move,type,:COSMIC,battle) || pbBattleMoveImmunityAbility(user,target,move,type,:TIME,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:MENTALBLOCK,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityAbility(user,target,move,type,:PSYCHIC,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:WATERABSORB,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:WATER,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.copy(:WATERABSORB,:DRYSKIN)

BattleHandlers::MoveImmunityTargetAbility.add(:WONDERGUARD,
  proc { |ability,user,target,move,type,battle|
    next false if move.statusMove?
    next false if type<0 || PBTypes.superEffective?(target.damageState.typeMod)
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1} avoided damage with {2}!",target.pbThis,target.abilityName))
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.copy(:WONDERGUARD,:TIMEWARP)

BattleHandlers::MoveImmunityTargetAbility.copy(:WONDERGUARD,:HYPERSPACE)
#===============================================================================
# MoveBaseTypeModifierAbility handlers
#===============================================================================

BattleHandlers::MoveBaseTypeModifierAbility.add(:AERILATE,
  proc { |ability,user,move,type|
    next if !isConst?(type,PBTypes,:NORMAL) || !hasConst?(PBTypes,:FLYING)
    move.powerBoost = true
    next getConst(PBTypes,:FLYING)
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:STELLARIZE,
  proc { |ability,user,move,type|
    next if !isConst?(type,PBTypes,:NORMAL) || !hasConst?(PBTypes,:COSMIC)
    move.powerBoost = true
    next getConst(PBTypes,:COSMIC)
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:ENTYMATE,
  proc { |ability,user,move,type|
    next if !isConst?(type,PBTypes,:NORMAL) || !hasConst?(PBTypes,:BUG)
    move.powerBoost = true
    next getConst(PBTypes,:BUG)
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:GALVANIZE,
  proc { |ability,user,move,type|
    next if !isConst?(type,PBTypes,:NORMAL) || !hasConst?(PBTypes,:ELECTRIC)
    move.powerBoost = true
    next getConst(PBTypes,:ELECTRIC)
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:LIQUIDVOICE,
  proc { |ability,user,move,type|
    next getConst(PBTypes,:WATER) if hasConst?(PBTypes,:WATER) && move.soundMove?
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:NORMALIZE,
  proc { |ability,user,move,type|
    next if !hasConst?(PBTypes,:NORMAL)
    move.powerBoost = true if NEWEST_BATTLE_MECHANICS
    next getConst(PBTypes,:NORMAL)
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:PIXILATE,
  proc { |ability,user,move,type|
    next if !isConst?(type,PBTypes,:NORMAL) || !hasConst?(PBTypes,:FAIRY)
    move.powerBoost = true
    next getConst(PBTypes,:FAIRY)
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:REFRIGERATE,
  proc { |ability,user,move,type|
    next if !isConst?(type,PBTypes,:NORMAL) || !hasConst?(PBTypes,:ICE)
    move.powerBoost = true
    next getConst(PBTypes,:ICE)
  }
)

#===============================================================================
# AccuracyCalcUserAbility handlers
#===============================================================================

BattleHandlers::AccuracyCalcUserAbility.add(:COMPOUNDEYES,
  proc { |ability,mods,user,target,move,type|
    mods[ACC_MULT] = (mods[ACC_MULT]*1.3).round
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:HUSTLE,
  proc { |ability,mods,user,target,move,type|
    mods[ACC_MULT] = (mods[ACC_MULT]*0.8).round if move.physicalMove?
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:KEENEYE,
  proc { |ability,mods,user,target,move,type|
    mods[EVA_STAGE] = 0 if mods[EVA_STAGE]>0 && NEWEST_BATTLE_MECHANICS
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:NOGUARD,
  proc { |ability,mods,user,target,move,type|
    mods[BASE_ACC] = 0
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:UNAWARE,
  proc { |ability,mods,user,target,move,type|
    mods[EVA_STAGE] = 0 if move.damagingMove?
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:VICTORYSTAR,
  proc { |ability,mods,user,target,move,type|
    mods[ACC_MULT] = (mods[ACC_MULT]*1.1).round
  }
)

#===============================================================================
# AccuracyCalcUserAllyAbility handlers
#===============================================================================

BattleHandlers::AccuracyCalcUserAllyAbility.add(:VICTORYSTAR,
  proc { |ability,mods,user,target,move,type|
    mods[ACC_MULT] = (mods[ACC_MULT]*1.1).round
  }
)

#===============================================================================
# AccuracyCalcTargetAbility handlers
#===============================================================================

BattleHandlers::AccuracyCalcTargetAbility.add(:LIGHTNINGROD,
  proc { |ability,mods,user,target,move,type|
    mods[BASE_ACC] = 0 if isConst?(type,PBTypes,:ELECTRIC)
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:NOGUARD,
  proc { |ability,mods,user,target,move,type|
    mods[BASE_ACC] = 0
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:SANDVEIL,
  proc { |ability,mods,user,target,move,type|
    if target.battle.pbWeather==PBWeather::Sandstorm
      mods[EVA_MULT] = (mods[EVA_MULT]*1.25).round
    end
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:SNOWCLOAK,
  proc { |ability,mods,user,target,move,type|
    if target.battle.pbWeather==PBWeather::Hail
      mods[EVA_MULT] = (mods[EVA_MULT]*1.25).round
    end
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:STORMDRAIN,
  proc { |ability,mods,user,target,move,type|
    mods[BASE_ACC] = 0 if isConst?(type,PBTypes,:WATER)
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:TANGLEDFEET,
  proc { |ability,mods,user,target,move,type|
    mods[ACC_MULT] /= 2 if target.effects[PBEffects::Confusion]>0
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:UNAWARE,
  proc { |ability,mods,user,target,move,type|
    mods[ACC_STAGE] = 0 if move.damagingMove?
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:WONDERSKIN,
  proc { |ability,mods,user,target,move,type|
    if move.statusMove? && user.opposes?(target)
      mods[BASE_ACC] = 0 if mods[BASE_ACC]>50
    end
  }
)

#===============================================================================
# DamageCalcUserAbility handlers
#===============================================================================

BattleHandlers::DamageCalcUserAbility.add(:AERILATE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.2).round if move.powerBoost
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:AERILATE,:PIXILATE,:REFRIGERATE,:GALVANIZE,:ENTYMATE,:STELLARIZE)

BattleHandlers::DamageCalcUserAbility.add(:ANALYTIC,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if (target.battle.choices[target.index][0]!=:UseMove &&
       target.battle.choices[target.index][0]!=:Shift) ||
       target.movedThisRound?
      mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.3).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BLAZE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.hp<=user.totalhp/3 && isConst?(type,PBTypes,:FIRE)
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DEFEATIST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[ATK_MULT] = (mults[ATK_MULT]*0.5).round if user.hp<=user.totalhp/2
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FLAREBOOST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.burned? && move.specialMove?
      mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.5).round
    end
  }
)
BattleHandlers::DamageCalcUserAbility.add(:BALLISTIC,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.2).round if move.bombMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FLASHFIRE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.effects[PBEffects::FlashFire] && isConst?(type,PBTypes,:FIRE)
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    w = user.battle.pbWeather
    if move.physicalMove? && (w==PBWeather::Sun || w==PBWeather::HarshSun)
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:GUTS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.pbHasAnyStatus? && move.physicalMove?
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:HUGEPOWER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[ATK_MULT] *= 2 if move.physicalMove?
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:HUGEPOWER,:PUREPOWER)

BattleHandlers::DamageCalcUserAbility.add(:COMPOSURE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[ATK_MULT] *= 2 if move.specialMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TRIAGE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[ATK_MULT] *= 1.5 if move.healingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:HUSTLE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round if move.physicalMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:IRONFIST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.2).round if move.punchingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MEGALAUNCHER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.5).round if move.pulseMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:AMPLIFIER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.5).round if move.soundMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MINUS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !move.specialMove?
    user.eachAlly do |b|
      next if !b.hasActiveAbility?([:MINUS,:PLUS])
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
      break
    end
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:MINUS,:PLUS)

BattleHandlers::DamageCalcUserAbility.add(:NEUROFORCE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if PBTypes.superEffective?(target.damageState.typeMod)
      mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*1.25).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:OVERGROW,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.hp<=user.totalhp/3 && isConst?(type,PBTypes,:GRASS)
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RECKLESS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.2).round if move.recoilMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RIVALRY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.gender!=2 && target.gender!=2
      if user.gender==target.gender
        mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.25).round
      else
        mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*0.75).round
      end
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SANDFORCE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.battle.pbWeather==PBWeather::Sandstorm &&
       (isConst?(type,PBTypes,:ROCK) ||
       isConst?(type,PBTypes,:GROUND) ||
       isConst?(type,PBTypes,:STEEL))
      mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.3).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SHEERFORCE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.3).round if move.addlEffect>0
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SLOWSTART,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.turnCount<=5 && move.physicalMove?
      mults[ATK_MULT] = (mults[ATK_MULT]*0.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SOLARPOWER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    w = user.battle.pbWeather
    if move.specialMove? && (w==PBWeather::Sun || w==PBWeather::HarshSun)
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SNIPER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if target.damageState.critical
      mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STAKEOUT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[ATK_MULT] *= 2 if target.battle.choices[target.index][0]==:SwitchOut
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STEELWORKER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round if isConst?(type,PBTypes,:STEEL)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STRONGJAW,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.5).round if move.bitingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SWARM,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.hp<=user.totalhp/3 && isConst?(type,PBTypes,:BUG)
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TECHNICIAN,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.index!=target.index && move.id>0 && baseDmg*mults[BASE_DMG_MULT]/0x1000<=60
      mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TIGHTFOCUS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.5).round if move.beamMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TINTEDLENS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[FINAL_DMG_MULT] *= 2 if PBTypes.resistant?(target.damageState.typeMod)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TORRENT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.hp<=user.totalhp/3 && isConst?(type,PBTypes,:WATER)
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TOUGHCLAWS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*4/3.0).round if move.contactMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:VAMPIRIC,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.5).round if move.function=="14F" || move.function=="0DD"
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TOXICBOOST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.poisoned? && move.physicalMove?
      mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:WATERBUBBLE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[ATK_MULT] *= 2 if isConst?(type,PBTypes,:WATER)
  }
)

#===============================================================================
# DamageCalcUserAllyAbility handlers
#===============================================================================

BattleHandlers::DamageCalcUserAllyAbility.add(:BATTERY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !move.specialMove?
    mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*1.3).round
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    w = user.battle.pbWeather
    if move.physicalMove? && (w==PBWeather::Sun || w==PBWeather::HarshSun)
      mults[ATK_MULT] = (mults[ATK_MULT]*1.5).round
    end
  }
)

#===============================================================================
# DamageCalcTargetAbility handlers
#===============================================================================

BattleHandlers::DamageCalcTargetAbility.add(:DRYSKIN,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if isConst?(type,PBTypes,:FIRE)
      mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*1.25).round
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FILTER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if PBTypes.superEffective?(target.damageState.typeMod)
      mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*0.75).round
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.copy(:FILTER,:SOLIDROCK)

BattleHandlers::DamageCalcTargetAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    w = user.battle.pbWeather
    if move.specialMove? && (w==PBWeather::Sun || w==PBWeather::HarshSun)
      mults[DEF_MULT] = (mults[DEF_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FLUFFY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[FINAL_DMG_MULT] *= 2 if isConst?(move.calcType,PBTypes,:FIRE)
    mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*0.5).round if move.contactMove?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FURCOAT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[DEF_MULT] *= 2 if move.physicalMove? || move.function=="122"   # Psyshock
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:ICESCALES,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[DEF_MULT] *= 2 if move.specialMove? || !move.function=="122"   # Psyshock
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:GRASSPELT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.battle.field.terrain==PBBattleTerrains::Grassy
      mults[DEF_MULT] = (mults[DEF_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:HEATPROOF,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*0.5).round if isConst?(type,PBTypes,:FIRE)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:MARVELSCALE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if target.pbHasAnyStatus? && move.physicalMove?
      mults[DEF_MULT] = (mults[DEF_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:MULTISCALE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if target.hp==target.totalhp
      mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*0.5).round
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:THICKFAT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if isConst?(type,PBTypes,:FIRE) || isConst?(type,PBTypes,:ICE)
      mults[BASE_DMG_MULT] = (mults[BASE_DMG_MULT]*0.5).round
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:WATERBUBBLE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if isConst?(type,PBTypes,:FIRE)
      mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*0.5).round
    end
  }
)

#===============================================================================
# DamageCalcTargetAbilityNonIgnorable handlers
#===============================================================================

BattleHandlers::DamageCalcTargetAbilityNonIgnorable.add(:PRISMARMOR,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if PBTypes.superEffective?(target.damageState.typeMod)
      mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*0.75).round
    end
  }
)

BattleHandlers::DamageCalcTargetAbilityNonIgnorable.add(:SHADOWSHIELD,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if target.hp==target.totalhp
      mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*0.5).round
    end
  }
)

#===============================================================================
# DamageCalcTargetAllyAbility handlers
#===============================================================================

BattleHandlers::DamageCalcTargetAllyAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    w = user.battle.pbWeather
    if move.specialMove? && (w==PBWeather::Sun || w==PBWeather::HarshSun)
      mults[DEF_MULT] = (mults[DEF_MULT]*1.5).round
    end
  }
)

BattleHandlers::DamageCalcTargetAllyAbility.add(:FRIENDGUARD,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[FINAL_DMG_MULT] = (mults[FINAL_DMG_MULT]*0.75).round
  }
)

#===============================================================================
# CriticalCalcUserAbility handlers
#===============================================================================

BattleHandlers::CriticalCalcUserAbility.add(:MERCILESS,
  proc { |ability,user,target,c|
    next 99 if target.poisoned?
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:SUPERLUCK,
  proc { |ability,user,target,c|
    next c+1
  }
)

#===============================================================================
# CriticalCalcTargetAbility handlers
#===============================================================================

BattleHandlers::CriticalCalcTargetAbility.add(:BATTLEARMOR,
  proc { |ability,user,target,c|
    next -1
  }
)

BattleHandlers::CriticalCalcTargetAbility.copy(:BATTLEARMOR,:SHELLARMOR)

#===============================================================================
# TargetAbilityOnHit handlers
#===============================================================================

BattleHandlers::TargetAbilityOnHit.add(:AFTERMATH,
  proc { |ability,user,target,move,battle|
    next if !target.fainted?
    next if !move.pbContactMove?(user)
    battle.pbShowAbilitySplash(target)
    if !battle.moldBreaker
      dampBattler = battle.pbCheckGlobalAbility(:DAMP)
      if dampBattler
        battle.pbShowAbilitySplash(dampBattler)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1} cannot use {2}!",target.pbThis,target.abilityName))
        else
          battle.pbDisplay(_INTL("{1} cannot use {2} because of {3}'s {4}!",
             target.pbThis,target.abilityName,dampBattler.pbThis(true),dampBattler.abilityName))
        end
        battle.pbHideAbilitySplash(dampBattler)
        battle.pbHideAbilitySplash(target)
        next
      end
    end
    if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(user.totalhp/4,false)
      battle.pbDisplay(_INTL("{1} was caught in the aftermath!",user.pbThis))
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:ANGERPOINT,
  proc { |ability,user,target,move,battle|
    next if !target.damageState.critical
    next if !target.pbCanRaiseStatStage?(PBStats::ATTACK,target)
    battle.pbShowAbilitySplash(target)
    target.stages[PBStats::ATTACK] = 6
    battle.pbCommonAnimation("StatUp",target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} maxed its {2}!",target.pbThis,PBStats.getName(PBStats::ATTACK)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} maxed its {3}!",
         target.pbThis,target.abilityName,PBStats.getName(PBStats::ATTACK)))
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CURSEDBODY,
  proc { |ability,user,target,move,battle|
    next if user.fainted?
    next if user.effects[PBEffects::Disable]>0
    regularMove = nil
    user.eachMove do |m|
      next if m.id!=user.lastRegularMoveUsed
      regularMove = m
      break
    end
    next if !regularMove || (regularMove.pp==0 && regularMove.totalpp>0)
    next if battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if !move.pbMoveFailedAromaVeil?(target,user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      user.effects[PBEffects::Disable]     = 3
      user.effects[PBEffects::DisableMove] = regularMove.id
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} was disabled!",user.pbThis,regularMove.name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} was disabled by {3}'s {4}!",
           user.pbThis,regularMove.name,target.pbThis(true),target.abilityName))
      end
      battle.pbHideAbilitySplash(target)
      user.pbItemStatusCureCheck
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CUTECHARM,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanAttract?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} made {3} fall in love!",target.pbThis,
           target.abilityName,user.pbThis(true))
      end
      user.pbAttract(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:EFFECTSPORE,
  proc { |ability,user,target,move,battle|
    # NOTE: This ability has a 30% chance of triggering, not a 30% chance of
    #       inflicting a status condition. It can try (and fail) to inflict a
    #       status condition that the user is immune to.
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100)>=30
    r = battle.pbRandom(3)
    next if r==0 && user.asleep?
    next if r==1 && user.poisoned?
    next if r==2 && user.paralyzed?
    battle.pbShowAbilitySplash(target)
    if user.affectedByPowder?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      case r
      when 0
        if user.pbCanSleep?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} made {3} fall asleep!",target.pbThis,
               target.abilityName,user.pbThis(true))
          end
          user.pbSleep(msg)
        end
      when 1
        if user.pbCanPoison?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} poisoned {3}!",target.pbThis,
               target.abilityName,user.pbThis(true))
          end
          user.pbPoison(target,msg)
        end
      when 2
        if user.pbCanParalyze?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
               target.pbThis,target.abilityName,user.pbThis(true))
          end
          user.pbParalyze(target,msg)
        end
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:FLAMEBODY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.burned? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanBurn?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} burned {3}!",target.pbThis,target.abilityName,user.pbThis(true))
      end
      user.pbBurn(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:GOOEY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    user.pbLowerStatStageByAbility(PBStats::SPEED,1,target,true,true)
  }
)

BattleHandlers::TargetAbilityOnHit.copy(:GOOEY,:TANGLINGHAIR)

BattleHandlers::TargetAbilityOnHit.add(:ILLUSION,
  proc { |ability,user,target,move,battle|
    # NOTE: This intentionally doesn't show the ability splash.
    next if !target.effects[PBEffects::Illusion]
    target.effects[PBEffects::Illusion] = nil
    battle.scene.pbChangePokemon(target,target.pokemon)
    battle.pbDisplay(_INTL("{1}'s illusion wore off!",target.pbThis))
    battle.pbSetSeen(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:INNARDSOUT,
  proc { |ability,user,target,move,battle|
    next if !target.fainted? || user.dummy
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(target.damageState.hpLost,false)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!",user.pbThis,
           target.pbThis(true),target.abilityName))
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:IRONBARBS,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(user.totalhp/8,false)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!",user.pbThis,
           target.pbThis(true),target.abilityName))
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.copy(:IRONBARBS,:ROUGHSKIN)

BattleHandlers::TargetAbilityOnHit.add(:JUSTIFIED,
  proc { |ability,user,target,move,battle|
    next if !isConst?(move.calcType,PBTypes,:DARK)
    target.pbRaiseStatStageByAbility(PBStats::ATTACK,1,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:MUMMY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.fainted?
    abilityBlacklist = [
       # This ability
       :MUMMY,
       # Form-changing abilities
       :BATTLEBOND,
       :DISGUISE,
#       :FLOWERGIFT,                                      # This can be replaced
       :FORECAST,                                        # This can be replaced
       :MULTITYPE,
       :ACCLIMATE,
       :POWERCONSTRUCT,
       :SCHOOLING,
       :SHIELDSDOWN,
       :STANCECHANGE,
       :ZENMODE,
       # Abilities intended to be inherent properties of a certain species
       :COMATOSE,
       :RKSSYSTEM,
    ]
    failed = false
    abilityBlacklist.each do |abil|
      next if !isConst?(user.ability,PBAbilities,abil)
      failed = true
      break
    end
    next if failed
    oldAbil = -1
    battle.pbShowAbilitySplash(target) if user.opposes?(target)
    if user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      oldAbil = user.ability
      battle.pbShowAbilitySplash(user,true,false) if user.opposes?(target)
      user.ability = getConst(PBAbilities,:MUMMY)
      battle.pbReplaceAbilitySplash(user) if user.opposes?(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s Ability became {2}!",user.pbThis,user.abilityName))
      else
        battle.pbDisplay(_INTL("{1}'s Ability became {2} because of {3}!",
           user.pbThis,user.abilityName,target.pbThis(true)))
      end
      battle.pbHideAbilitySplash(user) if user.opposes?(target)
    end
    battle.pbHideAbilitySplash(target) if user.opposes?(target)
    user.pbOnAbilityChanged(oldAbil) if oldAbil>=0
  }
)

BattleHandlers::TargetAbilityOnHit.add(:POISONPOINT,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.poisoned? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanPoison?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} poisoned {3}!",target.pbThis,target.abilityName,user.pbThis(true))
      end
      user.pbPoison(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:RATTLED,
  proc { |ability,user,target,move,battle|
    next if !isConst?(move.calcType,PBTypes,:BUG) &&
            !isConst?(move.calcType,PBTypes,:DARK) &&
            !isConst?(move.calcType,PBTypes,:GHOST)
    target.pbRaiseStatStageByAbility(PBStats::SPEED,1,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:STAMINA,
  proc { |ability,user,target,move,battle|
    target.pbRaiseStatStageByAbility(PBStats::DEFENSE,1,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:STATIC,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.paralyzed? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanParalyze?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
           target.pbThis,target.abilityName,user.pbThis(true))
      end
      user.pbParalyze(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WEAKARMOR,
  proc { |ability,user,target,move,battle|
    next if !move.physicalMove?
    next if !target.pbCanLowerStatStage?(PBStats::DEFENSE,target) &&
            !target.pbCanRaiseStatStage?(PBStats::SPEED,target)
    battle.pbShowAbilitySplash(target)
    target.pbLowerStatStageByAbility(PBStats::DEFENSE,1,target,false)
    target.pbRaiseStatStageByAbility(PBStats::SPEED,
       (NEWEST_BATTLE_MECHANICS) ? 2 : 1,target,false)
    battle.pbHideAbilitySplash(target)
  }
)

#===============================================================================
# UserAbilityOnHit handlers
#===============================================================================

BattleHandlers::UserAbilityOnHit.add(:POISONTOUCH,
  proc { |ability,user,target,move,battle|
    next if !move.contactMove?
    next if battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(user)
    if target.hasActiveAbility?(:SHIELDDUST) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
    elsif target.pbCanPoison?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} poisoned {3}!",user.pbThis,user.abilityName,target.pbThis(true))
      end
      target.pbPoison(user,msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)

#===============================================================================
# UserAbilityEndOfMove handlers
#===============================================================================

BattleHandlers::UserAbilityEndOfMove.add(:BEASTBOOST,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0
    userStats = user.plainStats
    highestStatValue = userStats.max
    PBStats.eachMainBattleStat do |s|
      next if userStats[s]<highestStatValue
      if user.pbCanRaiseStatStage?(s,user)
        user.pbRaiseStatStageByAbility(s,numFainted,user)
      end
      break
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:MAGICIAN,
  proc { |ability,user,targets,move,battle|
    next if !battle.futureSight
    next if !move.pbDamagingMove?
    next if user.item>0
    next if battle.wildBattle? && user.opposes?
    targets.each do |b|
      next if b.damageState.unaffected || b.damageState.substitute
      next if b.item==0
      next if b.unlosableItem?(b.item) || user.unlosableItem?(b.item)
      battle.pbShowAbilitySplash(user)
      if b.hasActiveAbility?(:STICKYHOLD)
        battle.pbShowAbilitySplash(b) if user.opposes?(b)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1}'s item cannot be stolen!",b.pbThis))
        end
        battle.pbHideAbilitySplash(b) if user.opposes?(b)
        next
      end
      user.item = b.item
      b.item = 0
      b.effects[PBEffects::Unburden] = true
      if battle.wildBattle? && user.initialItem==0 && b.initialItem==user.item
        user.setInitialItem(user.item)
        b.setInitialItem(0)
      end
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",user.pbThis,
           b.pbThis(true),user.itemName))
      else
        battle.pbDisplay(_INTL("{1} stole {2}'s {3} with {4}!",user.pbThis,
           b.pbThis(true),user.itemName,user.abilityName))
      end
      battle.pbHideAbilitySplash(user)
      user.pbHeldItemTriggerCheck
      break
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:MOXIE,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0 || !user.pbCanRaiseStatStage?(PBStats::ATTACK,user)
    user.pbRaiseStatStageByAbility(PBStats::ATTACK,numFainted,user)
  }
)

BattleHandlers::UserAbilityEndOfMove.copy(:MOXIE,:CHILLINGNEIGH)

BattleHandlers::UserAbilityEndOfMove.add(:GRIMNEIGH,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0 || !user.pbCanRaiseStatStage?(PBStats::SPATK,user)
    user.pbRaiseStatStageByAbility(PBStats::SPATK,numFainted,user)
  }
)
#===============================================================================
# TargetAbilityAfterMoveUse handlers
#===============================================================================

BattleHandlers::TargetAbilityAfterMoveUse.add(:BERSERK,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if target.damageState.initialHP<target.totalhp/2 || target.hp>=target.totalhp/2
    next if !target.pbCanRaiseStatStage?(PBStats::SPATK,target)
    target.pbRaiseStatStageByAbility(PBStats::SPATK,1,target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:COLORCHANGE,
  proc { |ability,target,user,move,switched,battle|
    next if target.damageState.calcDamage==0 || target.damageState.substitute
    next if move.calcType<0 || PBTypes.isPseudoType?(move.calcType)
    next if target.pbHasType?(move.calcType) && !target.pbHasOtherType?(move.calcType)
    typeName = PBTypes.getName(move.calcType)
    battle.pbShowAbilitySplash(target)
    target.pbChangeTypes(move.calcType)
    battle.pbDisplay(_INTL("{1}'s {2} made it the {3} type!",target.pbThis,
       target.abilityName,typeName))
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:PICKPOCKET,
  proc { |ability,target,user,move,switched,battle|
    # NOTE: According to Bulbapedia, this can still trigger to steal the user's
    #       item even if it was switched out by a Red Card. This doesn't make
    #       sense, so this code doesn't do it.
    next if battle.wildBattle? && target.opposes?
    next if !move.contactMove?
    next if switched.include?(user.index)
    next if user.effects[PBEffects::Substitute]>0 || target.damageState.substitute
    next if target.item>0 || user.item==0
    next if user.unlosableItem?(user.item) || target.unlosableItem?(user.item)
    battle.pbShowAbilitySplash(target)
    if user.hasActiveAbility?(:STICKYHOLD)
      battle.pbShowAbilitySplash(user) if target.opposes?(user)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s item cannot be stolen!",user.pbThis))
      end
      battle.pbHideAbilitySplash(user) if target.opposes?(user)
      battle.pbHideAbilitySplash(target)
      next
    end
    target.item = user.item
    user.item = 0
    user.effects[PBEffects::Unburden] = true
    if battle.wildBattle? && target.initialItem==0 && user.initialItem==target.item
      target.setInitialItem(target.item)
      user.setInitialItem(0)
    end
    battle.pbDisplay(_INTL("{1} pickpocketed {2}'s {3}!",target.pbThis,
       user.pbThis(true),target.itemName))
    battle.pbHideAbilitySplash(target)
    target.pbHeldItemTriggerCheck
  }
)

#===============================================================================
# EORWeatherAbility handlers
#===============================================================================

BattleHandlers::EORWeatherAbility.add(:DRYSKIN,
  proc { |ability,weather,battler,battle|
    case weather
    when PBWeather::Sun, PBWeather::HarshSun
      battle.pbShowAbilitySplash(battler)
      battle.scene.pbDamageAnimation(battler)
      battler.pbReduceHP(battler.totalhp/8,false)
      battle.pbDisplay(_INTL("{1} was hurt by the sunlight!",battler.pbThis))
      battle.pbHideAbilitySplash(battler)
      battler.pbItemHPHealCheck
    when PBWeather::Rain, PBWeather::HeavyRain
      next if !battler.canHeal?
      battle.pbShowAbilitySplash(battler)
      battler.pbRecoverHP(battler.totalhp/8)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::EORWeatherAbility.add(:ICEBODY,
  proc { |ability,weather,battler,battle|
    next unless weather==PBWeather::Hail
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/16)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:RAINDISH,
  proc { |ability,weather,battler,battle|
    next unless weather==PBWeather::Rain || weather==PBWeather::HeavyRain
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/16)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:SOLARPOWER,
  proc { |ability,weather,battler,battle|
    next unless weather==PBWeather::Sun || weather==PBWeather::HarshSun
    battle.pbShowAbilitySplash(battler)
    battle.scene.pbDamageAnimation(battler)
    battler.pbReduceHP(battler.totalhp/8,false)
    battle.pbDisplay(_INTL("{1} was hurt by the sunlight!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
    battler.pbItemHPHealCheck
  }
)

BattleHandlers::EORWeatherAbility.add(:ACCLIMATE,
  proc { |ability,weather,battler,battle|
    newWeather = 0
    oldWeather = battle.field.weather
    newForm = battler.form
    newWeather = newForm
    battle.eachOtherSideBattler(battler.index) do |b|
    targetTypes = b.pbTypes
    type1 = targetTypes[0]
    type2 = targetTypes[1] if targetTypes.length>1
    case type1
    when 0
      case type2
      when 7, 14, 20; newWeather = 7
      when 18; newWeather = 16
      when 2, 21; newWeather = 19
      when 6; newWeather = 1
      when 0,1,3,4,5,8,9,10,11,12,13,15,16,17,19, nil; newWeather = 15
      end
    when 1
      case type2
      when 3, 19; newWeather = 17
      when 8; newWeather = 6
      when 2, 10; newWeather = 19
      when 0,1,4,5,6,7,9,11,12,13,14,15,16,17,18,20,21, nil; newWeather = 4
      end
    when 2
      case type2
      when 4, 15, 16, 21; newWeather = 3
      when 10; newWeather = 19
      when 0,1,2,3,5,6,7,8,9,11,12,13,14,17,18,19,20, nil; newWeather = 9
      end
    when 5
      case type2
      when 15, 17; newWeather = 15
      when 2, 6, 12, 20, 21, 18; newWeather = 16
      when 11, 4; newWeather = 13
      when 10; newWeather = 2
      when 19; newWeather = 19
      when 0, 1, 3, 7, 8, 13, 16, 14, nil; newWeather = 14
      end
    when 4
      case type2
      when 11, 5, 13; newWeather = 13
      when 16, 2, 21; newWeather = 3
      when 19; newWeather = 17
      when 20; newWeather = 5
      when 0,1,3,4,6,7,8,9,10,12,14,15,17,18, nil; newWeather = 2
      end
    when 3
      case type2
      when 17, 8, 13, 5, 10, 14; newWeather = 14
      when 20; newWeather = 16
      when 21; newWeather = 12
      when 7; newWeather = 5
      when 0,1,2,3,4,6,9,11,12,15,16,18,19, nil; newWeather = 17
      end
    when 6
      case type2
      when 4, 11, 1; newWeather = 8
      when 12, 8, 19; newWeather = 1
      when 20; newWeather = 16
      when 0,2,3,5,6,7,9,10,13,14,15,16,17,18,21, nil; newWeather = 12
      end
    when 7
      case type2
      when 1, 17; newWeather = 4
      when 18; newWeather = 16
      when 6; newWeather = 1
      when 0,2,3,4,5,7,8,9,10,11,12,13,14,15,16,19,20,21, nil; newWeather = 7
      end
    when 8
      case type2
      when 11; newWeather = 9
      when 20; newWeather = 7
      when 10, 5; newWeather = 14
      when 17, 0; newWeather = 15
      when 16; newWeather = 6
      when 2,3,4,6,7,8,9,12,13,14,15,18,19,21, nil; newWeather = 1
      end
    when 12
      case type2
      when 8, 19, 15; newWeather = 1
      when 20, 18; newWeather = 11
      when 16, 4, 2, 21, 13; newWeather = 3
      when 17, 14; newWeather = 18
      when 5; newWeather = 16
      when 0, 1, 3, 6, 7, 10, 11, nil; newWeather = 8
      end
    when 10
      case type2
      when 12; newWeather = 8
      when 11; newWeather = 9
      when 19, 5, 1, 2, 21; newWeather = 19
      when 20; newWeather = 7
      when 16, 13; newWeather = 14
      when 0,3,4,6,7,8,9,10,14,15,17,18, nil; newWeather = 2
      end
    when 11
      case type2
      when 10, 2; newWeather = 9
      when 7; newWeather = 7
      when 4, 5; newWeather = 13
      when 14; newWeather = 20
      when 0,1,3,6,8,9,11,12,13,15,16,17,18,19,20,21, nil; newWeather = 6
      end
    when 13
      case type2
      when 2, 12; newWeather = 3
      when 20; newWeather = 5
      when 6; newWeather = 1
      when 0,1,3,4,5,7,8,9,10,11,13,14,15,16,17,18,19,21, nil; newWeather = 14
      end
    when 15
      case type2
      when 7, 14; newWeather = 7
      when 20, 18, 5; newWeather = 16
      when 21, 10, 2, 3; newWeather = 12
      when 12, 6, 8, 19; newWeather = 1
      when 0, 1, 4, 11, 16, 13, 17, nil; newWeather = 15
      end
    when 14
      case type2
      when 17, 12; newWeather = 18
      when 1, 2, 8, 11; newWeather = 20
      when 15, 18; newWeather = 16
      when 0,3,4,5,6,7,9,10,13,14,16,19,20,21, nil; newWeather = 7
      end
    when 16
      case type2
      when 21, 4, 2, 12; newWeather = 3
      when 17, 1, 20; newWeather = 4
      when 10; newWeather = 12
      when 14; newWeather = 20
      when 0,3,5,6,7,8,9,11,13,15,16,18,19, nil; newWeather = 6
      end
    when 17
      case type2
      when 0,1,2,4,6,7,11,13,16,18,20,21,nil; newWeather = 4
      when 3,10,19; newWeather = 14
      when 12,14; newWeather = 18
      when 5,8,15; newWeather = 15
      end
    when 18
      case type2
      when 10, 21; newWeather = 11
      when 14, 7, 20; newWeather = 16
      when 0,1,2,3,4,5,6,8,9,11,12,13,15,16,17,18,19, nil; newWeather = 6
      end
    when 19
      case type2
      when 8; newWeather = 6
      when 4; newWeather = 13
      when 7; newWeather = 7
      when 3, 1; newWeather = 17
      when 15, 12, 6; newWeather = 1
      when 0,2,5,9,10,11,13,14,16,17,18,19,20,21, nil; newWeather = 19
      end
    when 20
      case type2
      when 0, 17; newWeather = 11
      when 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,19,20,21, nil; newWeather = 5
      end
    when 21
      case type2
      when 4, 2, 12, 16; newWeather = 3
      when 3, 5, 8; newWeather = 14
      when 1; newWeather = 4
      when 11; newWeather = 6
      when 0,6,7,9,10,13,14,15,16,17,18,19,20,21, nil; newWeather = 12
      end
    end
  end
  if newWeather==newForm
    weatherChange = battle.field.weather
    break
  end
  case newWeather
  when 1; weatherChange = PBWeather::Sun  if weather != PBWeather::Sun
  when 2; weatherChange = PBWeather::Rain  if weather != PBWeather::Rain
  when 3; weatherChange = PBWeather::Sleet  if weather != PBWeather::Sleet
  when 4; weatherChange = PBWeather::Fog  if weather != PBWeather::Fog
  when 5; weatherChange = PBWeather::Overcast  if weather != PBWeather::Overcast
  when 6; weatherChange = PBWeather::Starstorm  if weather != PBWeather::Starstorm
  when 7; weatherChange = PBWeather::Eclipse  if weather != PBWeather::Eclipse
  when 8; weatherChange = PBWeather::Windy  if weather != PBWeather::Windy
  when 9; weatherChange = PBWeather::HeatLight  if weather != PBWeather::HeatLight
  when 10; weatherChange = PBWeather::StrongWinds  if weather != PBWeather::StrongWinds
  when 11; weatherChange = PBWeather::AcidRain  if weather != PBWeather::AcidRain
  when 12; weatherChange = PBWeather::Sandstorm  if weather != PBWeather::Sandstorm
  when 13; weatherChange = PBWeather::Rainbow  if weather != PBWeather::Rainbow
  when 14; weatherChange = PBWeather::DustDevil  if weather != PBWeather::DustDevil
  when 15; weatherChange = PBWeather::DAshfall  if weather != PBWeather::DAshfall
  when 16; weatherChange = PBWeather::VolcanicAsh  if weather != PBWeather::VolcanicAsh
  when 17; weatherChange = PBWeather::Borealis  if weather != PBWeather::Borealis
  when 18; weatherChange = PBWeather::Humid  if weather != PBWeather::Humid
  when 19; weatherChange = PBWeather::TimeWarp  if weather != PBWeather::TimeWarp
  when 20; weatherChange = PBWeather::Reverb  if weather != PBWeather::Reverb
  end
  battle.pbShowAbilitySplash(battler)
  battle.field.weather = weatherChange
  battle.field.weatherDuration = 5
  @weatherType = weatherChange
  case weatherChange
  when PBWeather::Starstorm;   battle.pbDisplay(_INTL("Stars fill the sky."))
  when PBWeather::Thunder;     battle.pbDisplay(_INTL("Lightning flashes in th sky."))
  when PBWeather::Humid;       battle.pbDisplay(_INTL("The air is humid."))
  when PBWeather::Overcast;    battle.pbDisplay(_INTL("The sky is overcast."))
  when PBWeather::Eclipse;     battle.pbDisplay(_INTL("The sky is dark."))
  when PBWeather::Fog;         battle.pbDisplay(_INTL("The fog is deep."))
  when PBWeather::AcidRain;    battle.pbDisplay(_INTL("Acid rain is falling."))
  when PBWeather::VolcanicAsh; battle.pbDisplay(_INTL("Volcanic Ash sprinkles down."))
  when PBWeather::Rainbow;     battle.pbDisplay(_INTL("A rainbow crosses the sky."))
  when PBWeather::Borealis;    battle.pbDisplay(_INTL("The sky is ablaze with color."))
  when PBWeather::TimeWarp;    battle.pbDisplay(_INTL("Time has stopped."))
  when PBWeather::Reverb;      battle.pbDisplay(_INTL("A dull echo hums."))
  when PBWeather::DClear;      battle.pbDisplay(_INTL("The sky is distorted."))
  when PBWeather::DRain;       battle.pbDisplay(_INTL("Rain is falling upward."))
  when PBWeather::DWind;       battle.pbDisplay(_INTL("The wind is haunting."))
  when PBWeather::DAshfall;    battle.pbDisplay(_INTL("Ash floats in midair."))
  when PBWeather::Sleet;       battle.pbDisplay(_INTL("Sleet began to fall."))
  when PBWeather::Windy;       battle.pbDisplay(_INTL("There is a slight breeze."))
  when PBWeather::HeatLight;   battle.pbDisplay(_INTL("Static fills the air."))
  when PBWeather::DustDevil;   battle.pbDisplay(_INTL("A dust devil approaches."))
  when PBWeather::Sun;         battle.pbDisplay(_INTL("The sunlight is strong."))
  when PBWeather::Rain;        battle.pbDisplay(_INTL("It is raining."))
  when PBWeather::Sandstorm;   battle.pbDisplay(_INTL("A sandstorm is raging."))
  when PBWeather::Hail;        battle.pbDisplay(_INTL("Hail is falling."))
  when PBWeather::HarshSun;    battle.pbDisplay(_INTL("The sunlight is extremely harsh."))
  when PBWeather::HeavyRain;   battle.pbDisplay(_INTL("It is raining heavily."))
  when PBWeather::StrongWinds; battle.pbDisplay(_INTL("The wind is strong."))
  when PBWeather::ShadowSky;   battle.pbDisplay(_INTL("The sky is shadowy."))
  end
    newForm = newWeather
    if @form!=newForm
      battler.pbChangeForm(newForm,_INTL("{1} transformed!",battler.pbThis))
    end
    oldWeather = weatherChange
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# EORHealingAbility handlers
#===============================================================================

BattleHandlers::EORHealingAbility.add(:HEALER,
  proc { |ability,battler,battle|
    next unless battle.pbRandom(100)<30
    battler.eachAlly do |b|
      next if b.status==PBStatuses::NONE
      battle.pbShowAbilitySplash(battler)
      oldStatus = b.status
      b.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        case oldStatus
        when PBStatuses::SLEEP
          battle.pbDisplay(_INTL("{1}'s {2} woke its partner up!",battler.pbThis,battler.abilityName))
        when PBStatuses::POISON
          battle.pbDisplay(_INTL("{1}'s {2} cured its partner's poison!",battler.pbThis,battler.abilityName))
        when PBStatuses::BURN
          battle.pbDisplay(_INTL("{1}'s {2} healed its partner's burn!",battler.pbThis,battler.abilityName))
        when PBStatuses::PARALYSIS
          battle.pbDisplay(_INTL("{1}'s {2} cured its partner's paralysis!",battler.pbThis,battler.abilityName))
        when PBStatuses::FROZEN
          battle.pbDisplay(_INTL("{1}'s {2} defrosted its partner!",battler.pbThis,battler.abilityName))
        end
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::EORHealingAbility.add(:HYDRATION,
  proc { |ability,battler,battle|
    next if battler.status==PBStatuses::NONE
    weather = battle.pbWeather
    next if weather!=PBWeather::Rain && weather!=PBWeather::HeavyRain
    battle.pbShowAbilitySplash(battler)
    oldStatus = battler.status
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      case oldStatus
      when PBStatuses::SLEEP
        battle.pbDisplay(_INTL("{1}'s {2} woke it up!",battler.pbThis,battler.abilityName))
      when PBStatuses::POISON
        battle.pbDisplay(_INTL("{1}'s {2} cured its poison!",battler.pbThis,battler.abilityName))
      when PBStatuses::BURN
        battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",battler.pbThis,battler.abilityName))
      when PBStatuses::PARALYSIS
        battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",battler.pbThis,battler.abilityName))
      when PBStatuses::FROZEN
        battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",battler.pbThis,battler.abilityName))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORHealingAbility.add(:SHEDSKIN,
  proc { |ability,battler,battle|
    next if battler.status==PBStatuses::NONE
    next unless battle.pbRandom(100)<30
    battle.pbShowAbilitySplash(battler)
    oldStatus = battler.status
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      case oldStatus
      when PBStatuses::SLEEP
        battle.pbDisplay(_INTL("{1}'s {2} woke it up!",battler.pbThis,battler.abilityName))
      when PBStatuses::POISON
        battle.pbDisplay(_INTL("{1}'s {2} cured its poison!",battler.pbThis,battler.abilityName))
      when PBStatuses::BURN
        battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",battler.pbThis,battler.abilityName))
      when PBStatuses::PARALYSIS
        battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",battler.pbThis,battler.abilityName))
      when PBStatuses::FROZEN
        battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",battler.pbThis,battler.abilityName))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)
BattleHandlers::EORHealingAbility.add(:RESURGENCE,
  proc { |ability,battler,battle|
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/16)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORHealingAbility.add(:ASPIRANT,
  proc { |ability,battler,battle|
    wishHeal = $game_variables[103]
    $game_variables[101] -= 1
    if $game_variables[101]==0
      wishMaker = $game_variables[102]
      battler.pbRecoverHP(wishHeal)
      battle.pbDisplay(_INTL("{1}'s wish came true!",wishMaker))
    end
    next if $game_variables[101]>0
    if $game_variables[101]<0
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        $game_variables[103] = (battler.totalhp/2)
        $game_variables[102] = battler.pbThis
        $game_variables[101] += 2
        battle.pbDisplay(_INTL("{1} made a wish!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1} made a wish with {2}",battler.pbThis,battler.abilityName))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORHealingAbility.add(:HOPEFULTOLL,
  proc { |ability,battler,battle|
    def pbAromatherapyHeal(pkmn,battler=nil)
      oldStatus = (battler) ? battler.status : pkmn.status
      curedName = (battler) ? battler.pbThis : pkmn.name
      if battler
        battler.pbCureStatus(false)
      else
        pkmn.status      = PBStatuses::NONE
        pkmn.statusCount = 0
      end
    end
    battle.pbShowAbilitySplash(battler)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} rang a healing bell!",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} sounded a {2}",battler.pbThis,battler.abilityName))
    end
    battle.pbParty(battler.index).each_with_index do |pkmn,i|
      next if !pkmn || !pkmn.able? || pkmn.status==PBStatuses::NONE
      pbAromatherapyHeal(pkmn)
    end
    battle.pbHideAbilitySplash(battler)
  }
)
#===============================================================================
# EOREffectAbility handlers
#===============================================================================

BattleHandlers::EOREffectAbility.add(:BADDREAMS,
  proc { |ability,battler,battle|
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler) || !b.asleep?
      battle.pbShowAbilitySplash(battler)
      next if !b.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      oldHP = b.hp
      b.pbReduceHP(b.totalhp/8)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is tormented!",b.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is tormented by {2}'s {3}!",b.pbThis,
           battler.pbThis(true),battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
    end
  }
)

BattleHandlers::EOREffectAbility.add(:MOODY,
  proc { |ability,battler,battle|
    randomUp = []; randomDown = []
    PBStats.eachBattleStat do |s|
      randomUp.push(s) if battler.pbCanRaiseStatStage?(s,battler)
      randomDown.push(s) if battler.pbCanLowerStatStage?(s,battler)
    end
    next if randomUp.length==0 && randomDown.length==0
    battle.pbShowAbilitySplash(battler)
    if randomUp.length>0
      r = battle.pbRandom(randomUp.length)
      battler.pbRaiseStatStageByAbility(randomUp[r],2,battler,false)
      randomDown.delete(randomUp[r])
    end
    if randomDown.length>0
      r = battle.pbRandom(randomDown.length)
      battler.pbLowerStatStageByAbility(randomDown[r],1,battler,false)
    end
    battle.pbHideAbilitySplash(battler)
    battler.pbItemStatRestoreCheck if randomDown.length>0
  }
)

BattleHandlers::EOREffectAbility.add(:SPEEDBOOST,
  proc { |ability,battler,battle|
    # A Pokémon's turnCount is 0 if it became active after the beginning of a
    # round
    if battler.turnCount>0 && battler.pbCanRaiseStatStage?(PBStats::SPEED,battler)
      battler.pbRaiseStatStageByAbility(PBStats::SPEED,1,battler)
    end
  }
)

#===============================================================================
# EORGainItemAbility handlers
#===============================================================================

BattleHandlers::EORGainItemAbility.add(:HARVEST,
  proc { |ability,battler,battle|
    next if battler.item>0
    next if battler.recycleItem<=0 || !pbIsBerry?(battler.recycleItem)
    weather = battle.pbWeather
    if weather!=PBWeather::Sun && weather!=PBWeather::HarshSun
      next unless battle.pbRandom(100)<50
    end
    battle.pbShowAbilitySplash(battler)
    battler.item = battler.recycleItem
    battler.setRecycleItem(0)
    battler.setInitialItem(battler.item) if battler.initialItem==0
    battle.pbDisplay(_INTL("{1} harvested one {2}!",battler.pbThis,battler.itemName))
    battle.pbHideAbilitySplash(battler)
    battler.pbHeldItemTriggerCheck
  }
)

BattleHandlers::EORGainItemAbility.add(:PICKUP,
  proc { |ability,battler,battle|
    next if battler.item>0
    foundItem = 0; fromBattler = nil; use = 0
    battle.eachBattler do |b|
      next if b.index==battler.index
      next if b.effects[PBEffects::PickupUse]<=use
      foundItem   = b.effects[PBEffects::PickupItem]
      fromBattler = b
      use         = b.effects[PBEffects::PickupUse]
    end
    next if foundItem<=0
    battle.pbShowAbilitySplash(battler)
    battler.item = foundItem
    fromBattler.effects[PBEffects::PickupItem] = 0
    fromBattler.effects[PBEffects::PickupUse]  = 0
    fromBattler.setRecycleItem(0) if fromBattler.recycleItem==foundItem
    if battle.wildBattle? && battler.initialItem==0 && fromBattler.initialItem==foundItem
      battler.setInitialItem(foundItem)
      fromBattler.setInitialItem(0)
    end
    battle.pbDisplay(_INTL("{1} found one {2}!",battler.pbThis,battler.itemName))
    battle.pbHideAbilitySplash(battler)
    battler.pbHeldItemTriggerCheck
  }
)

#===============================================================================
# CertainSwitchingUserAbility handlers
#===============================================================================

# There aren't any!

#===============================================================================
# TrappingTargetAbility handlers
#===============================================================================

BattleHandlers::TrappingTargetAbility.add(:ARENATRAP,
  proc { |ability,switcher,bearer,battle|
    next true if !switcher.airborne?
  }
)

BattleHandlers::TrappingTargetAbility.add(:MAGNETPULL,
  proc { |ability,switcher,bearer,battle|
    next true if switcher.pbHasType?(:STEEL)
  }
)

BattleHandlers::TrappingTargetAbility.add(:SHADOWTAG,
  proc { |ability,switcher,bearer,battle|
    next true if !switcher.hasActiveAbility?(:SHADOWTAG)
  }
)

#===============================================================================
# AbilityOnSwitchIn handlers
#===============================================================================

BattleHandlers::AbilityOnSwitchIn.add(:AIRLOCK,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} has {2}!",battler.pbThis,battler.abilityName))
    end
    battle.pbDisplay(_INTL("The effects of the weather disappeared."))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.copy(:AIRLOCK,:CLOUDNINE)

BattleHandlers::AbilityOnSwitchIn.add(:ANTICIPATION,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    battlerTypes = battler.pbTypes(true)
    type1 = (battlerTypes.length>0) ? battlerTypes[0] : nil
    type2 = (battlerTypes.length>1) ? battlerTypes[1] : type1
    type3 = (battlerTypes.length>2) ? battlerTypes[2] : type2
    found = false
    battle.eachOtherSideBattler(battler.index) do |b|
      b.eachMove do |m|
        next if m.statusMove?
        moveData = pbGetMoveData(m.id)
        if type1
          moveType = moveData[MOVE_TYPE]
          if NEWEST_BATTLE_MECHANICS && isConst?(m.id,PBMoves,:HIDDENPOWER)
            moveType = pbHiddenPower(b.pokemon)[0]
          end
          eff = PBTypes.getCombinedEffectiveness(moveData[MOVE_TYPE],type1,type2,type3)
          next if PBTypes.ineffective?(eff)
          next if !PBTypes.superEffective?(eff) && moveData[MOVE_FUNCTION_CODE]!="070"   # OHKO
        else
          next if moveData[MOVE_FUNCTION_CODE]!="070"   # OHKO
        end
        found = true
        break
      end
      break if found
    end
    if found
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} shuddered with anticipation!",battler.pbThis))
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:AURABREAK,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} reversed all other Pokémon's auras!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:COMATOSE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is drowsing!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DARKAURA,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a dark aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:GAIAFORCE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a dark aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DUAT,
  proc { |ability,battler,battle|
    timeType = getConst(PBTypes,:TIME)
    battler.effects[PBEffects::Type3] = timeType
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is shrouded in the Duat !",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DELTASTREAM,
  proc { |ability,battler,battle|
    next if battle.field.weather == PBWeather::StrongWinds
    pbBattleWeatherAbility(PBWeather::StrongWinds,battler,battle,true)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DESOLATELAND,
  proc { |ability,battler,battle|
    next if battle.field.weather == PBWeather::HarshSun
    pbBattleWeatherAbility(PBWeather::HarshSun,battler,battle,true)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DOWNLOAD,
  proc { |ability,battler,battle|
    oDef = oSpDef = 0
    battle.eachOtherSideBattler(battler.index) do |b|
      oDef   += b.defense
      oSpDef += b.spdef
    end
    stat = (oDef<oSpDef) ? PBStats::ATTACK : PBStats::SPATK
    battler.pbRaiseStatStageByAbility(stat,1,battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DRIZZLE,
  proc { |ability,battler,battle|
    next if battle.field.weather == PBWeather::Rain
    pbBattleWeatherAbility(PBWeather::Rain,battler,battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DROUGHT,
  proc { |ability,battler,battle|
    next if battle.field.weather == PBWeather::Sun
    pbBattleWeatherAbility(PBWeather::Sun,battler,battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:EQUINOX,
  proc { |ability,battler,battle|
    next if battle.field.weather == PBWeather::Starstorm
    pbBattleWeatherAbility(PBWeather::Starstorm,battler,battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:NIGHTFALL,
  proc { |ability,battler,battle|
    next if battle.field.weather == PBWeather::Eclipse
    pbBattleWeatherAbility(PBWeather::Eclipse,battler,battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SHROUD,
  proc { |ability,battler,battle|
    next if battle.field.weather == PBWeather::Fog
    pbBattleWeatherAbility(PBWeather::Fog,battler,battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:HAILSTORM,
  proc { |ability,battler,battle|
    next if battle.field.weather == PBWeather::Sleet
    pbBattleWeatherAbility(PBWeather::Sleet,battler,battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ELECTRICSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain==PBBattleTerrains::Electric
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler,PBBattleTerrains::Electric)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FAIRYAURA,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a fairy aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FOREWARN,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    highestPower = 0
    forewarnMoves = []
    battle.eachOtherSideBattler(battler.index) do |b|
      b.eachMove do |m|
        moveData = pbGetMoveData(m.id)
        power = moveData[MOVE_BASE_DAMAGE]
        power = 160 if ["070"].include?(moveData[MOVE_FUNCTION_CODE])    # OHKO
        power = 150 if ["08B"].include?(moveData[MOVE_FUNCTION_CODE])    # Eruption
        # Counter, Mirror Coat, Metal Burst
        power = 120 if ["071","072","073"].include?(moveData[MOVE_FUNCTION_CODE])
        # Sonic Boom, Dragon Rage, Night Shade, Endeavor, Psywave,
        # Return, Frustration, Crush Grip, Gyro Ball, Hidden Power,
        # Natural Gift, Trump Card, Flail, Grass Knot
        power = 80 if ["06A","06B","06D","06E","06F",
                       "089","08A","08C","08D","090",
                       "096","097","098","09A"].include?(moveData[MOVE_FUNCTION_CODE])
        next if power<highestPower
        forewarnMoves = [] if power>highestPower
        forewarnMoves.push(m.id)
        highestPower = power
      end
    end
    if forewarnMoves.length>0
      battle.pbShowAbilitySplash(battler)
      forewarnMoveID = forewarnMoves[battle.pbRandom(forewarnMoves.length)]
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} was alerted to {2}!",
          battler.pbThis,PBMoves.getName(forewarnMoveID)))
      else
        battle.pbDisplay(_INTL("{1}'s Forewarn alerted it to {2}!",
          battler.pbThis,PBMoves.getName(forewarnMoveID)))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FRISK,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    foes = []
    battle.eachOtherSideBattler(battler.index) do |b|
      foes.push(b) if b.item>0
    end
    if foes.length>0
      battle.pbShowAbilitySplash(battler)
      if NEWEST_BATTLE_MECHANICS
        foes.each do |b|
          battle.pbDisplay(_INTL("{1} frisked {2} and found its {3}!",
             battler.pbThis,b.pbThis(true),PBItems.getName(b.item)))
        end
      else
        foe = foes[battle.pbRandom(foes.length)]
        battle.pbDisplay(_INTL("{1} frisked the foe and found one {2}!",
           battler.pbThis,PBItems.getName(foe.item)))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:GRASSYSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain==PBBattleTerrains::Grassy
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler,PBBattleTerrains::Grassy)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:IMPOSTER,
  proc { |ability,battler,battle|
    next if battler.effects[PBEffects::Transform]
    choice = battler.pbDirectOpposing
    next if choice.fainted?
    next if choice.effects[PBEffects::Transform] ||
            choice.effects[PBEffects::Illusion] ||
            choice.effects[PBEffects::Substitute]>0 ||
            choice.effects[PBEffects::SkyDrop]>=0 ||
            choice.semiInvulnerable?
    battle.pbShowAbilitySplash(battler,true)
    battle.pbHideAbilitySplash(battler)
    battle.pbAnimation(getConst(PBMoves,:TRANSFORM),battler,choice)
    battle.scene.pbChangePokemon(battler,choice.pokemon)
    battler.pbTransform(choice)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:INTIMIDATE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerAttackStatStageIntimidate(battler)
      b.pbItemOnIntimidatedCheck
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MINDGAMES,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerSpAtkStatStageMindGames(battler)
      b.pbItemOnIntimidatedCheck
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MEDUSOID,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerSpeedStatStageMedusoid(battler)
      b.pbItemOnIntimidatedCheck
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MISTYSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain==PBBattleTerrains::Misty
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler,PBBattleTerrains::Misty)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MOLDBREAKER,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} breaks the mold!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PRESSURE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is exerting its pressure!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PRIMORDIALSEA,
  proc { |ability,battler,battle|
    next if battle.field.weather == PBWeather::HeavyRain
    pbBattleWeatherAbility(PBWeather::HeavyRain,battler,battle,true)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PSYCHICSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain==PBBattleTerrains::Psychic
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler,PBBattleTerrains::Psychic)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SANDSTREAM,
  proc { |ability,battler,battle|
    next if battle.field.weather == PBWeather::Sandstorm
    pbBattleWeatherAbility(PBWeather::Sandstorm,battler,battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:GALEFORCE,
  proc { |ability,battler,battle|
    next if battle.field.weather == PBWeather::Windy
    pbBattleWeatherAbility(PBWeather::Windy,battler,battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PINDROP,
  proc { |ability,battler,battle|
    next if battle.field.weather == PBWeather::Reverb
    pbBattleWeatherAbility(PBWeather::Reverb,battler,battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:WORMHOLE,
  proc { |ability,battler,battle|
    next if battle.field.weather == PBWeather::TimeWarp
    pbBattleWeatherAbility(PBWeather::TimeWarp,battler,battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SLOWSTART,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.effects[PBEffects::SlowStart] = 5
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} can't get it going!",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} can't get it going because of its {2}!",
         battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SNOWWARNING,
  proc { |ability,battler,battle|
    next if battle.field.weather == PBWeather::Hail
    pbBattleWeatherAbility(PBWeather::Hail,battler,battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TERAVOLT,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a bursting aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TURBOBLAZE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a blazing aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DIMENSIONSHIFT,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    if battle.field.effects[PBEffects::TrickRoom] > 0
      battle.field.effects[PBEffects::TrickRoom] = 0
      battle.pbDisplay(_INTL("{1} reverted the dimensions!",battler.pbThis))
    end
    if battle.field.weather == PBWeather::TimeWarp
      battle.field.effects[PBEffects::TrickRoom] = 7
      battle.pbDisplay(_INTL("{1} twisted the dimensions!",battler.pbThis))
    else
      battle.field.effects[PBEffects::TrickRoom] = 5
      battle.pbDisplay(_INTL("{1} twisted the dimensions!",battler.pbThis))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CACOPHONY,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is creating an uproar!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:UNNERVE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is too nervous to eat Berries!",battler.pbOpposingTeam))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ASONEICE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} has 2 Abilities!",battler.name))
    battle.pbShowAbilitySplash(battler,false,true,PBAbilities.getName(getID(PBAbilities,:UNNERVE)))
    battle.pbDisplay(_INTL("{1} is too nervous to eat Berries!",battler.pbOpposingTeam))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.copy(:ASONEICE,:ASONEGHOST)

BattleHandlers::AbilityOnSwitchIn.add(:INTREPIDSWORD,
  proc { |ability,battler,battle|
    stat = PBStats::ATTACK
    battler.pbRaiseStatStageByAbility(stat,1,battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DAUNTLESSSHIELD,
  proc { |ability,battler,battle|
    stat = PBStats::DEFENSE
    battler.pbRaiseStatStageByAbility(stat,1,battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SCREENCLEANER,
  proc { |ability,battler,battle|
    target=battler
    battle.pbShowAbilitySplash(battler)
    if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0
      target.pbOwnSide.effects[PBEffects::AuroraVeil] = 0
      battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::LightScreen]>0
      target.pbOwnSide.effects[PBEffects::LightScreen] = 0
      battle.pbDisplay(_INTL("{1}'s Light Screen wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Reflect]>0
      target.pbOwnSide.effects[PBEffects::Reflect] = 0
      battle.pbDisplay(_INTL("{1}'s Reflect wore off!",target.pbTeam))
    end
    if target.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
      target.pbOpposingSide.effects[PBEffects::AuroraVeil] = 0
      battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!",target.pbOpposingTeam))
    end
    if target.pbOpposingSide.effects[PBEffects::LightScreen]>0
      target.pbOpposingSide.effects[PBEffects::LightScreen] = 0
      battle.pbDisplay(_INTL("{1}'s Light Screen wore off!",target.pbOpposingTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Reflect]>0
      target.pbOpposingSide.effects[PBEffects::Reflect] = 0
      battle.pbDisplay(_INTL("{1}'s Reflect wore off!",target.pbOpposingTeam))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PASTELVEIL,
  proc { |ability,battler,battle|
    battler.eachAlly do |b|
      next if b.status != PBStatuses::POISON
      battle.pbShowAbilitySplash(battler)
      b.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cured its {3}'s poison!",battler.pbThis,battler.abilityName,b.pbThis(true)))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CURIOUSMEDICINE,
  proc { |ability,battler,battle|
    done= false
    battler.eachAlly do |b|
      next if !b.hasAlteredStatStages?
      b.pbResetStatStages
      done = true
    end
    if done
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("All allies' stat changes were eliminated!"))
      battle.pbHideAbilitySplash(battler)
    end
  }
)
#===============================================================================
# AbilityOnSwitchOut handlers
#===============================================================================

BattleHandlers::AbilityOnSwitchOut.add(:NATURALCURE,
  proc { |ability,battler,endOfBattle|
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.status = PBStatuses::NONE
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:REGENERATOR,
  proc { |ability,battler,endOfBattle|
    next if endOfBattle || battler.fainted?
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.pbRecoverHP(battler.totalhp/3,false,false)
  }
)

#===============================================================================
# AbilityChangeOnBattlerFainting handlers
#===============================================================================

BattleHandlers::AbilityChangeOnBattlerFainting.add(:POWEROFALCHEMY,
  proc { |ability,battler,fainted,battle|
    next if battler.opposes?(fainted)
    abilityBlacklist = [
       # Replaces self with another ability
       :POWEROFALCHEMY,
       :RECEIVER,
       :TRACE,
       # Form-changing abilities
       :BATTLEBOND,
       :DISGUISE,
       :FLOWERGIFT,
       :FORECAST,
       :ACCLIMATE,
       :MULTITYPE,
       :POWERCONSTRUCT,
       :SCHOOLING,
       :SHIELDSDOWN,
       :STANCECHANGE,
       :ZENMODE,
       # Appearance-changing abilities
       :ILLUSION,
       :IMPOSTER,
       # Abilities intended to be inherent properties of a certain species
       :COMATOSE,
       :RKSSYSTEM,
       # Abilities that would be overpowered if allowed to be transferred
       :WONDERGUARD
    ]
    failed = false
    abilityBlacklist.each do |abil|
      next if !isConst?(fainted.ability,PBAbilities,abil)
      failed = true
      break
    end
    next if failed
    battle.pbShowAbilitySplash(battler,true)
    battler.ability = fainted.ability
    battle.pbReplaceAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1}'s {2} was taken over!",fainted.pbThis,fainted.abilityName))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityChangeOnBattlerFainting.copy(:POWEROFALCHEMY,:RECEIVER)

#===============================================================================
# AbilityOnBattlerFainting handlers
#===============================================================================

BattleHandlers::AbilityOnBattlerFainting.add(:SOULHEART,
  proc { |ability,battler,fainted,battle|
    battler.pbRaiseStatStageByAbility(PBStats::SPATK,1,battler)
  }
)

#===============================================================================
# RunFromBattleAbility handlers
#===============================================================================

BattleHandlers::RunFromBattleAbility.add(:RUNAWAY,
  proc { |ability,battler|
    next true
  }
)
