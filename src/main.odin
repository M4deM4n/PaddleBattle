package PaddleBattle

import "core:c"
import "core:os"
import "gameTypes"
import "spriteAnimation"
import rl "vendor:raylib"

WINDOW_WIDTH :: 1920
WINDOW_HEIGHT :: 1080

renderScale: f32

shouldClose: bool = false

studioTexture: rl.Texture2D

winImg: spriteAnimation.AnimatedSprite


main :: proc() {

	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT, .BORDERLESS_WINDOWED_MODE})
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "PaddleBattle")

	mw := rl.GetMonitorWidth(0)
	mh := rl.GetMonitorHeight(0)
	rl.SetWindowPosition((mw - WINDOW_WIDTH) / 2, (mh - WINDOW_HEIGHT) / 2)

	rl.SetExitKey(.KEY_NULL)
	rl.SetWindowMinSize(640, 360) // 16:9 aspect ratio
	rl.SetTargetFPS(500)

	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()

	game: gameTypes.Game
	game.screen = {f32(WINDOW_WIDTH), f32(WINDOW_HEIGHT)}
	game.centerScreen = {game.screen.x * 0.5, game.screen.y * 0.5}

	studioTexture = rl.LoadTexture("../res/img/poo.png")
	defer rl.UnloadTexture(studioTexture)

	spriteAnimation.init(&winImg, "../res/img/player_win.png", 100, 100)
	anim := spriteAnimation.create("win", 0, 14, 12, false)
	spriteAnimation.addAnimation(&winImg, anim)

	defer rl.UnloadTexture(winImg.texture)

	// init with override starting point
	init(&game, gameTypes.GameState.Intro)

	initFont()
	defer rl.UnloadFont(gameFont.font)

	// render texture
	renderTarget := rl.LoadRenderTexture(i32(game.screen.x), i32(game.screen.y))

	// filtering
	rl.SetTextureFilter(renderTarget.texture, .BILINEAR)
	rl.SetTextureFilter(gameFont.font.texture, .BILINEAR)


	for !shouldClose {

		if rl.WindowShouldClose() {
			shouldClose = true
		}

		// update game logic
		dt := rl.GetFrameTime()
		update(&game, dt)

		// render to render texture to maintain aspect ration across resolutions
		renderScale = min(
			f32(rl.GetScreenWidth()) / game.screen.x,
			f32(rl.GetScreenHeight()) / game.screen.y,
		)

		// mouse compensation for render scale

		rl.BeginTextureMode(renderTarget)
		render(&game)
		rl.EndTextureMode()

		rl.BeginDrawing()
		rl.ClearBackground({0, 0, 0, 255}) // black


		// render the scaled render texture
		rl.DrawTexturePro(
			renderTarget.texture,
			rl.Rectangle {
				0.0,
				0.0,
				f32(renderTarget.texture.width),
				-f32(renderTarget.texture.height),
			},
			rl.Rectangle {
				(f32(rl.GetScreenWidth()) * 0.5) - ((game.screen.x * renderScale) * 0.5),
				(f32(rl.GetScreenHeight()) * 0.5) - ((game.screen.y * renderScale) * 0.5),
				game.screen.x * renderScale,
				game.screen.y * renderScale,
			},
			rl.Vector2{0, 0},
			0,
			{255, 255, 255, 255},
		)

		rl.EndDrawing()

		free_all(context.temp_allocator)
	}

	unloadAudio()
	rl.UnloadRenderTexture(renderTarget)
	rl.CloseWindow()
}
