--- STEAMODDED HEADER
--- MOD_NAME: Jester's Privilege
--- MOD_ID: JestersPrivilege
--- MOD_AUTHOR: [unethikeele]
--- MOD_DESCRIPTION: Adds some joker ideas I had that hopefully fit in the Vanilla theme.
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0812d]
--- PREFIX: JP
----------------------------------------------
------------MOD CODE -------------------------


SMODS.Atlas {
  key = "JestersPrivilegeAtlas",
  path = "JestersPrivilegeAtlas.png",
  px = 71,
  py = 95
}

-- Bobo
SMODS.Joker {
  key = 'JPBobodoll',
  loc_txt = {
    name = 'Bobo Doll',
    text = {
      "This Joker gains {C:chips}#2#{} Chips", 
      "if played hand is the same",
      "as previously played hand.", 
      "{C:inactive}Currently {C:chips}#1#{} {C:inactive}Chips" 
    }
  },
  config = { extra = { chips = 0, chips_gain = 10, last_hand_played = nil} },
  rarity = 1,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 3, y = 0 },
  cost = 4,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,

  loc_vars = function(self, info_queue, card)
    return { vars = {card.ability.extra.chips, card.ability.extra.chips_gain, card.ability.extra.last_hand_played } }
  end,

  calculate = function(self, card, context)
    if context.joker_main then
        return {
            chips_gain = card.ability.extra.chips,
            message = localize {type = 'variable', key = 'a_chips', vars = {card.ability.extra.chips}}
         }
    end
    if context.cardarea == G.jokers then
        local hand = context.scoring_name
        if context.before then
            if hand == card.ability.extra.last_hand_played then
                if not context.blueprint then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_gain
                    return {
                      message = "Upgraded!",
                      colour = G.C.CHIPS,
                      card = card
                    }
                end
            end
        elseif context.after and not context.blueprint then
            card.ability.extra.last_hand_played = hand
        end
    end
  end
}

-- Draw Four
SMODS.Joker { 
  key = "JPD4", 
  loc_txt = {
    name = 'Draw Four',
    text = {
      "Gain {C:mult}+#2# Mult{} for",
      "each {C:attention}Wild Card{} played",
      "Currently {C:mult}+#1#{}"
    }
  },
  config = { extra = {mult = 0, mult_gain = 4} },
  rarity = 1,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 0, y = 2 },
  cost = 5,
  unlocked = true,
  discovered = true, -- change later
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  loc_vars = function(self, info_queue, card)
    return { 
        vars = {card.ability.extra.mult, card.ability.extra.mult_gain} 
    } 
  end,

  calculate = function(self, card, context)
        if context.joker_main and not context.blueprint then
            return {
                mult_mod = card.ability.extra.mult,
                message = localize {type = 'variable', key = 'a_mult', vars = {card.ability.extra.mult}}
            }
        end
       if context.individual and context.cardarea == G.play then
            if context.other_card.ability.name == "Wild Card" then
                card.ability.extra.mult = card.ability.extra.mult + 4
                  return {
                    extra = {focus = card, message = localize('k_upgrade_ex'), colour = G.C.MULT},
                    colour = G.C.MULT,
                    card = card
                  }
                end
            end
        end
}

-- Gorgon
SMODS.Joker {
  key = "JPmedusa",
  loc_txt = {
    name = 'Gorgon',
    text = {
      "All played face cards", 
      "become {C:attention}Stone{}",
      "cards when scored"
    },
    unlock = {
        "Defeat the {C:attention}Medusa{} Challenge"
    }
  },
  config = { },
  rarity = 1,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 3, y = 1 },
  cost = 7,
  unlocked = false,
  discovered = false,
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_medusa_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = {}}
  end,
  calculate = function(self, card, context)
		if not context.blueprint and context.scoring_hand then
            local faces = {}
                        for k, v in ipairs(context.scoring_hand) do
                            if v:is_face() then 
                                faces[#faces+1] = v
                                v:set_ability(G.P_CENTERS.m_stone, nil, true)
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        card:juice_up()
                                        return true
                                    end
                                })) 
                            end
                        end
                        if #faces > 0 then 
                            return {
                                message = "Stoned",
                                colour = G.C.CHIPS,
                                card = self
                            }
                        end
            end
		end
}

-- Hermit
SMODS.Joker {
  key = '',
  loc_txt = {
    name = 'Hermit Crab',
    text = {
      "When {C:attention}Blind{} is selected", 
      "{C:green}#1# in #2#{} chance to create", 
      "a {C:tarot}Hermit{} card", 
      "{C:inactive}(Must have room)"
    },
    unlock = {"Defeat the {C:attention}Rich get Richer{} Challenge"}
  },
  config = { extra = {odds = 6} },
  rarity = 1,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 1, y = 1 },
  cost = 7,
  unlocked = false,
  discovered = false,
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_rich_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
   loc_vars = function(self, info_queue, card)
    return {
      vars = {G.GAME.probabilities.normal, card.ability.extra.odds}
    }
  end,

  calculate = function(self, card, context)
    if context.setting_blind then
            if pseudorandom('Hermit') < G.GAME.probabilities.normal / card.ability.extra.odds then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
              trigger = 'before',
              delay = 0.0,
              func = (function()
                  local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, 'c_hermit', 'sup')
                  card:add_to_deck()
                  G.consumeables:emplace(card)
                  G.GAME.consumeable_buffer = 0
                return true
              end)}))
        end
    end
  end
}

-- Metro
SMODS.Joker {
  key = "JPMetro", 
  loc_txt = {
    name = 'Metro Card',
    text = {
      "Gain {C:mult}+3 Mult{} if ",
      "played hand is {C:attention}#3#{}",
      "Currently {C:mult}+#1#{}",
      "{C:inactive}(Hand changes", 
      "{C:inactive}each time played){}"
    },
    unlock = {"Defeat the {C:attention}15 Minute City{} Challenge"},
  },
  config = { extra = {mult = 0, mult_gain = 3, poker_hand = "High Card"} },
  rarity = 1,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 0, y = 1 },
  cost = 5,
  unlocked = false,
  discovered = false, -- change later
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_xray_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  loc_vars = function(self, info_queue, card)
    return { 
        vars = {card.ability.extra.mult, card.ability.extra.mult_gain, card.ability.extra.poker_hand} 
    } 
  end,

  calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult_mod = card.ability.extra.mult,
                message = localize {type = 'variable', key = 'a_mult', vars = {card.ability.extra.mult}}
            }
        end
        if context.before and context.scoring_name == card.ability.extra.poker_hand then
            G.E_MANAGER:add_event(Event({
                    func = function()
                        local _poker_hands = {}
                        for k, v in pairs(G.GAME.hands) do
                            if v.visible and k ~= card.ability.to_do_poker_hand then _poker_hands[#_poker_hands + 1] = k end
                        end
                        card.ability.extra.poker_hand = pseudorandom_element(_poker_hands, pseudoseed('to_do'))
                        return true
                    end
            }))
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
                  return {
                      message = "Upgraded!",
                      colour = G.C.MULT,
                      card = card
                  }
        end
  end
}

-- Nosferatu
SMODS.Joker {
  key = "JPNosfy",
  loc_txt = {
    name = 'Nosferatu',
    text = {
      "All played cards", 
      "become {C:attention}Mult{}",
      "cards after scoring",
    },
    unlock = {"Defeat the {C:attention}Bram Poker{} Challenge"},
  },
  config = { },
  rarity = 2,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 4, y = 1 },
  cost = 7,
  unlocked = false,
  discovered = false,
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_bram_poker_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = {}}
  end,
  calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.scoring_hand then
                if context.other_card.ability.name == 'Mult' then
                    return nil
                end
                context.other_card:set_ability(G.P_CENTERS.m_mult, nil, true)
            end
		end
  end
}

-- Receipt
SMODS.Joker {
  key = 'JPReceipt', 
  loc_txt = {
    name = 'Receipt',
    text = {
      "The {C:attention}sell value{} of this Joker", 
      "is equal to the {C:attention}sell value{}",
      "of all other {C:attention}Jokers{} combined"
    },
    unlock = {"Defeat the {C:attention}Inflation{} Challenge"},
  },
  rarity = 1,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 4, y = 2 },
  cost = 5,
  unlocked = false,
  discovered = false,
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_inflation_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = {card.ability.extra_value}}
    end,

  update = function(self, card, context)
    if not G.jokers then return end
        local sell_cost = 0
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] ~= card and (G.jokers.cards[i].area and G.jokers.cards[i].area == G.jokers) then
                    sell_cost = sell_cost + G.jokers.cards[i].sell_cost
                end
            end
        card.ability.extra_value = sell_cost
        card:set_cost()
  end
}

-- Breakout
SMODS.Joker {
  key = 'JPBreakout',
  loc_txt = {
    name = 'Breakout Role',
    text = {
      "After {C:attention}#2#{} rounds,",
      "this card has",
      "{X:mult,C:white}X#3#{}",
      "{C:inactive}(Currently {C:attention}#1#{C:inactive}/#2#)"
    },
    unlock = {"Defeat the {C:attention}Typecast{} Challenge"},
  },
  config = { extra = { c_rounds = 0, rounds = 10, x_mult = 4} },
  rarity = 2,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 1, y = 2 },
  cost = 7,
  unlocked = false,
  discovered = false,
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_typecast_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,


  loc_vars = function(self, info_queue, card)
    return { vars = {card.ability.extra.c_rounds, card.ability.extra.rounds, card.ability.extra.x_mult} }
  end,

  calculate = function(self, card, context)
   if context.end_of_round and not context.individual and not context.repetition  and not context.blueprint then
      card.ability.extra.c_rounds = card.ability.extra.c_rounds + 1
      if card.ability.extra.c_rounds >= card.ability.extra.rounds and (card.ability.extra.c_rounds - 1) < card.ability.extra.rounds then 
        local eval = function(card) return not card.REMOVED end
        juice_card_until(card, eval, true)
      end
    end
    if context.joker_main and (card.ability.extra.c_rounds >= card.ability.extra.rounds) and not context.blueprint then
         return {
        message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}},
        Xmult_mod = card.ability.extra.x_mult,
      }
    end
  end
}

-- Buzzer Beater
SMODS.Joker {
  key = 'JPbuzzerbeater',
  loc_txt = {
    name = 'Buzzer Beater',
    text = {
      "Defeating the ante", 
      "on the last hand", 
      "increases by {X:mult,C:white}X#2#{}", 
      "{C:inactive}Currently {X:mult,C:white}X#1#{} {C:inactive}Mult"
    }
  },
  config = { extra = { x_mult = 1, x_mult_gain = 0.5 } },
  rarity = 2,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 0, y = 0 },
  cost = 6,
  unlocked = true,
  discovered = false,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,


  loc_vars = function(self, info_queue, card)
    return { vars = {card.ability.extra.x_mult, card.ability.extra.x_mult_gain } }
  end,

  calculate = function(self, card, context)
    if context.joker_main and not context.blueprint and context.cardarea == G.jokers then
        if G.GAME.blind.boss and G.GAME.current_round.hands_left == 0 then
            card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain
            G.E_MANAGER:add_event(Event({
                func = function()
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')}); return true
                    end
            }))
            end
            return {
                message = localize {type = 'variable', key = 'a_xmult', vars = {card.ability.extra.x_mult} },
                Xmult_mod = card.ability.extra.x_mult
        }
     end
  end
}

-- Countdown
SMODS.Joker { -- shout out to snoresvilleturbulentjokers pi joker
  key = 'JPCountdown', 
  loc_txt = {
    name = 'Countdown',
    text = {
      "This Joker gains {X:mult,C:white}X#1#{} Mult",
      "every time a scored card's rank",
      "matches the next rank of the countdown",
      "Next ranks are: {C:attention}#3#, #4#, #5#, #6#, #7#{}",
      "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)"
    },
    unlock = {"Defeat the {C:attention}Blast Off{} Challenge"},
  },
  config = { extra = 
  { x_mult = 1, 
  x_mult_gain = 0.1,
  countdown_index = 0 } },
  rarity = 2,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 3, y = 2 },
  cost = 7,
  unlocked = false,
  discovered = false,
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_blast_off_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,

  loc_vars = function(self, info_queue, card)
  local countdown = "098765432109876543210987654321098765432109876543210987654321098765432109876543210987654321098765432109876543210987654321098765432109876543210987654321098765432109876543210987654321"
  local function get_countdown_at_index(i)
    local digit = countdown:sub(i % #countdown +1, i % #countdown +1)
    return (digit == "0" and "10")
    or (digit ==  "1" and "Ace")
    or digit
    end
    return { vars = {card.ability.extra.x_mult_gain, card.ability.extra.x_mult + card.ability.extra.x_mult_gain * card.ability.extra.countdown_index,
                     get_countdown_at_index(card.ability.extra.countdown_index + 0),
                     get_countdown_at_index(card.ability.extra.countdown_index + 1),
                     get_countdown_at_index(card.ability.extra.countdown_index + 2),
                     get_countdown_at_index(card.ability.extra.countdown_index + 3),
                     get_countdown_at_index(card.ability.extra.countdown_index + 4),
    } }
  end,

  calculate = function(self, card, context)
    if context.cardarea == G.play and context.individual and not context.blueprint then
        local other_card = context.other_card

        local countdown = "098765432109876543210987654321098765432109876543210987654321098765432109876543210987654321098765432109876543210987654321098765432109876543210987654321098765432109876543210987654321"
          local function get_countdown_at_index(i)
            local digit = countdown:sub(i % #countdown +1, i % #countdown +1)
            return (digit == "0" and "10")
            or (digit ==  "1" and "Ace")
            or digit
            end

            local card_rank = (other_card.base.value == "10" and "0")
            or (other_card.base.value == "Ace" and "1")
            or other_card.base.value
            local next_number = countdown:sub(card.ability.extra.countdown_index % #countdown + 1, card.ability.extra.countdown_index % #countdown + 1)

            if card_rank == next_number then
                card.ability.extra.countdown_index = card.ability.extra.countdown_index + 1
                return {
                    extra = {focus = card, message = localize('k_upgrade_ex'), colour = G.C.MULT},
                    colour = G.C.MULT,
                    card = card
                }
            end
    end
    if context.joker_main and not context.blueprint then
        if card.ability.extra.countdown_index > 0 then
            local x_mult = 1
            local x_mult_gain = 0.1
            return {
                Xmult_mod = x_mult + x_mult_gain * card.ability.extra.countdown_index,
                message = localize {
                type = 'variable', key = 'a_xmult',vars = { x_mult + x_mult_gain * card.ability.extra.countdown_index} }
            }
        end
    end
end
}

-- Dredd
SMODS.Joker {
  key = 'JPDredd',
  loc_txt = {
    name = 'Dredd Joker',
    text = {
      "When {C:attention}Blind{} is selected", 
      "{C:green}#1# in #2#{} chance to create", 
      "a {C:tarot}Judgement{}, {C:tarot}Justice{}", 
      "or {C:tarot}Hanged Man{}", 
      "{C:inactive}(Must have room)"
    }
  },
  config = { extra = {odds = 4} },
  rarity = 2,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 2, y = 0 },
  cost = 4,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
   loc_vars = function(self, info_queue, card)
    return {
      vars = {G.GAME.probabilities.normal, card.ability.extra.odds}
    }
  end,

  calculate = function(self, card, context)
    if context.setting_blind then
            if pseudorandom('DREDD') < G.GAME.probabilities.normal / card.ability.extra.odds then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
              trigger = 'before',
              delay = 0.0,
              func = (function()
                  local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, 'c_judgement', 'c_justice', 'c_hanged_man', 'sup')
                  card:add_to_deck()
                  G.consumeables:emplace(card)
                  G.GAME.consumeable_buffer = 0
                return true
              end)}))
        end
    end
  end
}

-- Familiar
SMODS.Joker {
  key = "JPFamiliar Faces",
  loc_txt = {
    name = 'Familiar Faces',
    text = {
      "{C:green}#1# in #2#{} chance to create",
      "a {C:spectral}Familiar{} card",
    },
    unlock = {"Defeat the {C:attention}Mad World{} Challenge"},
  },
  config = { extra = {odds = 4} },
  rarity = 2,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 2, y = 1 },
  cost = 6,
  unlocked = false,
  discovered = false,
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_mad_world_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = {G.GAME.probabilities.normal, card.ability.extra.odds}}
  end,
  calculate = function(self, card, context)
		if context.ending_shop and not context.blueprint then
				if pseudorandom('Gary Jules') < G.GAME.probabilities.normal / card.ability.extra.odds then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                      trigger = 'before',
                      delay = 0.0,
                      func = (function()
                          local card = create_card('Spectral',G.consumeables, nil, nil, nil, nil, 'c_familiar', 'sup')
                          card:add_to_deck()
                          G.consumeables:emplace(card)
                          G.GAME.consumeable_buffer = 0
                        return true
                        end)}))
		        end
		end
	end
}

-- Seal
SMODS.Joker {
  key = 'JPSeal', -- idk how but it started working
  loc_txt = {
    name = 'Seal of Approval',
    text = {
      "Gain {X:mult,C:white}X#2#{} for every", 
      "card in deck with a {C:attention}Seal", 
      "{C:inactive}Currently {X:mult,C:white}X#1#{} {C:inactive}Mult"
    },
    unlock = {"Defeat the {C:attention}Double or Nothing{} Challenge"},
  },
  config = { extra = 
  { x_mult = 1, 
  x_mult_gain = 0.5 } },
  rarity = 2,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 2, y = 2 },
  cost = 7,
  unlocked = false,
  discovered = false,
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_double_nothing_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,


  loc_vars = function(self, info_queue, card)
    return { vars = {card.ability.extra.x_mult, card.ability.extra.x_mult_gain } }
  end,

  calculate = function(self, card, context)
      if context.joker_main and not context.blueprint and context.cardarea == G.jokers then
                return {
                    message = localize {type = 'variable', key = 'a_xmult', vars = {card.ability.extra.x_mult} },
                    Xmult_mod = card.ability.extra.x_mult
                    }
      end
  end,
  update = function(self, card, dt)
        if G.STAGE == G.STAGES.RUN then
             card.ability.extra.x_mult = 1
             for _, v in pairs(G.playing_cards) do
                    if v.seal ~= nil then
                    card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain
                    end
             end
        end
   end
}

-- Microtransaction -- fixed by Saydyrya90 thanks slime
SMODS.Joker { 
  key = 'JPMicrotransaction',
  loc_txt = {
    name = 'Microtransaction',
    text = {
      "Every item purchased", "from the shop adds", "{X:mult,C:white}X#2#{} to this card", "{C:inactive}Currently {X:mult,C:white}X#1#{} {C:inactive}Mult"
    }
  },
  config = { extra = { x_mult = 1, x_mult_gain = 0.05, seen = {} } },
  rarity = 3,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 1, y = 0 },
  cost = 6,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,

  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.x_mult, card.ability.extra.x_mult_gain } }
  end,

  calculate = function(self, card, context)
    -- Apply X mult during scoring
    if context.joker_main and card.ability.extra.x_mult > 1 then
      return {
        message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}},
        Xmult_mod = card.ability.extra.x_mult,
        colour = G.C.MULT,
      }
    end

    -- Increment on unique purchases or booster pack opens
    if (context.buying_card or context.open_booster) and not context.blueprint then
      local purchase_key
      if context.buying_card then
        purchase_key = context.card.label or context.card.config.center.key
      elseif context.open_booster then
        purchase_key = context.card.config.center.key
      end
      
      if purchase_key and not card.ability.extra.seen[purchase_key] then
        card.ability.extra.seen[purchase_key] = true
        card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain
        
        return {
          message = localize('k_upgrade_ex'),
        }
      end
    end
  end
}

-- Neon
SMODS.Joker {
  key = "Neon",
  loc_txt = {
    name = 'Neon Joker',
    text = {
      "All scored {C:attention}Glass{} Cards ","are given {C:dark_edition}Polychrome{}"
    }
  },
  config = { extra = {} },
  rarity = 3,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 4, y = 0 },
  cost = 5,
  unlocked = true,
  discovered = true, -- change later
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  loc_vars = function(self, info_queue, center)
    return { vars = {} } 
  end,
  calculate = function(self, card, context)
		if context.cardarea == G.jokers and context.before and not context.blueprint then 
				local faces = {}
				for k, v in ipairs(context.scoring_hand) do
					if v.ability.effect == "Glass Card" and not (v.edition and v.edition.polychrome) then
						faces[#faces+1] = v
						v:set_edition({polychrome = true}, nil,true)
						G.E_MANAGER:add_event(Event({
							func = function()
								v:juice_up()
								return true
							end
						})) 
				end
			end
            if #faces > 0 then 
				return {
					message = "Neon",
					colour = G.C.CHIPS,
					card = self
				}
			end
		end
	end
}

-- Money Laundering
SMODS.Joker {
  key = 'JPMoneyLaundering',
  loc_txt = {
    name = 'Money Laundering',
    text = {
      "Gain {C:attention}1{} extra hand size", 
      "for every {C:money}$20{} you have", 
      "{C:inactive}Currently {C:attention}+#2#{} hand size"
    },
    unlock = {"Defeat the {C:attention}Luxury Tax{} Challenge"},
  },
  config = { extra = { perDollar = 20, handSize = 0} },
  rarity = 3,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 1, y = 4 },
  cost = 9,
  unlocked = false,
  discovered = false,
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_luxury_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,


  loc_vars = function(self, info_queue, center)
    return { vars = {center.ability.extra.perDollar, center.ability.extra.handSize} }
  end,

  calculate = function(self, card, context)
    if context.first_hand_drawn and not context.blueprint then
        local handmax = card.ability.extra.handSize
			card.ability.extra.handSize = math.max(0, math.min(math.floor((G.GAME.dollars) / card.ability.extra.perDollar)))
			if card.ability.extra.handSize ~= handmax then
				G.hand:change_size(card.ability.extra.handSize - handmax)
			end
		end
	end
}

-- Minimize
SMODS.Joker {
  key = 'JPminimize',
  loc_txt = {
    name = 'Minimize',
    text = {
      "Gain {X:mult,C:white}X#2#{} for every", 
      "hand size below {C:attention}8{}", 
      "{C:inactive}Currently {X:mult,C:white}X#1#{} {C:inactive}Mult"
    },
    unlock = {"Defeat the {C:attention}Five-Card Draw{} Challenge"},
  },
  config = { extra = { x_mult = 1, x_mult_gain = 1 } },
  rarity = 3,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 0, y = 5 },
  cost = 6,
  unlocked = false,
  discovered = false,
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_five_card_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,


  loc_vars = function(self, info_queue, card)
    return { vars = {card.ability.extra.x_mult, card.ability.extra.x_mult_gain } }
  end,

  calculate = function(self, card, context)
    if context.first_hand_drawn and not context.blueprint then
        local handcalc = 8 - #G.hand.cards
        if handcalc > 0 then
            card.ability.extra.x_mult = card.ability.extra.x_mult + (card.ability.extra.x_mult_gain * handcalc)
            end
            return {
                message = localize {type = 'variable', key = 'a_xmult', vars = {card.ability.extra.x_mult} },
                Xmult_mod = card.ability.extra.x_mult
        }
     end
  end
}

-- Wall Hack 
SMODS.Joker { 
  key = "JPWallhack", 
  loc_txt = {
    name = 'Wallhacks',
    text = {
      "Flips and shuffles all",
      "Joker cards. All {C:attention}scored{}",
      "cards are retriggered"
    },
    unlock = {"Defeat the {C:attention}X-Ray{} Challenge"},
  },
  config = { extra = { repetition = 1} },
  rarity = 1,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 0, y = 3 },
  cost = 5,
  unlocked = false,
  discovered = false,
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_xray_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  loc_vars = function(self, info_queue, card)
    return { 
        vars = {card.ability.extra.repetition} 
    } 
  end,

  calculate = function(self, card, context) 
    if context.setting_blind then
        if #G.jokers.cards > 0 then
            G.jokers:unhighlight_all()
            for k, v in ipairs(G.jokers.cards) do
                v:flip()
            end
            if #G.jokers.cards > 1 then 
                    G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.2, func = function() 
                        G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('aajk'); play_sound('cardSlide1', 0.85);return true end })) 
                        delay(0.15)
                        G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('aajk'); play_sound('cardSlide1', 1.15);return true end })) 
                        delay(0.15)
                        G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('aajk'); play_sound('cardSlide1', 1);return true end })) 
                        delay(0.5)
                    return true end })) 
            end
        end
    end
    if context.repetition and context.cardarea == G.play then
        return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra.repetition,
                    card = card
                }
    end
    if context.end_of_round and context.cardarea == G.jokers then
        if #G.jokers.cards > 0 then
            G.jokers:unhighlight_all()
            for k, v in ipairs(G.jokers.cards) do
                v:flip()
            end
        end
    end
  end
}

-- Fried
SMODS.Joker {
  key = 'JPFried',
  loc_txt = {
    name = 'Fried',
    text = {
      "At the end of the round",
      "Earn $1 for each {C:attention}Joker{} card",  
      "{C:inactive}Currently {C:money}$#1#{}"
    },
    unlock = {"Defeat {C:attention}The Omelette{} Challenge"},
  },
  config = { extra = { dollar_bonus = 0 } },
  rarity = 2,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 1, y = 3 },
  cost = 6,
  unlocked = false,
  discovered = false,
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_omelette_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,


  loc_vars = function(self, info_queue, card)
    return { vars = {card.ability.extra.dollar_bonus} }
  end,

  calculate = function(self, card, context)
    if context.end_of_round and not context.blueprint then
        card.ability.extra.dollar_bonus = 0
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].ability.set == 'Joker' then card.ability.extra.dollar_bonus = card.ability.extra.dollar_bonus + 1 end
        end
    end
    end,
    calc_dollar_bonus = function(self, card)
            local dollar_bonus = card.ability.extra.dollar_bonus

            return dollar_bonus
    end
}

-- Monolith - i give up and having it upgrade for every hand played that is most played hand, which is unfortunately like jimball but oh well, couldnt get least played hand to work
SMODS.Joker {
  key = 'JPMonolith',
  loc_txt = {
    name = 'Monolith',
    text = {
      "This Joker gains {X:mult,C:white}X#2#{} Mult per", 
      "{C:attention}consecutive{} hand played", 
      "which is your", 
      "most played {C:attention}poker hand{}", 
      "{C:inactive}Currently {X:mult,C:white}X#1#{} {C:inactive}Mult"
    },
    unlock = {"Defeat the {C:attention}Monolith{} Challenge"},
  },
  config = { extra = { x_mult = 1, x_mult_gain = 0.1 } },
  rarity = 3,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 2, y = 3 },
  cost = 8,
  unlocked = false,
  discovered = false,
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_monolith_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,

  loc_vars = function(self, info_queue, card)
    return { vars = {card.ability.extra.x_mult, card.ability.extra.x_mult_gain} }
  end,

  calculate = function(self, card, context)
    if context.before and not context.blueprint then
        local reset = false
        local play_more_than = (G.GAME.hands[context.scoring_name].played or 0)
        for k, v in pairs(G.GAME.hands) do
            if k ~= context.scoring_name and v.played >= play_more_than and v.visible then
                reset = true
            end
        end
        if reset then
            if card.ability.extra.x_mult > 1 then
                card.ability.extra.x_mult = 1
                    return {
                    card = card,
                    message = localize('k_reset')
                    }
            end
        else
            card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain
            return nil, true
        end
    end
    if context.joker_main and not context.blueprint then
        return {
                message = localize {type = 'variable', key = 'a_xmult', vars = {card.ability.extra.x_mult} },
                Xmult_mod = card.ability.extra.x_mult
        }
    end
  end
}

-- Handle With Care 
SMODS.Joker { 
  key = "JPHandleWithCare", 
  loc_txt = {
    name = 'Handle With Care',
    text = {
      "Retrigger all scored", 
      "{C:attention}Glass Cards{}" 
    },
    unlock = {"Defeat the {C:attention}Fragile{} Challenge"},
  },
  config = { extra = {repetition = 1} },
  rarity = 3,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 3, y = 3 },
  cost = 5,
  unlocked = false,
  discovered = false,
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_fragile_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  loc_vars = function(self, info_queue, card)
    return { 
        vars = {card.ability.extra.repetition} 
    } 
  end,

  calculate = function(self, card, context)
    if context.repetition and context.cardarea == G.play then
        if context.other_card.ability.name == 'Glass Card' then
            return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra.repetition,
                    card = card
                }
        end
    end
  end
}

-- BlackJack
SMODS.Joker {
  key = 'JPBlackJack',
  loc_txt = {
    name = 'Black Jack',
    text = {
      "This Joker gains {C:chips}#2#{} Chips", 
      "for every {C:black}Black{} {C:attention}Jack{} played",
      "{C:inactive}Currently {C:chips}#1#{} {C:inactive}Chips" 
    }
  },
  config = { extra = { chips = 0, chips_gain = 21} },
  rarity = 1,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 4, y = 3 },
  cost = 4,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,

  loc_vars = function(self, info_queue, card)
    return { vars = {card.ability.extra.chips, card.ability.extra.chips_gain} }
  end,

  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.chips > 0 then 
        return {
            chips_gain = card.ability.extra.chips,
            message = localize {type = 'variable', key = 'a_chips', vars = {card.ability.extra.chips}}
         }
    end
    if context.individual and context.cardarea == G.play then
        if context.other_card:is_suit("Spades") and context.other_card:get_id() == 11 then
                    card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_gain
                        return {
                          message = localize('k_upgrade_ex'),
                          colour = G.C.CHIPS,
                          card = card
                        }
        end
        if context.other_card:is_suit("Clubs") and context.other_card:get_id() == 11 then
                    card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_gain
                        return {
                          message = localize('k_upgrade_ex'),
                          colour = G.C.CHIPS,
                          card = card
                        }
        end
    end
  end
}

--Pocket Aces
SMODS.Joker { 
  key = "JPPocketAces", 
  loc_txt = {
    name = 'Pocket Aces',
    text = {
      "If hand contains a {C:attention}Pair{}", 
      "of {C:attention}Aces{}, they are", 
      "Retriggered"
    }
  },
  config = { extra = {repetition = 1} },
  rarity = 2,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 0, y = 4 },
  cost = 5,
  unlocked = true,
  discovered = true, -- change later
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  loc_vars = function(self, info_queue, card)
    return { 
        vars = {card.ability.extra.repetitions} 
    } 
  end,

  calculate = function(self, card, context)
    if context.repetition and context.cardarea == G.play and context.poker_hands then
        if context.other_card:get_id() == 14 then 
            if next(context.poker_hands['Pair']) then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra.repetition,
                    card = card
                }
                end
            end
        end
    end
}

--Make it Rain
SMODS.Joker {
  key = 'JPRiskofRain',
  loc_txt = {
    name = 'Make it Rain',
    text = {
      "This Joker gains {C:chips}Chips{} equal", 
      "to quadruple the value of this",
      "Joker at the end of the round",
      "{C:inactive}Currently {C:chips}#1#{} {C:inactive}Chips" 
    },
    unlock = {"Defeat the", 
              "{C:attention}On a Knife's Edge{} Challenge"},
  },
  config = { extra = { chips = 0, chips_gain = 2} },
  rarity = 1,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 4, y = 4 },
  cost = 6,
  unlocked = false,
  discovered = false,
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_knife_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,

  loc_vars = function(self, info_queue, card)
    return { vars = {card.ability.extra.chips, card.ability.extra.chips_gain} }
  end,

  calculate = function(self, card, context)
        if context.end_of_round and not context.individual and not context.blueprint then
                card.ability.extra.chips = (card.ability.extra.chips + (card.ability.extra.chips_gain * card.sell_cost) / 2) -- dont ask, i dont know why but it was being multiplied by 8 without the /2 
                    return {
                      message = localize('k_upgrade_ex'),
                      colour = G.C.CHIPS,
                      card = card
                    }
        end
        if context.joker_main then
                return {
                    message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
                    chips_gain = card.ability.extra.chips
                }
        end
  end
}

--Sommers
SMODS.Joker { 
  key = "JPSommers", 
  loc_txt = {
    name = 'Sommers',
    text = {
      "Retrigger all {C:attention}Queens{}",
      "three times"
    },
    unlock = {"Defeat the {C:attention}Golden Needle{} Challenge"},
  },
  config = { extra = {repetition = 3} },
  rarity = 4,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 4, y = 5 },
  soul_pos = { x = 0, y = 6},
  cost = 20,
  unlocked = false,
  discovered = false, 
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_golden_needle_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  loc_vars = function(self, info_queue, card)
    return { 
        vars = {card.ability.extra.repetitions} 
    } 
  end,

  calculate = function(self, card, context)
    if context.repetition and context.cardarea == G.play then
        if context.other_card:get_id() == 12 then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra.repetition,
                    card = card
                }
            end
        end
    end
}

-- Fleeman
SMODS.Joker { 
  key = "JPFleeman", 
  loc_txt = {
    name = 'Fleeman',
    text = {
      "Create a {C:tarot}Fool{} for every",
      "{C:attention}Item{} purchased in the shop",
      "or {C:attention}Booster Pack{} opened",
      "{C:inactive}Must have room"
    },
    unlock = {"Defeat the {C:attention}Jokerless{} Challenge"},
  },
  config = {},
  rarity = 4,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 2, y = 5 },
  soul_pos = { x = 2, y = 6},
  cost = 20,
  unlocked = false,
  discovered = false, 
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_jokerless_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  loc_vars = function(self, info_queue, card)
    return { 
        vars = {} 
    } 
  end,

  calculate = function(self, card, context)
    if context.buying_card or context.open_booster and not context.blueprint and not (context.card == card) then
        if #G.consumeables.cards < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                      trigger = 'before',
                      delay = 0.0,
                          func = (function()
                              local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, 'c_fool')
                              card:add_to_deck()
                              G.consumeables:emplace(card)
                              G.GAME.consumeable_buffer = 0
                              return true
                          end)}))
                    end
        end
    end
}

--Hudson
SMODS.Joker { 
  key = "JPHudson", 
  loc_txt = {
    name = 'Hudson',
    text = {
      "This card gains {X:mult,C:white}X#2#{} Mult",
      "for every {C:attention}High Card{} played",
      "{C:inactive}Currently {X:mult,C:white}X#1#{} {C:inactive}Mult"
    },
    unlock = {"Defeat the {C:attention}Cruelty{} Challenge"},
  },
  config = { extra = { x_mult = 1, x_mult_gain = 0.25 } },
  rarity = 4,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 3, y = 5 },
  soul_pos = { x = 1, y = 6},
  cost = 20,
  unlocked = false,
  discovered = false, 
  check_for_unlock = function(self, args)
        if args.type == 'win_challenge' and G.GAME.challenge == 'c_cruelty_1' then
            self.challenge_bypass = true
            unlock_card(self)
        end
    end,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = {card.ability.extra.x_mult, card.ability.extra.x_mult_gain } }
  end,

  calculate = function(self, card, context)
    if context.joker_main and not context.blueprint and context.cardarea == G.jokers then
        if context.scoring_hand and context.scoring_hand == "High Card" then
            card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain
                G.E_MANAGER:add_event(Event({
                func = function()
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')}); return true
                    end
            }))
            end
            return {
                message = localize {type = 'variable', key = 'a_xmult', vars = {card.ability.extra.x_mult} },
                Xmult_mod = card.ability.extra.x_mult
             }
        end
    end
}

-- Keycard
SMODS.Joker {
  key = 'JPKeycard',
  loc_txt = {
    name = 'Keycard',
    text = {
      "Create a {C:attention}Tag{} at the", 
      "end of the {C:attention}shop"
    }
  },
  config = {},
  rarity = 3,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 3, y = 4 },
  cost = 4,
  unlocked = true,
  discovered = true,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,

  loc_vars = function(self, info_queue, card)
    return { vars = {} }
  end,

  calculate = function(self, card, context)
    if context.ending_shop and not context.blueprint then
        G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    if G.FORCE_TAG then return G.FORCE_TAG end
                    local i = 1
                    while i <= 1 do
                        local _pool, _pool_key = get_current_pool('Tag', nil, nil, nil)
                        local _tag_name = pseudorandom_element(_pool, pseudoseed(_pool_key))
                        local it = 1
                        while _tag_name == 'UNAVAILABLE' or _tag_name == "tag_double" or _tag_name == "tag_orbital" do
                            it = it + 1
                            _tag_name = pseudorandom_element(_pool, pseudoseed(_pool_key .. '_resample' .. it))
                        end

                        G.GAME.round_resets.blind_tags = G.GAME.round_resets.blind_tags or {}
                        local _tag = Tag(_tag_name, nil, G.GAME.blind)
                        add_tag(_tag)
                        i = i + 1
                    end
                    return true
                end
            }))
    end
  end
}

--Grim Reaper
SMODS.Joker {
  key = 'JPGrim',
  loc_txt = {
    name = "Grim Reaper",
    text = {
      "This card gains {X:mult,C:white}X#2#{} Mult",
      "for every {C:tarot}Death{} used",
      "{C:inactive}Currently {X:mult,C:white}X#1#{} {C:inactive}Mult"
    }
  },
  config = { extra = { x_mult = 1, x_mult_gain = 0.2 } },
  rarity = 2,
  atlas = 'JestersPrivilegeAtlas',
  pos = { x = 1, y = 5 },
  cost = 7,
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,

  loc_vars = function(self, info_queue, card)
    return { vars = {card.ability.extra.x_mult, card.ability.extra.x_mult_gain} }
  end,

  calculate = function(self, card, context)
      if context.using_consumeable and not context.blueprint then
        if context.consumeable.ability.name == "Death" then
            card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain
                G.E_MANAGER:add_event(Event({
                        func = function()
                            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')}); return true
                            end
                    }))
        end
      end
      if context.joker_main and not context.before and not context.after then
        return {
            message = localize {type = 'variable', key = 'a_xmult', vars = {card.ability.extra.x_mult} },
            Xmult_mod = card.ability.extra.x_mult
            }
      end
        
  end
}


