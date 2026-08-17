package PaddleBattle

import "core:fmt"
import "gameTypes"
import rl "vendor:raylib"

introAlpha: f32 = 0.0
introTextColor: rl.Color = rl.BLACK
introShadowColor: rl.Color = rl.BLACK
introTextureColor: rl.Color = rl.WHITE
introTimer: f32
introSoundPlayed: bool

IntroUpdate :: proc(game: ^gameTypes.Game, dt: f32) {
	introTimer += dt

	if introTimer <= 1.5 {
		return
	}

	if introAlpha < 1 {
		introAlpha += 0.75 * dt
		if introAlpha > 1.0 {introAlpha = 1.0}
	}

	if !rl.IsSoundPlaying(introLaughter) && introAlpha >= 0.5 && !introSoundPlayed {
		rl.PlaySound(introLaughter)
		introSoundPlayed = true
	}

	if introTimer >= 8 {
		introTimer = 0
		game.state = .MainMenu
	}


}

IntroRender :: proc(game: ^gameTypes.Game) {
	rl.ClearBackground({255, 227, 102, 255})
	rl.BeginBlendMode(.ALPHA)
	introTextureColor = rl.Fade(rl.WHITE, introAlpha)
	introTextColor = rl.Fade(rl.BLACK, introAlpha)
	// introShadowColor = rl.Fade(rl.BLACK, introAlpha)


	rl.DrawTexture(
		studioTexture,
		i32(game.screen.x * 0.5) - i32(f32(studioTexture.width) * 0.5),
		i32(game.screen.y * 0.5) - i32(f32(studioTexture.height) * 0.5),
		introTextureColor,
	)
	rl.EndBlendMode()

	renderText(game.centerScreen + rl.Vector2{0, 200}, "Shits N Giggles", 72, introTextColor)
}
