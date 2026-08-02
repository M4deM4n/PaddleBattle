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

init :: proc(gs: GameState) {
	initAudio()

	paddle_velocity = 600
	ignoreCollission = false
	ballspeed = 500

	initBall()
	initPaddles()
	initBackgrounds()
	initPowerUp()
	initAI()

	gameState = gs
}

update :: proc(dt: f32) {
	updateGameState(dt)
}

render :: proc() {
	rl.ClearBackground({0, 0, 0, 255})

	renderGameState()
}
