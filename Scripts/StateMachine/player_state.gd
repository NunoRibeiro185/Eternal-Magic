class_name PlayerState extends State

const IDLE = "Idle"
const RUNNING = "Running"
const DASHING = "Dashing"
const CASTING = "Casting"
const TARTGETING = "Targeting"

const HURT = "Hurt"
const DEAD = "Dead"

const ROOT = "Root"
const STUNNED = "Stunned"
const SILENCED = "Silenced"

var player: Player

func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")
