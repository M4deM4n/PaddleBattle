package PaddleBattle

import rl "vendor:raylib"

PlayerScoredInput :: proc() {
	if rl.IsKeyPressed(.ESCAPE) {
		gameState = GameState.MainMenu
	}

	if rl.IsKeyPressed(.SPACE) || rl.IsKeyPressed(.ENTER) {
		resetMatch()
		gameState = GameState.MatchBegin
	}
}

PlayerScoredUpdate :: proc(dt: f32) {
	PlayerScoredInput()
}

PlayerScoredRender :: proc() {
	renderText({gameScreenWidth * 0.5, gameScreenHeight * 0.5}, "SCORE!!!", 142, rl.WHITE)
}
