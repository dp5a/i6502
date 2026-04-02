import Testing
@testable import i6502Assembler

@Suite
struct TranslatorTests {
    @Test("empty input")
    func empty() {
        #expect(throws: Never.self, "transaltion went successfully") {
            let resultBytes = try Translator.process([])
            let expectedBytes = memory()
            #expect(resultBytes == expectedBytes, "full memory is unallocated")
        }
    }

    @Test("empty directives")
    func emptyDirecties() {
        #expect(throws: Never.self, "transaltion went successfully") {
            let resultBytes = try Translator.process([
                .org(0xDEAD),
                .labelDeclaration(.init(name: "label", address: 0xDEAD))
            ])
            let expectedBytes = memory()
            #expect(resultBytes == expectedBytes, "full memory is unallocated")
        }
    }

    @Test(".org + .byte")
    func orgByte() {
        #expect(throws: Never.self, "transaltion went successfully") {
            let resultBytes = try Translator.process([
                .org(0xDEAD),
                .byte(0xFF)
            ])
            let expectedBytes = memory { bytes in
                bytes[0xDEAD] = 0xFF
            }
            #expect(resultBytes == expectedBytes, "memory is allocated with $FF at $DEAD")
        }
    }

    @Test(".org + .org + .byte")
    func orgOrgByte() {
        #expect(throws: Never.self, "transaltion went successfully") {
            let resultBytes = try Translator.process([
                .org(0xDEAD),
                .org(0x0123),
                .byte(0xFF)
            ])
            let expectedBytes = memory { bytes in
                bytes[0x123] = 0xFF
            }
            #expect(resultBytes == expectedBytes, "memory is allocated with $FF at $0123")
        }
    }

    @Test(".org + operation")
    func orgOperation() {
        #expect(throws: Never.self, "transaltion went successfully") {
            let resultBytes = try Translator.process([
                .org(0xDEAD),
                .operation(.init(code: .adc, argument: .immediate(0xAA), address: 0xDEAD))
            ])
            let expectedBytes = memory { bytes in
                bytes[0xDEAD] = 0x69
                bytes[0xDEAE] = 0xAA
            }
            #expect(resultBytes == expectedBytes, "memory is allocated with $69,$AA at $DEAD")
        }
    }

    @Test("failing unresolved reference")
    func failingUnresolvedReference() {
        #expect(throws: AssemblerError.translatorError("unresolved label \"unknown\" reference in absolute mode")) {
            try Translator.process([
                .operation(.init(code: .adc, argument: .absolute(.label("unknown")), address: 0xDEAD))
            ])
        }
    }

    @Test("failing illegal operation")
    func failingIllegalOperation() {
        #expect(
            throws: AssemblerError
                .translatorError("nop in immediate mode is illegal, use \".byte **\" if you are absolutely sure")
        ) {
            try Translator.process([
                .operation(.init(code: .nop, argument: .immediate(0xBB), address: 0xDEAD))
            ])
        }
    }

    @Test("assembler basic")
    func assemblerBasic() {
        #expect(throws: Never.self, "transaltion went successfully") {
            var tokens = try Tokenizer.process(
                input: """
                lda #$01
                sta $0200
                lda #$05
                sta $0201
                lda #$08
                sta $0202
                """
            )
            try Linker.process(&tokens)
            let resultBytes = try Translator.process(tokens)

            let expectedBytes = memory { bytes in
                bytes.assign([
                    0xA9, 0x01,
                    0x8D, 0x00, 0x02,
                    0xA9, 0x05,
                    0x8D, 0x01, 0x02,
                    0xA9, 0x08,
                    0x8D, 0x02, 0x02
                ])
            }
            #expect(resultBytes == expectedBytes, "assembler compiled input as expected")
        }
    }

    @Test("assembler snake game")
    func assemblerSanke() {
        #expect(throws: Never.self, "transaltion went successfully") {
            var tokens = try Tokenizer.process(
                input: """
                .define appleL         $00 ; screen location of apple, low byte
                .define appleH         $01 ; screen location of apple, high byte
                .define snakeHeadL     $10 ; screen location of snake head, low byte
                .define snakeHeadH     $11 ; screen location of snake head, high byte
                .define snakeBodyStart $12 ; start of snake body byte pairs
                .define snakeDirection $02 ; direction (possible values are below)
                .define snakeLength    $03 ; snake length, in bytes

                ; Directions (each using a separate bit)
                .define movingUp      1
                .define movingRight   2
                .define movingDown    4
                .define movingLeft    8

                ; ASCII values of keys controlling the snake
                .define ASCII_w      $77
                .define ASCII_a      $61
                .define ASCII_s      $73
                .define ASCII_d      $64

                ; System variables
                .define sysRandom    $fe
                .define sysLastKey   $ff
                .define rom        $0600
                .define screen     $0200

                .org rom
                  jsr init
                  jsr loop

                init:
                  jsr initSnake
                  jsr generateApplePosition
                  rts


                initSnake:
                  lda #movingRight  ;start direction
                  sta snakeDirection

                  lda #4  ;start length (2 segments)
                  sta snakeLength

                  lda #$11
                  sta snakeHeadL

                  lda #$10
                  sta snakeBodyStart

                  lda #$0f
                  sta $14 ; body segment 1

                  lda #$04
                  sta snakeHeadH
                  sta $13 ; body segment 1
                  sta $15 ; body segment 2
                  rts


                generateApplePosition:
                  ;load a new random byte into $00
                  lda sysRandom
                  sta appleL

                  ;load a new random number from 2 to 5 into $01
                  lda sysRandom
                  and #$03 ;mask out lowest 2 bits
                  clc
                  adc #2
                  sta appleH

                  rts


                loop:
                  jsr readKeys
                  jsr checkCollision
                  jsr updateSnake
                  jsr drawApple
                  jsr drawSnake
                  jsr spinWheels
                  jmp loop


                readKeys:
                  lda sysLastKey
                  cmp #ASCII_w
                  beq upKey
                  cmp #ASCII_d
                  beq rightKey
                  cmp #ASCII_s
                  beq downKey
                  cmp #ASCII_a
                  beq leftKey
                  rts
                upKey:
                  lda #movingDown
                  bit snakeDirection
                  bne illegalMove

                  lda #movingUp
                  sta snakeDirection
                  rts
                rightKey:
                  lda #movingLeft
                  bit snakeDirection
                  bne illegalMove

                  lda #movingRight
                  sta snakeDirection
                  rts
                downKey:
                  lda #movingUp
                  bit snakeDirection
                  bne illegalMove

                  lda #movingDown
                  sta snakeDirection
                  rts
                leftKey:
                  lda #movingRight
                  bit snakeDirection
                  bne illegalMove

                  lda #movingLeft
                  sta snakeDirection
                  rts
                illegalMove:
                  rts


                checkCollision:
                  jsr checkAppleCollision
                  jsr checkSnakeCollision
                  rts


                checkAppleCollision:
                  lda appleL
                  cmp snakeHeadL
                  bne doneCheckingAppleCollision
                  lda appleH
                  cmp snakeHeadH
                  bne doneCheckingAppleCollision

                  ;eat apple
                  inc snakeLength
                  inc snakeLength ;increase length
                  jsr generateApplePosition
                doneCheckingAppleCollision:
                  rts


                checkSnakeCollision:
                  ldx #2 ;start with second segment
                snakeCollisionLoop:
                  lda snakeHeadL,x
                  cmp snakeHeadL
                  bne continueCollisionLoop

                maybeCollided:
                  lda snakeHeadH,x
                  cmp snakeHeadH
                  beq didCollide

                continueCollisionLoop:
                  inx
                  inx
                  cpx snakeLength          ;got to last section with no collision
                  beq didntCollide
                  jmp snakeCollisionLoop

                didCollide:
                  jmp gameOver
                didntCollide:
                  rts


                updateSnake:
                  ldx snakeLength
                  dex
                  txa
                updateloop:
                  lda snakeHeadL,x
                  sta snakeBodyStart,x
                  dex
                  bpl updateloop

                  lda snakeDirection
                  lsr
                  bcs up
                  lsr
                  bcs right
                  lsr
                  bcs down
                  lsr
                  bcs left
                up:
                  lda snakeHeadL
                  sec
                  sbc #$20
                  sta snakeHeadL
                  bcc upup
                  rts
                upup:
                  dec snakeHeadH
                  lda #$1
                  cmp snakeHeadH
                  beq collision
                  rts
                right:
                  inc snakeHeadL
                  lda #$1f
                  bit snakeHeadL
                  beq collision
                  rts
                down:
                  lda snakeHeadL
                  clc
                  adc #$20
                  sta snakeHeadL
                  bcs downdown
                  rts
                downdown:
                  inc snakeHeadH
                  lda #$6
                  cmp snakeHeadH
                  beq collision
                  rts
                left:
                  dec snakeHeadL
                  lda snakeHeadL
                  and #$1f
                  cmp #$1f
                  beq collision
                  rts
                collision:
                  jmp gameOver


                drawApple:
                  ldy #0
                  lda sysRandom
                  sta (appleL),y
                  rts


                drawSnake:
                  ldx snakeLength
                  lda #0
                  sta (snakeHeadL,x) ; erase end of tail

                  ldx #0
                  lda #1
                  sta (snakeHeadL,x) ; paint head
                  rts


                spinWheels:
                  ldx #0
                spinloop:
                  nop
                  nop
                  dex
                  bne spinloop
                  rts


                gameOver:
                """
            )
            try Linker.process(&tokens)
            let resultBytes = try Translator.process(tokens)

            let expectedBytes = memory { bytes in
                bytes.assign(
                    at: 0x0600, [
                        0x20, 0x06, 0x06, 0x20, 0x38, 0x06, 0x20, 0x0D, 0x06, 0x20, 0x2A, 0x06, 0x60, 0xA9, 0x02, 0x85,
                        0x02, 0xA9, 0x04, 0x85, 0x03, 0xA9, 0x11, 0x85, 0x10, 0xA9, 0x10, 0x85, 0x12, 0xA9, 0x0F, 0x85,
                        0x14, 0xA9, 0x04, 0x85, 0x11, 0x85, 0x13, 0x85, 0x15, 0x60, 0xA5, 0xFE, 0x85, 0x00, 0xA5, 0xFE,
                        0x29, 0x03, 0x18, 0x69, 0x02, 0x85, 0x01, 0x60, 0x20, 0x4D, 0x06, 0x20, 0x8D, 0x06, 0x20, 0xC3,
                        0x06, 0x20, 0x19, 0x07, 0x20, 0x20, 0x07, 0x20, 0x2D, 0x07, 0x4C, 0x38, 0x06, 0xA5, 0xFF, 0xC9,
                        0x77, 0xF0, 0x0D, 0xC9, 0x64, 0xF0, 0x14, 0xC9, 0x73, 0xF0, 0x1B, 0xC9, 0x61, 0xF0, 0x22, 0x60,
                        0xA9, 0x04, 0x24, 0x02, 0xD0, 0x26, 0xA9, 0x01, 0x85, 0x02, 0x60, 0xA9, 0x08, 0x24, 0x02, 0xD0,
                        0x1B, 0xA9, 0x02, 0x85, 0x02, 0x60, 0xA9, 0x01, 0x24, 0x02, 0xD0, 0x10, 0xA9, 0x04, 0x85, 0x02,
                        0x60, 0xA9, 0x02, 0x24, 0x02, 0xD0, 0x05, 0xA9, 0x08, 0x85, 0x02, 0x60, 0x60, 0x20, 0x94, 0x06,
                        0x20, 0xA8, 0x06, 0x60, 0xA5, 0x00, 0xC5, 0x10, 0xD0, 0x0D, 0xA5, 0x01, 0xC5, 0x11, 0xD0, 0x07,
                        0xE6, 0x03, 0xE6, 0x03, 0x20, 0x2A, 0x06, 0x60, 0xA2, 0x02, 0xB5, 0x10, 0xC5, 0x10, 0xD0, 0x06,
                        0xB5, 0x11, 0xC5, 0x11, 0xF0, 0x09, 0xE8, 0xE8, 0xE4, 0x03, 0xF0, 0x06, 0x4C, 0xAA, 0x06, 0x4C,
                        0x35, 0x07, 0x60, 0xA6, 0x03, 0xCA, 0x8A, 0xB5, 0x10, 0x95, 0x12, 0xCA, 0x10, 0xF9, 0xA5, 0x02,
                        0x4A, 0xB0, 0x09, 0x4A, 0xB0, 0x19, 0x4A, 0xB0, 0x1F, 0x4A, 0xB0, 0x2F, 0xA5, 0x10, 0x38, 0xE9,
                        0x20, 0x85, 0x10, 0x90, 0x01, 0x60, 0xC6, 0x11, 0xA9, 0x01, 0xC5, 0x11, 0xF0, 0x28, 0x60, 0xE6,
                        0x10, 0xA9, 0x1F, 0x24, 0x10, 0xF0, 0x1F, 0x60, 0xA5, 0x10, 0x18, 0x69, 0x20, 0x85, 0x10, 0xB0,
                        0x01, 0x60, 0xE6, 0x11, 0xA9, 0x06, 0xC5, 0x11, 0xF0, 0x0C, 0x60, 0xC6, 0x10, 0xA5, 0x10, 0x29,
                        0x1F, 0xC9, 0x1F, 0xF0, 0x01, 0x60, 0x4C, 0x35, 0x07, 0xA0, 0x00, 0xA5, 0xFE, 0x91, 0x00, 0x60,
                        0xA6, 0x03, 0xA9, 0x00, 0x81, 0x10, 0xA2, 0x00, 0xA9, 0x01, 0x81, 0x10, 0x60, 0xA2, 0x00, 0xEA,
                        0xEA, 0xCA, 0xD0, 0xFB, 0x60
                    ]
                )
            }
            #expect(resultBytes == expectedBytes, "assembler compiled input as expected")
        }
    }

    private func memory(modifing: ((inout [UInt8?]) -> Void) = { _ in }) -> [UInt8?] {
        var memory = [UInt8?](repeating: nil, count: 65_536)
        modifing(&memory)
        return memory
    }

}

extension Array {
    fileprivate mutating func assign(at: Int = 0, _ value: Self) {
        for i in at ..< at + value.count {
            self[i] = value[i - at]
        }
    }
}
