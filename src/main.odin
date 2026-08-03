package PaddleBattle

import "core:c"
import "core:os"
import rl "vendor:raylib"

WINDOW_WIDTH :: 1920
WINDOW_HEIGHT :: 1080

gameScreenWidth: f32 = 1920
gameScreenHeight: f32 = 1080

renderScale: f32

shouldClose: bool = false

studioTexture: rl.Texture2D
main :: proc() {

	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT, .BORDERLESS_WINDOWED_MODE})
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "PaddleBattle")
	rl.SetExitKey(.KEY_NULL)
	rl.SetWindowMinSize(640, 360) // 16:9 aspect ratio
	rl.SetTargetFPS(500)

	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()

	studioTexture = rl.LoadTexture("../res/img/poo.png")
	defer rl.UnloadTexture(studioTexture)

	init(GameState.Intro)

	initFont()
	defer rl.UnloadFont(gameFont.font)

	// render texture
	renderTarget := rl.LoadRenderTexture(i32(gameScreenWidth), i32(gameScreenHeight))

	// filtering
	rl.SetTextureFilter(renderTarget.texture, .BILINEAR)
	rl.SetTextureFilter(gameFont.font.texture, .BILINEAR)


	for !shouldClose {

		if rl.WindowShouldClose() {
			shouldClose = true
		}

		// update game logic
		dt := rl.GetFrameTime()
		update(dt)

		// render to render texture to maintain aspect ration across resolutions
		renderScale = min(
			f32(rl.GetScreenWidth()) / gameScreenWidth,
			f32(rl.GetScreenHeight()) / gameScreenHeight,
		)

		// mouse compensation for render scale

		rl.BeginTextureMode(renderTarget)
		render()
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
				(f32(rl.GetScreenWidth()) * 0.5) - ((gameScreenWidth * renderScale) * 0.5),
				(f32(rl.GetScreenHeight()) * 0.5) - ((gameScreenHeight * renderScale) * 0.5),
				gameScreenWidth * renderScale,
				gameScreenHeight * renderScale,
			},
			rl.Vector2{0, 0},
			0,
			{255, 255, 255, 255},
		)

		rl.EndDrawing()
	}

	unloadAudio()
	rl.UnloadRenderTexture(renderTarget)
	rl.CloseWindow()
}
