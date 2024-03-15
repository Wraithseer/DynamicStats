# Dynamic Stats for Elder Scrolls Online™

**Dynamic Stats** is a simplistic addon for *Elder Scrolls Online™* that calculates and displays important stats on screen in real time.

## Currently Displayed Player Stats and Details:

- **Weapon/Spell Damage**: Displays whichever is higher, as stats are interchangeable for all purposes. This can be different due to minor brutality/sorcery, depending on classes in group.

- **Armor Penetration**: Shows physical and spell penetration values, which have the same value from all sources. Calculates penetration on target under reticle by scanning for debuffs - Minor/Major Breach, Crystal Weapon, Runic Sunder, Crushing enchantment, and set effects like Tremorscale, Alkosh, Crimson Oath. Also considers status effects if Force of Nature CP is slotted. Colored yellow if over 18200 (PvE cap).

- **Critical Chance**: Displays both physical and spell crit chance as a percentage. These can be different due to minor savagery/prophecy, depending on the classes in the group, and different abilities using different crit values.

- **Critical Damage**: Calculates critical damage from advanced stat sheet and additional sources. Also calculates critical damage on target under reticle by scanning for debuffs - Minor/Major Brittle and Elemental Weakness components. Checks if Backstabber CP is slotted and adds flat 10% CHD if detected. Colored red if over 125% global cap.

- **Physical and Spell Resistance**: Displays current values from the stat sheet. Colored yellow if over 33000 (PvE cap).

- **Movement Speed**: Calculated from different sources including original movement speed, sprint speed, Major/Minor Expedition, Bosmer Passive, Steed Mundus, Ring of the Wild Hunt, Swift Trait, Steed's Blessing (CP Slottable), Celerity (CP slottable). Colored red if over 200% global cap. When mounted, replaces with mount speed, calculated similarly but with different components. Assumes global cap of 300% is unreachable.

## Planned Fixes and Features:

1. Change format of capped values (CHD, non-mounted MS) to display value over cap (e.g., red 125%+6%).
2. Improve detection for when player stops sprinting (currently no trigger, stats update on other events).
3. Fix penetration values for Alkosh, Sundering enchant (add floating values if possible, improve detection if not) - currently delivers 4000 for Alkosh and max 2108 for sundering.
4. Fix Force of Nature CP not properly recognizing Diseased, Sundered, Overcharged, or Concussion (hidden buffs, see CMX).
5. Improve calculation of Swift traits to account for non-gold items (currently adds flat 7% per detected swift trait).
6. Improve calculation of divine trait of Steed mundus to account for non-gold items (currently adds flat 1% for every detected divine item beyond the first).
7. If possible, move sprint event from SHIFT press to a better detection method or make it configurable.
8. Add support for different levels of included CP stars (possibly not needed, but not the most extreme edge case).
9. Change functions and methods to reduce unnecessary calls and updates.
10. Improve visual design.
11. Add settings for turning stat lines on and off.
12. Add automatic PvP mode on battle spirit acquisition, removing cap information from penetration and armor and recalculating player penetration debuffs.
13. Refactor functions and calls to improve code quality.
