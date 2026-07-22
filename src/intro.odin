package PaddleBattle

import rl "vendor:raylib"

IntroTextAlpha: f32 = 0.0
introTextColor: rl.Color = rl.WHITE
introTimer: f32

IntroUpdate :: proc(dt: f32) {
	introTimer += dt

	if introTimer <= 1.5 {
		return
	}

	if IntroTextAlpha < 1 {
		IntroTextAlpha += 0.75 * dt
		if IntroTextAlpha > 1.0 {IntroTextAlpha = 1.0}
	}

	if introTimer >= 5 {
		introTimer = 0
		gameState = GameState.MainMenu
	}
}

IntroRender :: proc() {

	introTextColor = rl.Fade(rl.WHITE, IntroTextAlpha)

	renderText(
		{gameScreenWidth * 0.5, gameScreenHeight * 0.5},
		"PIZANO PRESENTS...",
		72,
		introTextColor,
	)
}
