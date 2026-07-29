package PaddleBattle

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"

MatchState :: struct {
	timer:             f32,
	rallyCount:        i32,
	rallyScore:        i32,
	p1Score:           i32,
	p2Score:           i32,
	increaseBallSpeed: bool,
}

currentMatch: MatchState = MatchState{}
announceSpeed: bool = true
scoreColor: rl.Color = {0, 0, 96, 255}
currentScoreColor: rl.Color = {0, 0, 96, 255}

updateMatch :: proc(dt: f32) {
	currentScoreColor = rl.ColorLerp(currentScoreColor, scoreColor, dt)
}

updateRally :: proc() {
	currentMatch.rallyCount += 1
	currentMatch.rallyScore += currentMatch.rallyCount * 10
	currentScoreColor = rl.WHITE

	if currentMatch.rallyCount == 8 && announceSpeed {
		announceSpeed = false
		rl.PlaySound(audioSpeedingUp)
	}

	if currentMatch.rallyCount % 15 == 0 {
		rl.PlaySound(rand.choice(announcerRally[:]))
	}
}

resetMatch :: proc() {
	currentMatch.timer = 0
	currentMatch.rallyCount = 0
	currentMatch.rallyScore = 0
	currentMatch.p1Score = 0
	currentMatch.p2Score = 0

	announceSpeed = true

	resetPaddles()
	resetBall()
	gameState = GameState.MatchBegin
}

renderRallyPoints :: proc() {
	position := rl.Vector2{gameScreenWidth * 0.5, 50}

	renderText(position, fmt.caprintf("%i", currentMatch.rallyScore), 72, currentScoreColor)
}
