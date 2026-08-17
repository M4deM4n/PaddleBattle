package PaddleBattle

import "core:fmt"
import "core:math"
import "gameTypes"
import rl "vendor:raylib"

PowerUp :: struct {
	position: rl.Vector2,
	velocity: rl.Vector2,
	radius:   f32,
}

PowerUpProfile :: struct {}
angle: f32

PowerUpState :: struct {
	profile:      []PowerUpProfile,
	releaseTimer: f32,
}

powerUp: PowerUp

initPowerUp :: proc(game: ^gameTypes.Game) {
	SpawnPowerUp(game)
}

updatePowerUp :: proc(game: ^gameTypes.Game, dt: f32) {
	angle += 1 * dt
	powerUp.position += {math.cos(angle) * 1.5, powerUp.velocity.y * dt}

	if powerUp.position.y >= game.screen.y || powerUp.position.y <= 0 {
		powerUp.velocity.y *= -1
	}
}

renderPowerUp :: proc() {
	rl.DrawCircleV(powerUp.position, powerUp.radius, rl.YELLOW)
}

SpawnPowerUp :: proc(game: ^gameTypes.Game) {
	powerUp = PowerUp {
		position = game.centerScreen,
		velocity = rl.Vector2{0, 50},
		radius   = 20,
	}
}
