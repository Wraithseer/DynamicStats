Dynamis stats is a simplistic addon for Elder Scrolls Online™ that calculates and displays important stats on screen in real time.

Currently displayed player stats and details:

Weapon/Spell Damage
Displays whichever higher as stats are interchangeable for all purpouses, can be different due to minor brutality/sorcery, depending on classes in group

Armor Penetration
Physical and spell penetration have the same value from all sources
Calculates penetration on target under reticle by scanning target debuffs - Minor/Major Breach, Crystal Weapon, Runic Sunder, Cushing enchantment and set effects Tremorscale, Alkosh, Crimson Oath, as well as status effects in case Force of Nature CP is slotted
Colored yeallow if over 18200 (pve cap)

Critical Chance 
Both physical and spell crit chance is shown as % as those can be different due to minor svagery/prophecy, depending on classes in group, and different abilities use different crit value

Critical Damage
Calculates critical damage from advansed stat sheet and additional sources
Calculates critical damage on target under reticle by scanning target debuffs - Minor/Major Brittle and Elemental Weakness components
Checks if Backstabber CP is slotted and adds flat 10% CHD if detected.
Colored red if over 125% global cap

Physical and Spell resistance
Displays current values for physical and spell resistance from the stat sheet
Colored yeallow if over 33000 (pve cap) 

Movement Speed
Calculated from number of different sources
-Original movement speed 100%
-Sprint speed from 40% up - taken from advansed stats
-Major Expedition 30%
-Minor Expedition 15%
-Bosmer Passive 5%
-Steed Mundus 10% (16% with 7/7 gold divines traits)
-Ring of the Wild Hunt (45% out of combat, 15% in combat)
-Swift Trait 7% (gold)
-Steeds Blessing (CP Slottable, 20% out of combat)
-Celerity 10% (CP slottable)
Colored red if over 200% global cap
Repaced with mount speed when player is mounted, calculated similairly
-Mount original speed 115%
-Mount sprint speed 30%
-Mount speed training value up to 60%
-Major Gallop 30%, multiplicative
-Gifted Raider CP 10%, multiplicative (additive with Major Gallop)
Assumer global cap of 300% is unreachable
This calculation does not account for ~20% additional speed burst that is gained for ~1s on sprint button press and is ment not to measure actual traversal speed but to display hidden game stats

Planned fixes and features
1. Change format of capped values (CHD, non-mounted MS) to dispaly value over cap (e.g. red 125%+6%)
2. Improve detection for when player stops sprinting (currenlty no trigger, stats update on other events)
3. Fix penetration values for Alkosh, Sundreing enchant (add floating values if possible, improve detection if not) - currently delivers 4000 for alcosh and max 2108 for sundering
4. Fix Force of Nature CP not properly recognizing Desiesed, Sundred, Overcharged or Concussion (hidden buffs, see cmx).
5. Improve calculation of Swift traits to account for non-gold items (currelty adds flat 7% per detected swift trait)
6. Improve calculation of divines trait of Steed mundus to account for non-gold items (currently adds flat 1% for every detected divines item beyond the first)
7. If possible, move sprint event from SHIFT press to better detection method or to be configurable
8. Add support for different levels of included CP stars (possibly not needed, but not the most extreme edge case)
9. Change functions and methods to reduce unnecessary calls and updates
10. Improve visual design
11. Add settings for turning stat lines on and off
12. Add automatic pvp mode on battle spirit aquisition, that will remove cap information from penetration and armor, as well as calculate player penetration debuffs
13. Refarctor functions and calls to improve code quality.

