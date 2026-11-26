# Pokesword — Project Scope

## Game vision

Pokesword is a 2.5D RPG built in Godot. The player explores the world and meets its inhabitants. The current design direction connects collectible spirits, swords, and forges. How the player obtains a spirit and how it becomes associated with a sword are still open design questions.

## Current foundation

The developer reports that player movement, camera follow, and collisions are working. Before changing any of these, check the existing Godot scenes, scripts, and input actions to see how they work together.

The first playable interaction is the trail sign north of the spawn in `mapa.tscn`. Press E while facing it within reach to read “Trilha da Forja”. The player keeps their facing direction when stopped and calls `interact(player)` on the first object hit in front of them if it implements that method.

While the player stays near the sign, E advances one page or closes the box after the final page. Walking beyond the player's `dialogue_exit_distance` (2 m by default) closes the box without another press; returning and interacting starts on page one. Interactables opt into distance-based closing with `player.start_dialogue(pages, self)`. On the trail sign, `message` is the first page and `additional_pages` holds any continuation.

In `mapa.tscn`, select `InteractionMessage` to tune **Box Layout** (minimum/maximum width, height, bottom margin) and **Typography** (font, size, word spacing). **Editor Preview → Show Preview** displays sample text in the 2D editor only. The box widens before wrapping; if an authored page is too long for the available space, E reveals the remaining lines before moving to the next page.

## Proposed next milestone — the first NPC interaction

Give the player one character they can approach and talk to. A single test NPC and one line of text are enough to test the interaction in a playable scene.

| In-game check | Expected result |
| --- | --- |
| Approach the NPC, face them, and press the interaction button once. | The NPC's line appears once. |
| Press the interaction button outside the NPC's reach. | The NPC does not respond. |
| Finish the exchange and walk away. | Movement, camera follow, and collisions still work as before. |

## Future tools and systems

| Item | Intended use | Planning status |
| --- | --- | --- |
| NPC editor | Give a designer one place to configure a character, including what the character says when approached. | Planned tool. Its fields and interface are open. |
| NPC movement routines | Let a designer specify where a particular NPC goes and in what order. | Under consideration. The choice between a dedicated editor and a section of the NPC editor is open. |
| Game state | Track facts that affect play. For example, a later conversation could depend on whether the player has already met an NPC. | Possible runtime system. The facts to track will depend on gameplay needs. |
| Event engine | Run authored actions when a gameplay condition is met. For example, finishing a conversation could cause an NPC to move. | Possible runtime system. The first event that needs it has yet to be chosen. |

## Open gameplay decisions

- What does the player do at a forge to obtain or bond with a spirit?
- Does the spirit become a sword or inhabit a blade? If it needs a blade, how does the player obtain one?

## Using this file with Codex

Use the current request to determine what to implement. The proposed milestone, future tools, and examples provide planning context. For example, a request to build the first NPC interaction can be completed with one NPC and one line of text. Work on the NPC editor begins when a task calls for it.

Update the current foundation after a feature works in the game. When a design question is settled, record the decision in the relevant section.
