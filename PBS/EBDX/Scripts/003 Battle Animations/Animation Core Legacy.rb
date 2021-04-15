#===============================================================================
#  Legacy animation player compatibility
#===============================================================================
class PBAnimationPlayerX
  #-----------------------------------------------------------------------------
  #  determine which battler and which type of focus to apply based on animation
  #-----------------------------------------------------------------------------
  def getFocus
    return 1 if @frame < 0
    pattern = 1
    if (@frame&1) == 0
      thisframe = @animation[@frame>>1]
      # Set each cel sprite acoordingly
      for i in 0...thisframe.length
        cel = thisframe[i]; next if !cel
        sprite = @animsprites[i]; next if !sprite
        focus = cel[AnimFrame::FOCUS]
      end
      return [pattern, focus].max
    end
    return 1
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Fix zooming issues with legacy animations (back sprite)
#===============================================================================
alias pbSpriteSetAnimFrame_ebdx pbSpriteSetAnimFrame unless defined?(pbSpriteSetAnimFrame_ebdx)
def pbSpriteSetAnimFrame(sprite, frame, user = nil, target = nil, inEditor = false)
  return if !sprite
  pbSpriteSetAnimFrame_ebdx(sprite, frame, user, target, inEditor)
  if !inEditor && sprite.respond_to?(:index) && sprite.index%2 == 0
    sprite.zoom_x *= 2*@scene.vector.zoom2
    sprite.zoom_y *= 2*@scene.vector.zoom2
  end
end
#===============================================================================
#  Legacy animation player core
#===============================================================================
class PokeBattle_Scene
  attr_accessor :animationCount
  #-----------------------------------------------------------------------------
  #  core animation processing for legacy animations
  #-----------------------------------------------------------------------------
  def pbAnimationCore(animation, user, target, oppMove = false)
    return if !animation
    @briefMessage = false
    # clear message window and hide databoxes
    clearMessageWindow
    # store databox visibility
    pbHideAllDataboxes
    # get the battler sprites
    userSprite   = (user) ? @sprites["pokemon_#{user.index}"] : nil
    targetSprite = (target) ? @sprites["pokemon_#{target.index}"] : nil
    # Remember the original positions of Pokémon sprites
    oldUserX = (userSprite) ? userSprite.x : 0
    oldUserY = (userSprite) ? userSprite.y : 0
    oldTargetX = (targetSprite) ? targetSprite.x : oldUserX
    oldTargetY = (targetSprite) ? targetSprite.y : oldUserY
    # Create the animation player
    animPlayer = PBAnimationPlayerX.new(animation,user,target,self,oppMove)
    # Apply a transformation to the animation based on where the user and target
    # actually are. Get the centres of each sprite.
    userHeight = (userSprite && userSprite.bitmap && !userSprite.bitmap.disposed?) ? userSprite.bitmap.height : 128
    if targetSprite
      targetHeight = (targetSprite.bitmap && !targetSprite.bitmap.disposed?) ? targetSprite.bitmap.height : 128
    else
      targetHeight = userHeight
    end
    animPlayer.setLineTransform(
       PokeBattle_SceneConstants::FOCUSUSER_X, PokeBattle_SceneConstants::FOCUSUSER_Y,
       PokeBattle_SceneConstants::FOCUSTARGET_X, PokeBattle_SceneConstants::FOCUSTARGET_Y,
       oldUserX, oldUserY - userHeight/2,
       oldTargetX, oldTargetY - targetHeight/2)
    # Play the animation
    @sprites["battlebg"].defocus
    animPlayer.start
    loop do
      # update necessary components
      animPlayer.update
      pbGraphicsUpdate
      pbInputUpdate
      animateScene
      # finish with the animation player
      break if animPlayer.animDone?
    end
    animPlayer.dispose
    @sprites["battlebg"].focus
    # Return Pokémon sprites to their original positions
    if userSprite
      userSprite.x = oldUserX
      userSprite.y = oldUserY
      userSprite.pbSetOrigin
    end
    if targetSprite
      targetSprite.x = oldTargetX
      targetSprite.y = oldTargetY
      targetSprite.pbSetOrigin
    end
    # reset databox visibility
    pbShowAllDataboxes
  end
  #-----------------------------------------------------------------------------
  #  get choice details for moves
  #-----------------------------------------------------------------------------
  def pbGetMoveChoice(moveID, target = -1, idxMove = -1, specialUsage = true)
    choice = []
    choice[0] = :UseMove   # "Use move"
    choice[1] = idxMove    # Index of move to be used in user's moveset
    if idxMove >= 0
      choice[2] = @moves[idxMove]
    else
      choice[2] = PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(moveID))   # PokeBattle_Move object
      choice[2].pp = -1
    end
    choice[3] = target     # Target (-1 means no target yet)
    return choice
  end
  #-----------------------------------------------------------------------------
  #  Main animation handling core
  #-----------------------------------------------------------------------------
  def pbAnimation(moveid, user, targets, hitnum = 0)
    # for hitnum, 1 is the charging animation, 0 is the damage animation
    return if !moveid
    # move information
    species = @battle.battlers[user.index].species
    movedata = EBMoveData.new(moveid)
    move = PokeBattle_Move.pbFromPBMove(@battle, PBMove.new(moveid))
    numhits = user.thisMoveHits
    multihit = !numhits.nil? ? (numhits > @animationCount) : false
    @animationCount += 1
    if numhits.nil?
      @animationCount = 1
    elsif @animationCount > numhits
      @animationCount = 1
    end
    multitarget = false
    multitarget = move.target if (move.target == PBTargets::AllFoes || move.target == PBTargets::AllNearFoes)
    target = (targets && targets.is_a?(Array)) ? targets[0] : targets
    target = user if !target
    # clears the current UI
    clearMessageWindow
    pbHideAllDataboxes
    # Substitute animation
    if @sprites["pokemon_#{user.index}"] && @battle.battlescene
      subbed = @sprites["pokemon_#{user.index}"].isSub
      self.setSubstitute(user.index, false) if subbed
    end
    # gets move animation def name
    handled = false
    if @battle.battlescene
      @sprites["battlebg"].defocus
      # checks if def for specific move exists, and then plays it
      handled = EliteBattle.playMoveAnimation(moveid, self, user.index, target.index, hitnum, multihit, species) if !handled
      # in case people want to use the old animation player
      if REPLACE_MISSING_ANIM && !handled
        animid = pbFindMoveAnimation(moveid, user.index, hitnum)
        return if !animid
        anim = animid[0]
        animations = EliteBattle.get(:moveAnimations)
        name = PBMoves.getName(moveid)
        pbSaveShadows {
           if animid[1] # On opposing side and using OppMove animation
             pbAnimationCore(animations[anim], target, user, true)
           else         # On player's side, and/or using Move animation
             pbAnimationCore(animations[anim], user, target, false)
           end
        }
        handled = true
      end
      # decides which global move animation to play, if any
      if !handled
        handled = EliteBattle.mapMoveGlobal(self, move.type, user.index, target.index, hitnum, multihit, multitarget, movedata.category)
      end
      # if all above failed, plays the move animation for Tackle
      if !handled
        EliteBattle.playMoveAnimation(:TACKLE, self, user.index, target.index, 0, multihit)
      end
      @sprites["battlebg"].focus
    end
    # Change form to transformed version
    if EBMoveData.new(moveid).function == 0x69 && user && target # Transform
      pbChangePokemon(user, target.pokemon)
    end
    # restores cleared UI
    pbShowAllDataboxes
    self.afterAnim = true
  end
  #-----------------------------------------------------------------------------
end
