extends Control

const DungeonScript = preload("res://scenes/dungeon/dungeon.gd")
const Dungeon = DungeonScript.Dungeon
const Direction = DungeonScript.Direction
const Corridor = DungeonScript.Corridor

@onready var dungeon: Dungeon = owner.dungeon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dungeon.moved.connect(_on_move)
	
func _on_move(_location, _facing):
	queue_redraw()

func rotate(vec: Vector2i):
	match dungeon.facing:
		Direction.NORTH:
			return vec
		Direction.EAST:
			return Vector2i(vec.y, -vec.x)
		Direction.SOUTH:
			return Vector2i(-vec.x, -vec.y)
		Direction.WEST:
			return Vector2i(-vec.y, vec.x)

func draw_centered(x: float, y: float, radius: float, color: Color):
	draw_rect(Rect2(x - radius/2.0, y - radius/2.0, radius, radius), color)

func _draw() -> void:
	print("REDRAW MINI")
	if dungeon == null:
		return
		
	var origin := size / 2
	# Draw the player rect
	for y in range(-5, 5):
		for x in range(-5, 5):
			var posX = dungeon.current_location.x + x
			var posY = dungeon.current_location.y + y
			var pos = Vector2i(posX, posY)
			var corridor: Corridor = dungeon.map.get(pos)

			if corridor != null && corridor.did_travel:
				var origX = x * 20
				var origY = y * 20
				var rotated = rotate(Vector2i(origX, origY))
				var corridorMapX = origin.x + rotated.x
				var corridorMapY = origin.y + rotated.y
				draw_centered(corridorMapX, corridorMapY, 10, Color("green"))
				for dir in corridor.open_directions:
					var adj = dungeon.map.get(dungeon.apply_direction(pos, dir))
					var color = Color('purple')
					if adj != null && adj.did_travel:
						color = Color('green')
					match dir:
						Direction.NORTH:
							var adj_rotated = rotate(Vector2i(origX, origY - 10))
							draw_centered(origin.x + adj_rotated.x, origin.y + adj_rotated.y, 10, color)
						Direction.EAST:
							var adj_rotated = rotate(Vector2i(origX + 10, origY))
							draw_centered(origin.x + adj_rotated.x, origin.y + adj_rotated.y, 10, color)
						Direction.SOUTH:
							var adj_rotated = rotate(Vector2i(origX, origY + 10))
							draw_centered(origin.x + adj_rotated.x, origin.y + adj_rotated.y, 10, color)
						Direction.WEST:
							var adj_rotated = rotate(Vector2i(origX - 10, origY))
							draw_centered(origin.x + adj_rotated.x, origin.y + adj_rotated.y, 10, color)
	draw_rect(Rect2(origin.x - 5, origin.y - 5, 10, 10), Color("red"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	pass
