package PaddleBattle

import "core:c"
import "core:fmt"
import rl "vendor:raylib"

player1 :: 0
player2 :: 1

paddle_l_posY: f32
paddle_r_posY: f32

paddle_velocity: f32

paddles: [2]Paddle
ball: Ball

startPosY: f32

aiState: AiState

gridShader: rl.Shader
locTargetHeight: c.int
locGridSize: c.int
locBallPosition: c.int
locBallRadius: c.int
locDistortRadius: c.int
locLineWidth: c.int
locBgColor: c.int
locLineColor: c.int
locGlowColor: c.int

init :: proc(gs: GameState) {
	initAudio()


	paddle_velocity = 600
	ignoreCollission = false
	ballspeed = 500

	gridShader = rl.LoadShaderFromMemory(nil, #load("../res/shader/grid_distort.glsl", cstring))
	locTargetHeight = rl.GetShaderLocation(gridShader, "u_targetHeight")
	locGridSize = rl.GetShaderLocation(gridShader, "u_gridSize")
	locBallPosition = rl.GetShaderLocation(gridShader, "u_ballPos")
	locBallRadius = rl.GetShaderLocation(gridShader, "u_ballRadius")
	locDistortRadius = rl.GetShaderLocation(gridShader, "u_distortRadius")
	locLineWidth = rl.GetShaderLocation(gridShader, "u_lineWidth")
	locBgColor = rl.GetShaderLocation(gridShader, "u_bgColor")
	locLineColor = rl.GetShaderLocation(gridShader, "u_lineColor")
	locGlowColor = rl.GetShaderLocation(gridShader, "u_glowColor")

	if locBallPosition < 0 {fmt.println("Warning: u_ballPos not found in shader")}

	initPaddles()
	initBall()
	initPowerUp()
	initAI()

	gameState = gs
}

update :: proc(dt: f32) {
	#partial switch gameState {
	case GameState.Intro:
		IntroUpdate(dt)

	case GameState.MainMenu:
		MainMenuUpdate(dt)

	case GameState.MatchBegin:
		MatchBeginUpdate(dt)

	case GameState.Playing:
		GameUpdate(dt)

	case GameState.PlayerScored:
		PlayerScoredUpdate(dt)

	}
}

render :: proc() {
	rl.ClearBackground({0, 0, 0, 255})

	#partial switch gameState {
	case GameState.Intro:
		IntroRender()

	case GameState.MainMenu:
		MainMenuRender()

	case GameState.MatchBegin:
		MatchBeginRender()

	case GameState.Playing:
		GameRender()

	case GameState.PlayerScored:
		PlayerScoredRender()
	}
}
