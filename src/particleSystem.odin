package PaddleBattle

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

Particle :: struct {
	position:        rl.Vector2,
	velocity:        rl.Vector2,
	rotation:        f32,
	angularVelocity: f32,
	size:            f32,
	color:           rl.Color,
	life:            f32,
	maxLife:         f32,
}

MAX_PARTICLES :: 512

particles: [MAX_PARTICLES]Particle
particleCount: int
particleGravity: rl.Vector2 = {0, 0}

spawnBurst :: proc(
	origin: rl.Vector2,
	count: int,
	color: rl.Color,
	force: rl.Vector2 = {0, 0},
	speed: f32 = 400,
	speedVar: f32 = 0.5,
	size: f32 = 6,
	sizeVar: f32 = 0.5,
	life: f32 = 0.9,
	lifeVar: f32 = 0.4,
	spin: f32 = 720,
) {
	for _ in 0 ..< count {
		angle := rand.float32_range(0, math.TAU)
		s := speed * (1 - speedVar + rand.float32() * speedVar * 2)

		p: Particle
		p.position = origin
		p.velocity = {math.cos(angle) * s, math.sin(angle) * s} + force
		p.rotation = rand.float32_range(0, 360)
		p.angularVelocity = rand.float32_range(-spin, spin)
		p.size = size * (1 - sizeVar + rand.float32() * sizeVar * 2)
		p.color = color
		p.maxLife = life * (1 - lifeVar + rand.float32() * lifeVar * 2)
		p.life = p.maxLife

		addParticle(p)
	}
}

addParticle :: proc(p: Particle) {
	if particleCount < MAX_PARTICLES {
		particles[particleCount] = p
		particleCount += 1
	} else {
		particles[0] = p
	}
}

updateParticles :: proc(dt: f32) {
	i := 0
	for i < particleCount {
		p := &particles[i]
		p.life -= dt

		if p.life <= 0 {
			particles[i] = particles[particleCount - 1]
			particleCount -= 1
			continue
		}

		p.velocity += particleGravity * dt
		p.position += p.velocity * dt
		p.rotation += p.angularVelocity * dt
		i += 1
	}
}

renderParticles :: proc() {
	for i in 0 ..< particleCount {
		p := &particles[i]
		c := p.color
		c.a = u8(clamp(p.life / p.maxLife, 0, 1) * 255)

		rect := rl.Rectangle{p.position.x, p.position.y, p.size, p.size}
		rl.DrawRectanglePro(rect, {p.size * 0.5, p.size * 0.5}, p.rotation, c)
	}
}

clearParticles :: proc() {
	particleCount = 0
}
