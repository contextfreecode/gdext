import SwiftGodot

#initSwiftExtension(cdecl: "swift_entry_point", types: [SwiftShip.self])

@Godot
class SwiftShip: Node {
    @Export(.range, "0,2000,100")
    var speed: Double = 500.0

    #signal("finished", arguments: ["node": Node.self])

    @Callable
    public func attack(ship_x: Double, target_x: Double, target_y: Double) {
        //
    }

    public override func _ready () {
        sprite = (getNode(path: "Sprite") as! Node2D)
        target = (getNode(path: "Target") as! Node2D)
    }

    public override func _process(delta: Double) {
        var position = sprite!.position
        if (state == .wait) {
            start = position
        }
        let targetPos = target!.position
        let oldState = state;
        state = switch state {
            case .wait: .enter
            case .enter: position.y > targetPos.y ? .exit : state
            case .exit: position.y < start.y ? .wait : state
        }
        let direction = (targetPos - start).normalized()
        let move = switch state {
            case .wait: Vector2.zero
            case .enter: direction
            case .exit: Vector2(x: direction.x, y: -direction.y)
        }
        position += move * delta * speed
        if state == .wait {
            if state != oldState {
                emit(signal: SwiftShip.finished, self)
            }
            position = start
        }
        sprite!.position = position
    }

    var sprite = nil as Node2D?
    var start = Vector2()
    var state = State.wait
    var target = nil as Node2D?
}

enum State {
    case wait
    case enter
    case exit
}
