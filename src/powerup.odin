package PaddleBattle

import "core:fmt"
import "core:math"
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

initPowerUp :: proc() {
	SpawnPowerUp()
}

updatePowerUp :: proc(dt: f32) {
	angle += 1 * dt
	powerUp.position += {math.cos(angle) * 1.5, powerUp.velocity.y * dt}

	if powerUp.position.y >= gameScreenHeight || powerUp.position.y <= 0 {
		powerUp.velocity.y *= -1
	}
}

renderPowerUp :: proc() {
	rl.DrawCircleV(powerUp.position, powerUp.radius, rl.YELLOW)
}

SpawnPowerUp :: proc() {
	powerUp = PowerUp {
		position = {gameScreenWidth * 0.5, gameScreenHeight * 0.5},
		velocity = rl.Vector2{0, 50},
		radius   = 20,
	}
}
