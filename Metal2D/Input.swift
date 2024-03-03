//
//  Input.swift
//  Metal2D
//
//  Created by Kuutti Taavitsainen on 1.3.2024.
//

import GameController
import simd

class Input {
    
    static var keys: Set<GCKeyCode> = []
    static var mouseLeft: Bool = false
    static var mouseRight: Bool = false
    static var mouseMiddle: Bool = false
    
    private static var mouseDX: Float = 0.0
    private static var mouseDY: Float = 0.0
    private static var mouseScrollDelta: Float = 0.0
    private static var mouseCaptured: Bool = false
    
    static func initialize() {
        addKeyboard()
        addMouse()
    }
    
    static func getMouseMoveDelta()-> simd_float2 {
        return simd_float2(mouseDX, mouseDY)
    }
    
    static func getMouseScrollDelta()-> Float {
        return mouseScrollDelta
    }
    
    static func update() {
        mouseDX = 0.0
        mouseDY = 0.0
        mouseScrollDelta = 0.0
    }
    
    static func addKeyboard() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCKeyboardDidConnect,
                                               object: nil,
                                               queue: .main) { info in
            guard let keyboard = info.object as? GCKeyboard else { return }
            keyboard.keyboardInput?.keyChangedHandler = { _, _, keyCode, pressed in
                if pressed {
                    if keyCode == .escape {
                        if mouseCaptured {
                            mouseCaptured = false
                            NSCursor.unhide()
                            CGAssociateMouseAndMouseCursorPosition(1)
                        } else {
                            mouseCaptured = true
                            NSCursor.hide()
                            CGAssociateMouseAndMouseCursorPosition(0)
                        }
                    }
                    keys.insert(keyCode)
                } else {
                    keys.remove(keyCode)
                }
            }
        }
    }
    
    static func addMouse() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCMouseDidBecomeCurrent,
                                               object: nil,
                                               queue: .main) { info in
            guard let mouse = info.object as? GCMouse else { return }
            mouse.mouseInput?.mouseMovedHandler = { _, dx, dy in
                mouseDX = dx
                mouseDY = dy
            }
            mouse.mouseInput?.scroll.yAxis.valueChangedHandler = { _, delta in
                mouseScrollDelta = delta
            }
            mouse.mouseInput?.leftButton.valueChangedHandler = { _, _, value in
                mouseLeft = value
            }
            mouse.mouseInput?.middleButton?.valueChangedHandler = { _, _, value in
                mouseMiddle = value
            }
            mouse.mouseInput?.rightButton?.valueChangedHandler = { _, _, value in
                mouseRight = value
            }
        }
    }
}
