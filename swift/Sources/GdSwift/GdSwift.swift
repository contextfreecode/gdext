import SwiftGodot

#initSwiftExtension(cdecl: "swift_entry_point", types: [SwiftShip.self])

@Godot
class SwiftShip: Sprite2D {
    public override func _ready () {}

    public override func _process(delta: Double) {
        rotation += delta
    }
}
