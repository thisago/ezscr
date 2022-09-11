# Source: https://github.com/Yardanico/nim-strenc/blob/master/src/strenc.nim
import hashes

proc b36f6b621036422ed69c60f642276196(s: string, key: int): string {.noinline.} =
  var k = key
  result = s
  for i in 0 ..< result.len:
    for f in [0, 8, 16, 24]:
      result[i] = chr(uint8(result[i]) xor uint8((k shr f) and 0xFF))
    k = k +% 1

const encodedCounter = hash(CompileTime & CompileDate) and 0x7FFFFFFF

proc encrypt*(data: string): string {.inline.} =
  b36f6b621036422ed69c60f642276196(data, encodedCounter)

template decrypt*(data: string): string =
  encrypt(data)
