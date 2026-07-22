package PaddleBattle

import rl "vendor:raylib"

matchBeginTimer: f32
matchCounterIndex: i32
matchCounterText: [4]cstring = {"3", "2", "1", "GO!"}
matchBeginText: cstring

MatchBeginUpdate :: proc(dt: f32) {
	matchBeginTimer += dt

	if matchBeginTimer >= 1 {
		matchCounterIndex += 1
		matchBeginTimer = 0
	}

	if matchCounterIndex >= len(matchCounterText) {
		matchCounterIndex = 0
		gameState = GameState.Playing
	}
}

MatchBeginRender :: proc() {
	renderText(
		{gameScreenWidth * 0.5, gameScreenHeight * 0.5},
		matchCounterText[matchCounterIndex],
		72,
		rl.WHITE,
	)
}
