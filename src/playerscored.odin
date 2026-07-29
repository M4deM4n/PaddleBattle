package PaddleBattle

import "core:math/rand"
import rl "vendor:raylib"

announceScoreDialog: bool = true
dialogDelayTimer: f32


PlayerScoredInput :: proc() {
	if rl.IsKeyPressed(.ESCAPE) {
		gameState = GameState.MainMenu
	}

	if rl.IsKeyPressed(.SPACE) || rl.IsKeyPressed(.ENTER) {
		resetMatch()
		announceScoreDialog = true
		dialogDelayTimer = 0
		gameState = GameState.MatchBegin
	}
}

PlayerScoredUpdate :: proc(dt: f32) {
	dialogDelayTimer += dt

	if announceScoreDialog && dialogDelayTimer >= 0 {
		rl.PlaySound(rand.choice(announcerGoal[:]))
		announceScoreDialog = false
	}
	PlayerScoredInput()
}

PlayerScoredRender :: proc() {
	renderText({gameScreenWidth * 0.5, gameScreenHeight * 0.5}, "SCORE!!!", 142, rl.WHITE)
}
