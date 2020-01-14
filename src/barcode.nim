## Nim barcode library

## Returns raw data

import strutils, strtabs, re, math, tables, algorithm

type
  Barcode* = object
    width: int

type Bars* = object
  drawBar*: bool
  width*: int
  height*: int
  positionVertical*: int

type BarArray* = object
  code*: string
  maxWidth*: int
  maxHeight*: int
  bars*: seq[Bars]

const
  TYPE_CODE_39* = 1
  TYPE_CODE_39_CHECKSUM* = 2
  TYPE_CODE_39E* = 3
  TYPE_CODE_39E_CHECKSUM* = 4
  TYPE_CODE_93* = 5
  TYPE_STANDARD_2_5* = 6
  TYPE_STANDARD_2_5_CHECKSUM* = 7
  TYPE_INTERLEAVED_2_5* = 8
  TYPE_INTERLEAVED_2_5_CHECKSUM* = 9
  TYPE_CODE_128* = 10
  TYPE_CODE_128_A* = 11
  TYPE_CODE_128_B* = 12
  TYPE_CODE_128_C* = 13
  TYPE_EAN_2* = 14
  TYPE_EAN_5* = 15
  TYPE_EAN_8* = 16
  TYPE_EAN_13* = 17 
  TYPE_UPC_A* = 18
  TYPE_UPC_E* = 19
  TYPE_MSI* = 20
  TYPE_MSI_CHECKSUM* = 21
  TYPE_POSTNET* = 22
  TYPE_PLANET* = 23
  TYPE_RMS4CC* = 24
  TYPE_KIX* = 25
  TYPE_IMB* = 26
  TYPE_CODABAR* = 27 
  TYPE_CODE_11* = 28
  TYPE_PHARMA_CODE* = 29
  TYPE_PHARMA_CODE_TWO_TRACKS* = 30

proc barcode_code39*(code:string, extended:bool = false, checksum:bool = false): BarArray
proc barcode_code93*(code:string): BarArray
proc barcode_s25*(code:string, checksum:bool = false): BarArray
proc barcode_i25*(code:string, checksum:bool = false): BarArray
proc barcode_c128*(code:string, tpye:string = ""): BarArray
proc barcode_eanext*(code:string, len:int = 5): BarArray
proc barcode_eanupc*(code:string, len:int = 13): BarArray
proc barcode_msi*(code:string, checksum:bool = false): BarArray
proc barcode_postnet*(code:string, planet:bool = false): BarArray
proc barcode_rms4cc*(code:string, kix:bool = false): BarArray
proc barcode_imb*(code:string): BarArray
proc barcode_codabar*(code:string): BarArray
proc barcode_code11*(code:string): BarArray
proc barcode_pharmacode*(code:string): BarArray
proc barcode_pharmacode2t*(code:string): BarArray

proc binseq_to_array(se:string, bararray:BarArray): BarArray

proc imb_reverse_us(num:int):int
proc imb_tables(n:int, size:int):Table[int, int]
proc imb_crc11fcs(code_array:seq[string]): int
proc checksum_code93*(code:string): string
proc encode_code39_ext*(code:string): string
proc checksum_code39*(code:string): string
proc checksum_s25*(code:string): string
proc get128ABsequence*(code:string):seq[seq[string]]

proc getBarcodeData*(code: string, tpye: int):BarArray =
  ## Get raw barcode data for specified type.
  ##
  ## This can be used to draw the barcode using an image library.
  ##
  ## code:string = code to represent.
  ## tpye:int = barcode type (see constants)
  case tpye:

    of TYPE_CODE_39: # CODE 39 - ANSI MH10.8M-1983 - USD-3 - 3 of 9.
      return barcode_code39(code, false, false) 

    of TYPE_CODE_39_CHECKSUM: # CODE 39 with checksum
      return barcode_code39(code, false, true) 

    of TYPE_CODE_39E: # CODE 39 EXTENDED
      return barcode_code39(code, true, false) 

    of TYPE_CODE_39E_CHECKSUM: # CODE 39 EXTENDED + CHECKSUM
      return barcode_code39(code, true, true) 

    of TYPE_CODE_93: # CODE 93 - USS-93
      return barcode_code93(code) 

    of TYPE_STANDARD_2_5: # Standard 2 of 5
        return barcode_s25(code, false) 

    of TYPE_STANDARD_2_5_CHECKSUM: # Standard 2 of 5 + CHECKSUM
        return barcode_s25(code, true)
            
    of TYPE_INTERLEAVED_2_5: # Interleaved 2 of 5
        return barcode_i25(code, false)
            
    of TYPE_INTERLEAVED_2_5_CHECKSUM: # Interleaved 2 of 5 + CHECKSUM
        return barcode_i25(code, true)
            
    of TYPE_CODE_128: # CODE 128
        return barcode_c128(code, "")
            
    of TYPE_CODE_128_A: # CODE 128 A
        return barcode_c128(code, "A")
            
    of TYPE_CODE_128_B: # CODE 128 B
        return barcode_c128(code, "B")
            
    of TYPE_CODE_128_C: # CODE 128 C
        return barcode_c128(code, "C")
            
    of TYPE_EAN_2: # 2-Digits UPC-Based Extention
        return barcode_eanext(code, 2)
            
    of TYPE_EAN_5: # 5-Digits UPC-Based Extention
        return barcode_eanext(code, 5)
        
    of TYPE_EAN_8: # EAN 8
        return barcode_eanupc(code, 8)
        
    of TYPE_EAN_13: # EAN 13
        return barcode_eanupc(code, 13)
        
    of TYPE_UPC_A: # UPC-A
        return barcode_eanupc(code, 12)
            
    of TYPE_UPC_E: # UPC-E
        return barcode_eanupc(code, 6)
            
    of TYPE_MSI: # MSI (Variation of Plessey code)
        return barcode_msi(code, false)
            
    of TYPE_MSI_CHECKSUM: # MSI + CHECKSUM (modulo 11)
        return barcode_msi(code, true)
            
    of TYPE_POSTNET: # POSTNET
        return barcode_postnet(code, false)
            
    of TYPE_PLANET: # PLANET
        return barcode_postnet(code, true)
            
    of TYPE_RMS4CC: # RMS4CC (Royal Mail 4-state Customer Code) - CBC (Customer Bar Code)
        return barcode_rms4cc(code, false)
            
    of TYPE_KIX: # KIX (Klant index - Customer index)
        return barcode_rms4cc(code, true)
            
    of TYPE_IMB: # IMB - Intelligent Mail Barcode - Onecode - USPS-B-3200
        return barcode_imb(code)
            
    of TYPE_CODABAR: # CODABAR
        return barcode_codabar(code)
            
    of TYPE_CODE_11: # CODE 11
        return barcode_code11(code)   
    
    of TYPE_PHARMA_CODE: # PHARMACODE
        return barcode_pharmacode(code)
    
    of TYPE_PHARMA_CODE_TWO_TRACKS: # PHARMACODE TWO-TRACKS
        return barcode_pharmacode2t(code)
        
    else:
      # throw error
      raise newException(OSError, "Unknown type of barcode")


proc barcode_code39*(code:string, extended:bool, checksum:bool): BarArray =
  ## CODE 39 - ANSI MH10.8M-1983 - USD-3 - 3 of 9.
  ## General-purpose code in very wide use world-wide
  ##
  ## code:string = code to represent.
  ## extended: bool = if true uses the extended mode.
  ## checksum: bool = if true add a checksum to the code.
  ##
  ## return: array barcode representation.
  ##
  var c = toUpper(code)
  var chr = newStringTable()
  chr["0"] = "111331311"
  chr["1"] = "311311113"
  chr["2"] = "113311113"
  chr["3"] = "313311111"
  chr["4"] = "111331113"
  chr["5"] = "311331111"
  chr["6"] = "113331111"
  chr["7"] = "111311313"
  chr["8"] = "311311311"
  chr["9"] = "113311311"
  chr["A"] = "311113113"
  chr["B"] = "113113113"
  chr["C"] = "313113111"
  chr["D"] = "111133113"
  chr["E"] = "311133111"
  chr["F"] = "113133111"
  chr["G"] = "111113313"
  chr["H"] = "311113311"
  chr["I"] = "113113311"
  chr["J"] = "111133311"
  chr["K"] = "311111133"
  chr["L"] = "113111133"
  chr["M"] = "313111131"
  chr["N"] = "111131133"
  chr["O"] = "311131131"
  chr["P"] = "113131131"
  chr["Q"] = "111111333"
  chr["R"] = "311111331"
  chr["S"] = "113111331"
  chr["T"] = "111131331"
  chr["U"] = "331111113"
  chr["V"] = "133111113"
  chr["W"] = "333111111"
  chr["X"] = "131131113"
  chr["Y"] = "331131111"
  chr["Z"] = "133131111"
  chr["-"] = "131111313"
  chr["."] = "331111311"
  chr[" "] = "133111311"
  chr["$"] = "131313111"
  chr["/"] = "131311131"
  chr["+"] = "131113131"
  chr["%"] = "111313131"
  chr["*"] = "131131311"

  if extended:
    # extended mode
    c = encode_code39_ext(c)

  if checksum:
    # checksum
    c = c & checksum_code39(c)

  # add start and stop codes
  c = "*" & c & "*"

  var bararray:BarArray
  bararray.code = c
  bararray.maxWidth = 0
  bararray.maxHeight = 1
  
  for i in 0..<c.len:
    var ch = c[i]
    
    if chr.hasKey($ch) == false:
      raise newException(OSError, "Char " & $ch & " is unsupported")
    
    var drawBar: bool
    
    for j in 0..8:
      
      if j mod 2 == 0:
        drawBar = true # bar
      else:
        drawBar = false # space

      var width = parseInt($chr[$ch][j])
      bararray.bars.add(Bars(drawBar:drawBar, width:width, height:1, positionVertical:0))
    
    # intercharacter gap
    bararray.bars.add(Bars(drawBar:false, width:1, height:1, positionVertical:0))
    inc(bararray.maxWidth)

  return bararray

proc encode_code39_ext*(code:string): string =
  ## Encode a string to be used for CODE 39 Extended mode.
  ##
  ## code:string = code to represent.
  ##
  ## return: string encoded string.
  ##
  var c = code
  var encode = newStringTable()
  encode[$chr(0)] = "%U"
  encode[$chr(1)] = "$A"
  encode[$chr(2)] = "$B"
  encode[$chr(3)] = "$C"
  encode[$chr(4)] = "$D"
  encode[$chr(5)] = "$E"
  encode[$chr(6)] = "$F"
  encode[$chr(7)] = "$G"
  encode[$chr(8)] = "$H"
  encode[$chr(9)] = "$I"
  encode[$chr(10)] = "$J"
  encode[$chr(11)] = "£K"
  encode[$chr(12)] = "$L"
  encode[$chr(13)] = "$M"
  encode[$chr(14)] = "$N"
  encode[$chr(15)] = "$O"
  encode[$chr(16)] = "$P"
  encode[$chr(17)] = "$Q"
  encode[$chr(18)] = "$R"
  encode[$chr(19)] = "$S"
  encode[$chr(20)] = "$T"
  encode[$chr(21)] = "$U"
  encode[$chr(22)] = "$V"
  encode[$chr(23)] = "$W"
  encode[$chr(24)] = "$X"
  encode[$chr(25)] = "$Y"
  encode[$chr(26)] = "$Z"
  encode[$chr(27)] = "%A"
  encode[$chr(28)] = "%B"
  encode[$chr(29)] = "%C"
  encode[$chr(30)] = "%D"
  encode[$chr(31)] = "%E"
  encode[$chr(32)] = " "
  encode[$chr(33)] = "/A"
  encode[$chr(34)] = "/B"
  encode[$chr(35)] = "/C"
  encode[$chr(36)] = "/D"
  encode[$chr(37)] = "/E"
  encode[$chr(38)] = "/F"
  encode[$chr(39)] = "/G"
  encode[$chr(40)] = "/H"
  encode[$chr(41)] = "/I"
  encode[$chr(42)] = "/J"
  encode[$chr(43)] = "/K"
  encode[$chr(44)] = "/L"
  encode[$chr(45)] = "-"
  encode[$chr(46)] = "."
  encode[$chr(47)] = "/O"
  encode[$chr(48)] = "0"
  encode[$chr(49)] = "1"
  encode[$chr(50)] = "2"
  encode[$chr(51)] = "3"
  encode[$chr(52)] = "4"
  encode[$chr(53)] = "5"
  encode[$chr(54)] = "6"
  encode[$chr(55)] = "7"
  encode[$chr(56)] = "8"
  encode[$chr(57)] = "9"
  encode[$chr(58)] = "/Z"
  encode[$chr(59)] = "%F"
  encode[$chr(60)] = "%G"
  encode[$chr(61)] = "%H"
  encode[$chr(62)] = "%I"
  encode[$chr(63)] = "%J"
  encode[$chr(64)] = "%V"
  encode[$chr(65)] = "A"
  encode[$chr(66)] = "B"
  encode[$chr(67)] = "C"
  encode[$chr(68)] = "D"
  encode[$chr(69)] = "E"
  encode[$chr(70)] = "F"
  encode[$chr(71)] = "G"
  encode[$chr(72)] = "H"
  encode[$chr(73)] = "I"
  encode[$chr(74)] = "J"
  encode[$chr(75)] = "K"
  encode[$chr(76)] = "L"
  encode[$chr(77)] = "M"
  encode[$chr(78)] = "N"
  encode[$chr(79)] = "O"
  encode[$chr(80)] = "P"
  encode[$chr(81)] = "Q"
  encode[$chr(82)] = "R"
  encode[$chr(83)] = "S"
  encode[$chr(84)] = "T"
  encode[$chr(85)] = "U"
  encode[$chr(86)] = "V"
  encode[$chr(87)] = "W"
  encode[$chr(88)] = "X"
  encode[$chr(89)] = "Y"
  encode[$chr(90)] = "Z"
  encode[$chr(91)] = "%K"
  encode[$chr(92)] = "%L"
  encode[$chr(93)] = "%M"
  encode[$chr(94)] = "%N"
  encode[$chr(95)] = "%O"
  encode[$chr(96)] = "%W"
  encode[$chr(97)] = "+A"
  encode[$chr(98)] = "+B"
  encode[$chr(99)] = "+C"
  encode[$chr(100)] = "+D"
  encode[$chr(101)] = "+E"
  encode[$chr(102)] = "+F"
  encode[$chr(103)] = "+G"
  encode[$chr(104)] = "+H"
  encode[$chr(105)] = "+I"
  encode[$chr(106)] = "+J"
  encode[$chr(107)] = "+K"
  encode[$chr(108)] = "+L"
  encode[$chr(109)] = "+M"
  encode[$chr(110)] = "+N"
  encode[$chr(111)] = "+O"
  encode[$chr(112)] = "+P"
  encode[$chr(113)] = "+Q"
  encode[$chr(114)] = "+R"
  encode[$chr(115)] = "+S"
  encode[$chr(116)] = "+T"
  encode[$chr(117)] = "+U"
  encode[$chr(118)] = "+V"
  encode[$chr(119)] = "+W"
  encode[$chr(120)] = "+X"
  encode[$chr(121)] = "+Y"
  encode[$chr(122)] = "+Z"
  encode[$chr(123)] = "%P"
  encode[$chr(124)] = "%Q"
  encode[$chr(125)] = "%R"
  encode[$chr(126)] = "%S"
  encode[$chr(127)] = "%T"
  
  var code_ext:string = ""
  
  for i in 0..<code.len:
    if ord(code[i]) > 127:
      raise newException(OSError, "Only supports to char 127")
    
    code_ext = code_ext & encode[$code[i]]
  
  return code_ext

proc barcode_code93*(code:string): BarArray = 
  ## CODE 93 - USS-93
  ## Compact code similar to Code 39
  ##
  ## code:string = code to represent.
  ##
  ## return: array barcode representation.
  ##
  var c = toUpper(code)
  var chr = newStringTable()
  chr["48"] = "131112" # 0
  chr["49"] = "111213" # 1
  chr["50"] = "111312" # 2
  chr["51"] = "111411" # 3
  chr["52"] = "121113" # 4
  chr["53"] = "121212" # 5
  chr["54"] = "121311" # 6
  chr["55"] = "111114" # 7
  chr["56"] = "131211" # 8
  chr["57"] = "141111" # 9
  chr["65"] = "211113" # A
  chr["66"] = "211212" # B
  chr["67"] = "211311" # C
  chr["68"] = "221112" # D
  chr["69"] = "221211" # E
  chr["70"] = "231111" # F
  chr["71"] = "112113" # G
  chr["72"] = "112212" # H
  chr["73"] = "112311" # I
  chr["74"] = "122112" # J
  chr["75"] = "132111" # K
  chr["76"] = "111123" # L
  chr["77"] = "111222" # M
  chr["78"] = "111321" # N
  chr["79"] = "121122" # O
  chr["80"] = "131121" # P
  chr["81"] = "212112" # Q
  chr["82"] = "212211" # R
  chr["83"] = "211122" # S
  chr["84"] = "211221" # T
  chr["85"] = "221121" # U
  chr["86"] = "222111" # V
  chr["87"] = "112122" # W
  chr["88"] = "112221" # X
  chr["89"] = "122121" # Y
  chr["90"] = "123111" # Z
  chr["45"] = "121131" # -
  chr["46"] = "311112" # .
  chr["32"] = "311211" #
  chr["36"] = "321111" # $
  chr["47"] = "112131" # /
  chr["43"] = "113121" # +
  chr["37"] = "211131" # %
  chr["128"] = "121221" # ($)
  chr["129"] = "311121" # (/)
  chr["130"] = "122211" # (+)
  chr["131"] = "312111" # (%)
  chr["42"] = "111141" # start-stop
  var encode = newStringTable()
  encode[$chr(0)] = chr(131) & "U"
  encode[$chr(1)] = chr(128) & "A"
  encode[$chr(2)] = chr(128) & "B"
  encode[$chr(3)] = chr(128) & "C"
  encode[$chr(4)] = chr(128) & "D"
  encode[$chr(5)] = chr(128) & "E"
  encode[$chr(6)] = chr(128) & "F"
  encode[$chr(7)] = chr(128) & "G"
  encode[$chr(8)] = chr(128) & "H"
  encode[$chr(9)] = chr(128) & "I"
  encode[$chr(10)] = chr(128) & "J"
  encode[$chr(11)] = "£K"
  encode[$chr(12)] = chr(128) & "L"
  encode[$chr(13)] = chr(128) & "M"
  encode[$chr(14)] = chr(128) & "N"
  encode[$chr(15)] = chr(128) & "O"
  encode[$chr(16)] = chr(128) & "P"
  encode[$chr(17)] = chr(128) & "Q"
  encode[$chr(18)] = chr(128) & "R"
  encode[$chr(19)] = chr(128) & "S"
  encode[$chr(20)] = chr(128) & "T"
  encode[$chr(21)] = chr(128) & "U"
  encode[$chr(22)] = chr(128) & "V"
  encode[$chr(23)] = chr(128) & "W"
  encode[$chr(24)] = chr(128) & "X"
  encode[$chr(25)] = chr(128) & "Y"
  encode[$chr(26)] = chr(128) & "Z"
  encode[$chr(27)] = chr(131) & "A"
  encode[$chr(28)] = chr(131) & "B"
  encode[$chr(29)] = chr(131) & "C"
  encode[$chr(30)] = chr(131) & "D"
  encode[$chr(31)] = chr(131) & "E"
  encode[$chr(32)] = " "
  encode[$chr(33)] = chr(129) & "A"
  encode[$chr(34)] = chr(129) & "B"
  encode[$chr(35)] = chr(129) & "C"
  encode[$chr(36)] = chr(129) & "D"
  encode[$chr(37)] = chr(129) & "E"
  encode[$chr(38)] = chr(129) & "F"
  encode[$chr(39)] = chr(129) & "G"
  encode[$chr(40)] = chr(129) & "H"
  encode[$chr(41)] = chr(129) & "I"
  encode[$chr(42)] = chr(129) & "J"
  encode[$chr(43)] = chr(129) & "K"
  encode[$chr(44)] = chr(129) & "L"
  encode[$chr(45)] = "-"
  encode[$chr(46)] = "."
  encode[$chr(47)] = chr(129) & "O"
  encode[$chr(48)] = "0"
  encode[$chr(49)] = "1"
  encode[$chr(50)] = "2"
  encode[$chr(51)] = "3"
  encode[$chr(52)] = "4"
  encode[$chr(53)] = "5"
  encode[$chr(54)] = "6"
  encode[$chr(55)] = "7"
  encode[$chr(56)] = "8"
  encode[$chr(57)] = "9"
  encode[$chr(58)] = chr(129) & "Z"
  encode[$chr(59)] = chr(131) & "F"
  encode[$chr(60)] = chr(131) & "G"
  encode[$chr(61)] = chr(131) & "H"
  encode[$chr(62)] = chr(131) & "I"
  encode[$chr(63)] = chr(131) & "J"
  encode[$chr(64)] = chr(131) & "V"
  encode[$chr(65)] = "A"
  encode[$chr(66)] = "B"
  encode[$chr(67)] = "C"
  encode[$chr(68)] = "D"
  encode[$chr(69)] = "E"
  encode[$chr(70)] = "F"
  encode[$chr(71)] = "G"
  encode[$chr(72)] = "H"
  encode[$chr(73)] = "I"
  encode[$chr(74)] = "J"
  encode[$chr(75)] = "K"
  encode[$chr(76)] = "L"
  encode[$chr(77)] = "M"
  encode[$chr(78)] = "N"
  encode[$chr(79)] = "O"
  encode[$chr(80)] = "P"
  encode[$chr(81)] = "Q"
  encode[$chr(82)] = "R"
  encode[$chr(83)] = "S"
  encode[$chr(84)] = "T"
  encode[$chr(85)] = "U"
  encode[$chr(86)] = "V"
  encode[$chr(87)] = "W"
  encode[$chr(88)] = "X"
  encode[$chr(89)] = "Y"
  encode[$chr(90)] = "Z"
  encode[$chr(91)] = chr(131) & "K"
  encode[$chr(92)] = chr(131) & "L"
  encode[$chr(93)] = chr(131) & "M"
  encode[$chr(94)] = chr(131) & "N"
  encode[$chr(95)] = chr(131) & "O"
  encode[$chr(96)] = chr(131) & "W"
  encode[$chr(97)] = chr(130) & "A"
  encode[$chr(98)] = chr(130) & "B"
  encode[$chr(99)] = chr(130) & "C"
  encode[$chr(100)] = chr(130) & "D"
  encode[$chr(101)] = chr(130) & "E"
  encode[$chr(102)] = chr(130) & "F"
  encode[$chr(103)] = chr(130) & "G"
  encode[$chr(104)] = chr(130) & "H"
  encode[$chr(105)] = chr(130) & "I"
  encode[$chr(106)] = chr(130) & "J"
  encode[$chr(107)] = chr(130) & "K"
  encode[$chr(108)] = chr(130) & "L"
  encode[$chr(109)] = chr(130) & "M"
  encode[$chr(110)] = chr(130) & "N"
  encode[$chr(111)] = chr(130) & "O"
  encode[$chr(112)] = chr(130) & "P"
  encode[$chr(113)] = chr(130) & "Q"
  encode[$chr(114)] = chr(130) & "R"
  encode[$chr(115)] = chr(130) & "S"
  encode[$chr(116)] = chr(130) & "T"
  encode[$chr(117)] = chr(130) & "U"
  encode[$chr(118)] = chr(130) & "V"
  encode[$chr(119)] = chr(130) & "W"
  encode[$chr(120)] = chr(130) & "X"
  encode[$chr(121)] = chr(130) & "Y"
  encode[$chr(122)] = chr(130) & "Z"
  encode[$chr(123)] = chr(131) & "P"
  encode[$chr(124)] = chr(131) & "Q"
  encode[$chr(125)] = chr(131) & "R"
  encode[$chr(126)] = chr(131) & "S"
  encode[$chr(127)] = chr(131) & "T"
  var code_ext:string = ""
  for i in 0..<c.len:
    if ord(c[i]) > 127:
      raise newException(OSError, "Only supports to char 127")
    code_ext = code_ext & encode[$c[i]]
  
  # checksum
  code_ext = code_ext & checksum_code93(code_ext)
  c = "*" & code_ext & "*"

  var bararray:BarArray
  bararray.code = c
  bararray.maxWidth = 0
  bararray.maxHeight = 1

  for i in 0..<c.len:
    var ch = ord(c[i])
    if chr.hasKey($ch) == false:
      raise newException(OSError, "Char " & $ch & " is unsupported")
    
    var drawBar: bool

    for j in 0..<6:      
      if j mod 2 == 0:
        drawBar = true # bar
      else:
        drawBar = false # space
      
      var width = parseInt($chr[$ch][j])
      bararray.bars.add(Bars(drawBar:drawBar, width:width, height:1, positionVertical:0))
      inc(bararray.maxWidth)
    
  # intercharacter gap
  bararray.bars.add(Bars(drawBar:true, width:1, height:1, positionVertical:0))
  inc(bararray.maxWidth)

  return bararray
  

proc barcode_s25*(code:string, checksum:bool = false): BarArray = 
  ## Standard 2 of 5 barcodes.
  ## Used in airline ticket marking, photofinishing
  ## Contains digits (0 to 9) and encodes the data only in the width of bars.
  ##
  ## code:string = code to represent
  ## checksum:bool = if checsum should be added
  ##
  ## return = array barcode representation
  ##
  var c = toUpper(code)
  var chr = newStringTable()
  chr["0"] = "10101110111010"
  chr["1"] = "11101010101110"
  chr["2"] = "10111010101110"
  chr["3"] = "11101110101010"
  chr["4"] = "10101110101110"
  chr["5"] = "11101011101010"
  chr["6"] = "10111011101010"
  chr["7"] = "10101011101110"
  chr["8"] = "10101110111010"
  chr["9"] = "10111010111010"
  
  if checksum:
    c = c & checksums25(c)
  
  if c.len mod 2 != 0:
    # add leading zero if code-length is odd
    c = "0" & c
  
  var se:string = "11011010"
  for i in 0..<c.len:
    var digit = c[i]
    if chr.hasKey($digit) == false:
      raise newException(OSError, "Char " & $digit & " is unsupported")
    se = se & chr[$digit]

  se = se & "1101011"
  var bararray:BarArray
  bararray.code = c
  bararray.maxWidth = 0
  bararray.maxHeight = 1

  return binseq_to_array(se, bararray)

proc binseq_to_array(se:string, bararray:BarArray): BarArray =
  var width = 0
  var ba:BarArray = bararray

  for i in 0..<se.len:
    inc(width)
    if (i == se.len - 1) or (i < se.len - 1 and se[i] != se[i + 1]):
      var drawBar: bool
      if $se[i] == "1":
        drawBar = true
      else:
        drawBar = false

      ba.bars.add(Bars(drawBar:drawBar, width:width, height:1, positionVertical:0))
      inc(ba.maxWidth, width)
      width = 0
  
  return ba

proc barcode_i25*(code:string, checksum:bool = false): BarArray = 
  ## Interleaved 2 of 5 barcodes.
  ## Compact numeric code, widely used in industry, air cargo
  ## Contains digits (0 to 9) and encodes the data in the width of both bars and spaces.
  ##
  ## code:string = code to represent
  ## checksum:bool = if checsum should be added
  ##
  ## return = array barcode representation
  ##
  var c = code
  var chrs = newStringTable()
  chrs["0"] = "11221"
  chrs["1"] = "21112"
  chrs["2"] = "12112"
  chrs["3"] = "22111"
  chrs["4"] = "11212"
  chrs["5"] = "21211"
  chrs["6"] = "12211"
  chrs["7"] = "11122"
  chrs["8"] = "21121"
  chrs["9"] = "12121"
  chrs["A"] = "11"
  chrs["Z"] = "21"
  
  if checksum:
    c = c & checksum_s25(c)
  
  if c.len mod 2 != 0:
    # add leading zero if code-length is odd
    c = "0" & c

  # add start and stop codes
  c = "AA" & toLower(c) & "ZA"

  var bararray:BarArray
  bararray.code = c
  bararray.maxWidth = 0
  bararray.maxHeight = 1

  for i in countup(0, c.len - 1, step=2):
    var char_bar = c[i]
    var char_space = c[i + 1]
    if chrs.hasKey($char_bar) == false or chrs.hasKey($char_space) == false:
      raise newException(OSError, "Character is unsupported")
    
    # create a bar-space sequence
    var se = ""
    for s in 0..<chrs[$char_bar].len:
      se = se & chrs[$char_bar][s] & chrs[$char_space][s]

    for j in 0..<se.len:
      var drawBar: bool
      if j mod 2 == 0:
        drawBar = true
      else:
        drawBar = false
      
      var width = parseInt($se[j])
      bararray.bars.add(Bars(drawBar:drawBar, width:width, height:1, positionVertical:0))
      inc(bararray.maxWidth, width)

  return bararray

proc barcode_c128*(code:string, tpye:string = ""): BarArray = 
  ## C128 barcodes.
  ## Very capable code, excellent density, high reliability; in very wide use world-wide
  ##
  ## code:string = code to represent.
  ## type:string = barcode type: A, B, C or empty for automatic switch (AUTO mode)
  ##
  ## return = array barcode representation.
  ## 
  var c = code
  var chars:array[0 .. 107, string]
  chars[0] = "212222" # 00
  chars[1] = "222122" # 01
  chars[2] = "222221" # 02
  chars[3] = "121223" # 03
  chars[4] = "121322" # 04
  chars[5] = "131222" # 05
  chars[6] = "122213" # 06
  chars[7] = "122312" # 07
  chars[8] = "132212" # 08
  chars[9] = "221213" # 09
  chars[10] = "221312" # 10
  chars[11] = "231212" # 11
  chars[12] = "112232" # 12
  chars[13] = "122132" # 13
  chars[14] = "122231" # 14
  chars[15] = "113222" # 15
  chars[16] = "123122" # 16
  chars[17] = "123221" # 17
  chars[18] = "223211" # 18
  chars[19] = "221132" # 19
  chars[20] = "221231" # 20
  chars[21] = "213212" # 21
  chars[22] = "223112" # 22
  chars[23] = "312131" # 23
  chars[24] = "311222" # 24
  chars[25] = "321122" # 25
  chars[26] = "321221" # 26
  chars[27] = "312212" # 27
  chars[28] = "322112" # 28
  chars[29] = "322211" # 29
  chars[30] = "212123" # 30
  chars[31] = "212321" # 31
  chars[32] = "232121" # 32
  chars[33] = "111323" # 33
  chars[34] = "131123" # 34
  chars[35] = "131321" # 35
  chars[36] = "112313" # 36
  chars[37] = "132113" # 37
  chars[38] = "132311" # 38
  chars[39] = "211313" # 39
  chars[40] = "231113" # 40
  chars[41] = "231311" # 41
  chars[42] = "112133" # 42
  chars[43] = "112331" # 43
  chars[44] = "132131" # 44
  chars[45] = "113123" # 45
  chars[46] = "113321" # 46
  chars[47] = "133121" # 47
  chars[48] = "313121" # 48
  chars[49] = "211331" # 49
  chars[50] = "231131" # 50
  chars[51] = "213113" # 51
  chars[52] = "213311" # 52
  chars[53] = "213131" # 53
  chars[54] = "311123" # 54
  chars[55] = "311321" # 55
  chars[56] = "331121" # 56
  chars[57] = "312113" # 57
  chars[58] = "312311" # 58
  chars[59] = "332111" # 59
  chars[60] = "314111" # 60
  chars[61] = "221411" # 61
  chars[62] = "431111" # 62
  chars[63] = "111224" # 63
  chars[64] = "111422" # 64
  chars[65] = "121124" # 65
  chars[66] = "121421" # 66
  chars[67] = "141122" # 67
  chars[68] = "141221" # 68
  chars[69] = "112214" # 69
  chars[70] = "112412" # 70
  chars[71] = "122114" # 71
  chars[72] = "122411" # 72
  chars[73] = "142112" # 73
  chars[74] = "142211" # 74
  chars[75] = "241211" # 75
  chars[76] = "221114" # 76
  chars[77] = "413111" # 77
  chars[78] = "241112" # 78
  chars[79] = "134111" # 79
  chars[80] = "111242" # 80
  chars[81] = "121142" # 81
  chars[82] = "121241" # 82
  chars[83] = "114212" # 83
  chars[84] = "124112" # 84
  chars[85] = "124211" # 85
  chars[86] = "411212" # 86
  chars[87] = "421112" # 87
  chars[88] = "421211" # 88
  chars[89] = "212141" # 89
  chars[90] = "214121" # 90
  chars[91] = "412121" # 91
  chars[92] = "111143" # 92
  chars[93] = "111341" # 93
  chars[94] = "131141" # 94
  chars[95] = "114113" # 95
  chars[96] = "114311" # 96
  chars[97] = "411113" # 97
  chars[98] = "411311" # 98
  chars[99] = "113141" # 99
  chars[100] = "114131" # 100
  chars[101] = "311141" # 101
  chars[102] = "411131" # 102
  chars[103] = "211412" # 103 START A
  chars[104] = "211214" # 104 START B
  chars[105] = "211232" # 105 START C
  chars[106] = "233111" # STOP
  chars[107] = "200000" # END
  
  # ASCII characters for CODE A (ASCII 00 - 95)
  var keys_a = " !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_"
  keys_a = keys_a & chr(0) & chr(1) & chr(2) & chr(3) & chr(4) & chr(5) & chr(6) & chr(7) & chr(8) & chr(9)
  keys_a = keys_a & chr(10) & chr(11) & chr(22) & chr(13) & chr(14) & chr(15) & chr(16) & chr(17) & chr(18) & chr(19)
  keys_a = keys_a & chr(20) & chr(21) & chr(22) & chr(23) & chr(24) & chr(25) & chr(26) & chr(27) & chr(28) & chr(29)
  keys_a = keys_a & chr(30) & chr(31)

  # ASCII characters for CODE B (ASCII 32 - 127)
  var keys_b = " !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~" & chr(127)
  
  # special codes
  var fnc_a = newStringTable()
  fnc_a["241"] = "102"
  fnc_a["242"] = "97"
  fnc_a["243"] = "96"
  fnc_a["244"] = "101"

  var fnc_b = newStringTable()
  fnc_b["241"] = "102"
  fnc_b["242"] = "97"
  fnc_b["243"] = "96"
  fnc_b["244"] = "100"
  
  # array of symbols
  var startid: int
  var code_data:seq[string]
  case toUpper(tpye):
    of "A": # MODE A
      startid = 103
      for i in 0..<c.len:
        var ch = c[i]
        var ch_id = ord(ch)
        if ch_id >= 241 and ch_id <= 244:
          code_data.add(fnc_a[$ch_id])
        elif ch_id >= 0 and ch_id <= 95:
          code_data.add($(find(keys_a, $ch)))
        else:
          raise newException(OSError, "Character " & ch & " is unsupported")
    of "B": # MODE B
      startid = 104
      for i in 0..<c.len:
        var ch = c[i]
        var ch_id = ord(ch)
        if ch_id >= 241 and ch_id <= 244:
          code_data.add(fnc_b[$ch_id])
        elif ch_id >= 32 and ch_id <= 127:
          code_data.add($find(keys_b, $ch))
        else:
          raise newException(OSError, "Character " & ch & " is unsupported")
    of "C": # MODE C
      startid = 105
      if ord(c[0]) == 241:
        code_data.add($102)
        c = c[1..c.high]
      
      if c.len mod 2 != 0:
        raise newException(OSError, "Length must be even")

      for i in countup(0, c.len - 1, step=2):
        var chrnum = c[i] & c[i + 1]
        if match(chrnum, re"([0-9]{2})"):
          code_data.add($chrnum)
        else:
          raise newException(OSError, "Invalid Character")     

    else: # MODE Auto   
      # split code into sequences
      var sequence: seq[seq[string]]
      # get numeric sequences (if any)
      var numseq = findAll(c, re"([0-9]){4,}") # find all number sequences >= 4 digits
      
      if numseq.len > 0:

        var end_offset = 0
        for val in numseq:
          var v: string = val
          var offset = find(c, val)
          
          # numeric sequence
          var slen = v.len
          if slen mod 2 != 0:
            # the length must be event
            inc(offset)
            v = v[1..v.high]

          if offset > end_offset:
            # non numeric sequence
            for t in get128ABsequence(code[end_offset..offset - end_offset - 1]):
              sequence.add(t)

          slen = v.len
          if slen mod 2 != 0:
            # the length must be even
            dec(slen)

          sequence.add(@["C", code[offset..offset + slen - 1], $slen, "false"])
          end_offset = offset + slen
        
        if end_offset < code.len:
          for t in get128ABsequence(code[end_offset..code.high]):
            sequence.add(t)
    
      else:
        # text code (non C mode)
        for t in get128ABsequence(code):
          sequence.add(t)
      
      for k, v in sequence:
        case v[0]:
          of "A": # MODE A
            if k == 0:
              startid = 103
            elif sequence[k - 1][0] != "A":
              if v[2] == "1" and k > 0 and sequence[k - 1][0] == "B" and sequence[k - 1][3] != "false": 
                # single charachter shift
                code_data.add("98")
                sequence[k][3] = "true"
              elif sequence[k - 1][3] != "true":
                code_data.add("101")
        
              for i in 0..v[2].parseInt - 1:
                var cha = v[1][i]
                var cha_id = ord(cha)

                if cha_id >= 241 and cha_id <= 244:
                  code_data.add(fnc_a[$cha_id])
                else:
                  code_data.add($find(keys_a, cha))
            
          of "B": # MODE B
            if k == 0:
              var tmpchr = ord(v[1][0])

              if v[2] == "1" and tmpchr >= 241 and tmpchr <= 244 and sequence[k + 1][0] != "B":
                case sequence[k + 1][0]:
                  of "A":
                    startid = 103
                    sequence[k][0] = "A"
                    code_data.add(fnc_a[$tmpchr])
                  of "C":
                    startid = 105
                    sequence[k][0] = "C"
                    code_data.add(fnc_a[$tmpchr])

              else:
                startid = 104

            elif sequence[k - 1][0] != "B":
              if v[2] == "1" and k > 0 and sequence[k - 1][0] == "A" and sequence[k - 1][3] != "false":
                # single character shift
                code_data.add("98")
                # mark shift
                sequence[k][3] = "true"
              elif sequence[k - 1][3] != "true":
                code_data.add("100")

            for i in 0..v[2].parseInt - 1:
              var cha = v[1][i]
              var cha_id = ord(cha)
              if cha_id >= 241 and cha_id <= 244:
                code_data.add(fnc_b[$cha_id])
              else:
                code_data.add($find(keys_b, cha))

          of "C": # MODE C
            if k == 0:
              startid = 105
            elif sequence[k - 1][0] != "C":
              code_data.add("99")
            
            for i in countup(0, v[2].parseInt - 1, 2):
              var chrnum = v[1][i] & v[1][i + 1]
              code_data.add(chrnum)
            
          else:
            discard        
    
  # calculate check character
  var sum = startid
  for k, v in code_data:
    inc(sum, parseInt(v) * (k + 1))
  
  code_data.add($(sum mod 103))
  # add stop sequence
  code_data.add("106")
  code_data.add("107")

  # add start code at the beginning
  code_data.insert($startid,0)

  var bararray:BarArray
  bararray.code = c
  bararray.maxWidth = 0
  bararray.maxHeight = 1

  for val in code_data:
    var se = chars[parseInt(val)]
    for j in 0..<6:
      var drawBar: bool
      if j mod 2 == 0:
        drawBar = true
      else:
        drawBar = false
      
      var width = parseInt($se[j])
      bararray.bars.add(Bars(drawBar:drawBar, width:width, height:1, positionVertical:0))
      inc(bararray.maxWidth, width)
  
  return bararray
        
proc barcode_eanupc*(code:string, len:int = 13): BarArray = 
  ## EAN13 and UPC-A barcodes.
  ## EAN13: European Article Numbering international retail product code
  ## UPC-A: Universal product code seen on almost all retail products in the USA and Canada
  ## UPC-E: Short version of UPC symbol
  ##
  ## code:string = code to represent.
  ## len:int = barcode type: 6 = UPC-E, 8 = EAN8, 13 = EAN13, 12 = UPC-A
  ##
  ## return = array barcode representation.
  ## 
  var l = len
  var c = code

  var upce = false

  if l == 6:
    l = 12
    upce = true

  var data_len = l - 1
  # Padding
  c = align(c, data_len, '0')
  var code_len = c.len

  # Calculate check digit
  var sum_a = 0
  for i in countup(1, data_len-1, 2):
    if i < c.len:
      inc(sum_a, parseInt($c[i]))

  if l > 12:
    sum_a = sum_a * 3
  
  var sum_b = 0
  for i in countup(0, data_len, 2):
    inc(sum_b, parseInt($c[i]))
  
  if l < 13:
    sum_b = sum_b * 3

  var r = (sum_a + sum_b) mod 10

  if r > 0:
    r = 10 - r

  if code_len == data_len:
    # Add check digit
    c = c & $r

  elif r != parseInt($c[data_len]):
    raise newException(OSError, "Invalid Check Digit")  

  if l == 12:
    # UPC-A
    c = "0" & c
    inc(l)

  var upce_code:string
  if upce:
    # convert UPC-A to UPC-E
    var tmp = c[4..6]
    
    if tmp == "000" or tmp == "100" or tmp == "200":
      # Manufacturer code, ends in 000, 100 or 200
      upce_code = c[2..3] & c[9..11] & c[4..4]
    
    else:
      tmp = c[5..6]
      if tmp == "00":
        # Manufacurer code, ends in 00
        upce_code = c[2..4] & c[10..11] & "3"
      else:
        tmp = $c[6]
        if tmp == "0":
          # Manufacturer code ends in 0
          upce_code = c[2..5] & $c[11] & "4"
        else:
          # Manufacturer code does not end in zero
          upce_code = c[2..6] & $c[11]
    
  # Convert digits to bars
  var codes_a = newStringTable() # left odd parity
  codes_a["0"] = "0001101"
  codes_a["1"] = "0011001"
  codes_a["2"] = "0010011"
  codes_a["3"] = "0111101"
  codes_a["4"] = "0100011"
  codes_a["5"] = "0110001"
  codes_a["6"] = "0101111"
  codes_a["7"] = "0111011"
  codes_a["8"] = "0110111"
  codes_a["9"] = "0001011"

  var codes_b = newStringTable() # left even parity
  codes_b["0"] = "0100111"
  codes_b["1"] = "0110011"
  codes_b["2"] = "0011011"
  codes_b["3"] = "0100001"
  codes_b["4"] = "0011101"
  codes_b["5"] = "0111001"
  codes_b["6"] = "0000101"
  codes_b["7"] = "0010001"
  codes_b["8"] = "0001001"
  codes_b["9"] = "0010111"

  var codes_c = newStringtable() # right
  codes_c["0"] = "1110010"
  codes_c["1"] = "1100110"
  codes_c["2"] = "1101100"
  codes_c["3"] = "1000010"
  codes_c["4"] = "1011100"
  codes_c["5"] = "1001110"
  codes_c["6"] = "1010000"
  codes_c["7"] = "1000100"
  codes_c["8"] = "1001000"
  codes_c["9"] = "1110100"

  var parities: array[0..9,array[0..5, string]]
  parities[0] = ["A", "A", "A", "A", "A", "A"]
  parities[1] = ["A", "A", "B", "A", "B", "B"]
  parities[2] = ["A", "A", "B", "B", "A", "B"]
  parities[3] = ["A", "A", "B", "B", "B", "A"]
  parities[4] = ["A", "B", "A", "A", "B", "B"]
  parities[5] = ["A", "B", "B", "A", "A", "B"]
  parities[6] = ["A", "B", "B", "B", "A", "A"]
  parities[7] = ["A", "B", "A", "B", "A", "B"]
  parities[8] = ["A", "B", "A", "B", "B", "A"]
  parities[9] = ["A", "B", "B", "A", "B", "A"]

  var upce_parities: array[0..1, array[0..59, array[0..5, string]]]

  upce_parities[0][0] = ["B", "B", "B", "A", "A", "A"]
  upce_parities[0][1] = ["B", "B", "A", "B", "A", "A"]
  upce_parities[0][2] = ["B", "B", "A", "A", "B", "A"]
  upce_parities[0][3] = ["B", "B", "A", "A", "A", "B"]
  upce_parities[0][4] = ["B", "A", "B", "B", "A", "A"]
  upce_parities[0][5] = ["B", "A", "A", "B", "B", "A"]
  upce_parities[0][6] = ["B", "A", "A", "A", "B", "B"]
  upce_parities[0][7] = ["B", "A", "B", "A", "B", "A"]
  upce_parities[0][8] = ["B", "A", "B", "A", "A", "B"]
  upce_parities[0][9] = ["B", "A", "A", "B", "A", "B"]

  upce_parities[1][0] = ["A", "A", "A", "B", "B", "B"]
  upce_parities[1][1] = ["A", "A", "B", "A", "B", "B"]
  upce_parities[1][2] = ["A", "A", "B", "B", "A", "B"]
  upce_parities[1][3] = ["A", "A", "B", "B", "B", "A"]
  upce_parities[1][4] = ["A", "B", "A", "A", "B", "B"]
  upce_parities[1][5] = ["A", "B", "B", "A", "A", "B"]
  upce_parities[1][6] = ["A", "B", "B", "B", "A", "A"]
  upce_parities[1][7] = ["A", "B", "A", "B", "A", "B"]
  upce_parities[1][8] = ["A", "B", "A", "B", "B", "A"]
  upce_parities[1][9] = ["A", "B", "B", "A", "B", "A"]

  var se = "101" # left guard bar
  var bararray:BarArray
  
  if upce:
    bararray.code = upce_code
    bararray.maxWidth = 0
    bararray.maxHeight = 1

    var p = upce_parities[parseInt($c[1])][r]
    for i in 0..5:
      case p[i]:
        of "A":
          se = se & codes_a[$upce_code[i]]
        of "B":
          se = se & codes_b[$upce_code[i]]
        of "C":
          se = se & codes_c[$upce_code[i]]
        else:
          discard
    se = se & "010101" # right guard bar

  else:
    bararray.code = c
    bararray.maxWidth = 0
    bararray.maxHeight = 1
    
    var half_len = ceil(l / 2)
    if l == 8:
      for i in 0..half_len.toInt - 1:
        se = se & codes_a[$c[i]]

    else:
      var p = parities[parseInt($c[0])]
      for i in 1..half_len.toInt - 1:
        case p[i - 1]:
          of "A":
            se = se & codes_a[$c[i]]
          of "B":
            se = se & codes_b[$c[i]]
          of "C":
            se = se & codes_c[$c[i]]
          else:
            discard

    se = se & "01010" # center gaurd bar
    for i in half_len.toInt..l - 1:
      if codes_c.hasKey($c[i]) == false:
        raise newException(OSError, "Char " & $c[i] & " not allowed")
      se = se & codes_c[$c[i]]
    
    se = se & "101" # right gaurd bar

  var clen = se.len
  var width = 0
  for i in 0..clen - 1:
    inc(width)
    if (i == clen - 1) or (i < clen - 1 and se[i] != se[i + 1]): # TODO SOMETHING ISN'T RIGHT HERE
      var drawBar: bool
      if se[i] == '1':
        drawBar = true

      else:
        drawBar = false
      
      bararray.bars.add(Bars(drawBar:drawBar, width:width, height:1, positionVertical:0))
      inc(bararray.maxWidth, width)
      width = 0

  return bararray
        
proc barcode_eanext*(code:string, len:int = 5): BarArray = 
  ## UPC-Based Extensions
  ## 2-Digit Ext.: Used to indicate magazines and newspaper issue numbers
  ## 5-Digit Ext.: Used to mark suggested retail price of books
  ##
  ## code:string = code to represent.
  ## len:int = barcode type: 2 = 2-Digit, 5 = 5-Digit
  ##
  ## return = array barcode representation.
  ## 
  var c = code
  var l = len
  
  try:
    discard c.parseInt
  except:
    raise newException(OSError, "Code needs to be numeric for this type of barcode")

  # Padding
  c = align(c, l, '0')
  # Calculate check digit
  var r: int
  if l == 2:
    r = c.parseInt mod 4
  elif l == 5:
    r = (3 * (parseInt($c[0]) + parseInt($c[2]) + parseInt($c[4]))) + (9 * (parseInt($c[1]) + parseInt($c[3])))
    r = r mod 10
  else:
    raise newException(OSError, "Invalid check digit")    

  # Convert digits to bars
  var codes_a = newStringTable() # left odd parity
  codes_a["0"] = "0001101"
  codes_a["1"] = "0011001"
  codes_a["2"] = "0010011"
  codes_a["3"] = "0111101"
  codes_a["4"] = "0100011"
  codes_a["5"] = "0110001"
  codes_a["6"] = "0101111"
  codes_a["7"] = "0111011"
  codes_a["8"] = "0110111"
  codes_a["9"] = "0001011"

  var codes_b = newStringTable() # left even parity
  codes_b["0"] = "0100111"
  codes_b["1"] = "0110011"
  codes_b["2"] = "0011011"
  codes_b["3"] = "0100001"
  codes_b["4"] = "0011101"
  codes_b["5"] = "0111001"
  codes_b["6"] = "0000101"
  codes_b["7"] = "0010001"
  codes_b["8"] = "0001001"
  codes_b["9"] = "0010111"

  var parities: array[0..6, array[0..59, array[0..4, string]]]

  parities[2][0] = ["A", "A", "", "", ""]
  parities[2][1] = ["A", "B", "", "", ""]
  parities[2][2] = ["B", "A", "", "", ""]
  parities[2][3] = ["B", "B", "", "", ""]
  
  parities[5][0] = ["B", "B", "A", "A", "A"]
  parities[5][1] = ["B", "A", "B", "A", "A"]
  parities[5][2] = ["B", "A", "A", "B", "A"]
  parities[5][3] = ["B", "A", "A", "A", "B"]
  parities[5][4] = ["A", "B", "B", "A", "A"]
  parities[5][5] = ["A", "A", "B", "B", "A"]
  parities[5][6] = ["A", "A", "A", "B", "B"]
  parities[5][7] = ["A", "B", "A", "B", "A"]
  parities[5][8] = ["A", "B", "A", "A", "B"]
  parities[5][9] = ["A", "A", "B", "A", "B"]

  var p = parities[l][r]
  var se = "1011" # left gaurd bar
  case p[0]:
    of "A":
      se = se & codes_a[$c[0]]
    of "B":
      se = se & codes_b[$c[0]]
  
  for i in 1..l - 1:
    se = se & "01"
    case p[i]:
      of "A":
        se = se & codes_a[$c[i]]
      of "B":
        se = se & codes_b[$c[i]]

  var bararray:BarArray  
  bararray.code = c
  bararray.maxWidth = 0
  bararray.maxHeight = 1
  return binseq_to_array(se, bararray)



proc barcode_msi*(code:string, checksum:bool = false): BarArray = 
  ## MSI
  ## Variation of Plessey code, with similar applications
  ## Contains digits (0 to 9) and encodes the data only in the width of bars.
  ##
  ## code:string = code to represent.
  ## checksum:bool = if true add a checksum to the code (modulo 11)
  ##
  ## return = array barcode representation.
  ## 
  var c = code
  var chrs = newStringTable()
  chrs["0"] = "100100100100"
  chrs["1"] = "100100100110"
  chrs["2"] = "100100110100"
  chrs["3"] = "100100110110"
  chrs["4"] = "100110100100"
  chrs["5"] = "100110100110"
  chrs["6"] = "100110110100"
  chrs["7"] = "100110110110"
  chrs["8"] = "110100100100"
  chrs["9"] = "110100100110"
  chrs["A"] = "110100110100"
  chrs["B"] = "110100110110"
  chrs["C"] = "110110100100"
  chrs["D"] = "110110100110"
  chrs["E"] = "110110110100"
  chrs["F"] = "110110110110"
  
  if checksum:
    # Add checksum
    var clen = c.len
    var p = 2
    var check = 0
    for i in countdown(clen - 1, 0, 1):
      var t = ($c[i]).parseHexInt
      check = check + (t * p)
      inc(p)
      if p > 7:
        p = 2
    
    check = check mod 11
    if check > 0:
      check = 11 - check

    c = c & $check

  var se = "110" # left gaurd 
  var clen = c.len
  for i in 0..clen - 1:
    var digit = $c[i]
    if chrs.hasKey(digit) == false:
      raise newException(OSError, "Char " & digit & " is unsupported digit")
    se = se & chrs[digit]
  
  se = se & "1001" # right gaurd 
  var bararray:BarArray  
  bararray.code = c
  bararray.maxWidth = 0
  bararray.maxHeight = 1
  return binseq_to_array(se, bararray)

proc barcode_postnet*(code:string, planet:bool = false): BarArray = 
  ## POSTNET and PLANET barcodes.
  ## Used by U.S. Postal Service for automated mail sorting
  ## Contains digits (0 to 9) and encodes the data only in the width of bars.
  ##
  ## code:string = zip code to represent. Must be a string containing a zip code of the form DDDDD or DDDDD-DDDD.
  ## planet:bool = if true print the PLANET barcode, otherwise print POSTNET
  ##
  ## return = array barcode representation.
  ## 
  var c = code
  var barlen: array[0..9, array[0..4, int]]
  if planet:
    barlen[0] = [1, 1, 2, 2, 2]
    barlen[1] = [2, 2, 2, 1, 1]
    barlen[2] = [2, 2, 1, 2, 1]
    barlen[3] = [2, 2, 1, 1, 2]
    barlen[4] = [2, 1, 2, 2, 1]
    barlen[5] = [2, 1, 2, 1, 2]
    barlen[6] = [2, 1, 1, 2, 2]
    barlen[7] = [1, 2, 2, 2, 1]
    barlen[8] = [1, 2, 2, 1, 2]
    barlen[9] = [1, 2, 1, 2, 2]
  else:
    barlen[0] = [2, 2, 1, 1, 1]
    barlen[1] = [1, 1, 1, 2, 2]
    barlen[2] = [1, 1, 2, 1, 2]
    barlen[3] = [1, 1, 2, 2, 1]
    barlen[4] = [1, 2, 1, 1, 2]
    barlen[5] = [1, 2, 1, 2, 1]
    barlen[6] = [1, 2, 2, 1, 1]
    barlen[7] = [2, 1, 1, 1, 2]
    barlen[8] = [2, 1, 1, 2, 1]
    barlen[9] = [2, 1, 2, 1, 1]

  var bararray:BarArray
  bararray.code = c
  bararray.maxWidth = 0
  bararray.maxHeight = 2

  c = replace(c, "-", "")
  c = replace(c, " ", "")
  var l = c.len
  # Calculate checksum
  var sum = 0
  for i in 0..l - 1:
    sum = sum + parseInt($c[i])
  
  var chkd = sum mod 10
  if chkd > 0:
    chkd = 10 - chkd

  c = c & $chkd
  l = c.len
  
  # Start bar
  bararray.bars.add(Bars(drawBar:true, width:1, height:2, positionVertical:0))
  bararray.bars.add(Bars(drawBar:false, width:1, height:2, positionVertical:0))
  inc(bararray.maxWidth, 2)
  for i in 0..l - 1:
    for j in 0..4:
      var h = barlen[parseInt($c[i])][j]
      var p = floor((1 div h).toFloat)
      bararray.bars.add(Bars(drawBar:true, width:1, height:h, positionVertical:p.toInt))
      bararray.bars.add(Bars(drawBar:false, width:1, height:2, positionVertical:0))
      inc(bararray.maxWidth, 2)
  
  # End bar
  bararray.bars.add(Bars(drawBar:true, width:1, height:2, positionVertical:0))
  inc(bararray.maxWidth)
  
  return bararray

proc barcode_rms4cc*(code:string, kix:bool = false): BarArray = 
  ## RMS4CC - CBC - KIX
  ## RMS4CC (Royal Mail 4-state Customer Code) - CBC (Customer Bar Code) - KIX (Klant index - Customer index)
  ## RM4SCC is the name of the barcode symbology used by the Royal Mail for its Cleanmail service.
  ##
  ## code:string = zip code to represent. Must be a string containing a zip code of the form DDDDD or DDDDD-DDDD.
  ## kix:bool = if true prints the KIX variation (doesn't use the start and end symbols, and the checksum)
  ##    - in this case the house number must be sufficed with an X and placed at the end of the code.
  ##
  ## return = array barcode representation.
  ## 
  var c = toUpper(code)
  var notkix:bool = not kix
  # bar mode
  # 1 = pos 1, length 2
  # 2 = pos 1, length 3
  # 3 = pos 2, length 1
  # 4 = pos 2, length 2
  var barmode = newStringTable()
  barmode["0"] = "3322"
  barmode["1"] = "3412"
  barmode["2"] = "3421"
  barmode["3"] = "4312"
  barmode["4"] = "4321"
  barmode["5"] = "4411"
  barmode["6"] = "3142"
  barmode["7"] = "3232"
  barmode["8"] = "3241"
  barmode["9"] = "4132"
  barmode["A"] = "4141"
  barmode["B"] = "4231"
  barmode["C"] = "3124"
  barmode["D"] = "3214"
  barmode["E"] = "3223"
  barmode["F"] = "4114"
  barmode["G"] = "4123"
  barmode["H"] = "4213"
  barmode["I"] = "1342"
  barmode["J"] = "1432"
  barmode["K"] = "1441"
  barmode["L"] = "2332"
  barmode["M"] = "2341"
  barmode["N"] = "2431"
  barmode["O"] = "1324"
  barmode["P"] = "1414"
  barmode["Q"] = "1423"
  barmode["R"] = "2314"
  barmode["S"] = "2323"
  barmode["T"] = "2413"
  barmode["U"] = "1144"
  barmode["V"] = "1234"
  barmode["W"] = "1243"
  barmode["X"] = "2134"
  barmode["Y"] = "2143"
  barmode["Z"] = "2233"
  var l = c.len
  var bararray:BarArray
  bararray.code = c
  bararray.maxWidth = 0
  bararray.maxHeight = 3
  if notkix:
    # table for checksum calculations (row, col)
    var checktable = newStringTable()
    checktable["0"] = "11"
    checktable["1"] = "12"
    checktable["2"] = "13"
    checktable["3"] = "14"
    checktable["4"] = "15"
    checktable["5"] = "10"
    checktable["6"] = "21"
    checktable["7"] = "22"
    checktable["8"] = "23"
    checktable["9"] = "24"
    checktable["A"] = "25"
    checktable["B"] = "20"
    checktable["C"] = "31"
    checktable["D"] = "32"
    checktable["E"] = "33"
    checktable["F"] = "34"
    checktable["G"] = "35"
    checktable["H"] = "30"
    checktable["I"] = "41"
    checktable["J"] = "42"
    checktable["K"] = "43"
    checktable["L"] = "44"
    checktable["M"] = "45"
    checktable["N"] = "40"
    checktable["O"] = "51"
    checktable["P"] = "52"
    checktable["Q"] = "53"
    checktable["R"] = "54"
    checktable["S"] = "55"
    checktable["T"] = "50"
    checktable["U"] = "01"
    checktable["V"] = "02"
    checktable["W"] = "03"
    checktable["X"] = "04"
    checktable["Y"] = "05"
    checktable["Z"] = "00"
    var row, col:int
    for i in 0..l - 1:
      inc(row, parseInt($checktable[$c[i]][0]))
      inc(col, parseInt($checktable[$c[i]][1]))
    
    row = row mod 6
    col = col mod 6
    var chk:string
    for k, v in checktable:
      if v == $row & $col:
        chk = k
    
    c = c & chk
    inc(l)
  
  if notkix:
    # start bar
    bararray.bars.add(Bars(drawBar:true, width:1, height:2, positionVertical:0))
    bararray.bars.add(Bars(drawBar:false, width:1, height:2, positionVertical:0))
    inc(bararray.maxWidth, 2)
  
  var p, h: int
  for i in 0..l - 1:
    for j in 0..3:
      case barmode[$c[i]][j]:
        of '1':
          p = 0
          h = 2
        of '2':
          p = 0
          h = 3
        of '3':
          p = 1
          h = 1
        of '4':
          p = 1
          h = 2
        else:
          discard
      
      bararray.bars.add(Bars(drawBar:true, width:1, height:h, positionVertical:p))
      bararray.bars.add(Bars(drawBar:false, width:1, height:2, positionVertical:0))
      inc(bararray.maxWidth, 2)
  
  if notkix:
    # stop bar
    bararray.bars.add(Bars(drawBar:true, width:1, height:3, positionVertical:0))
    inc(bararray.maxWidth, 1)
  
  return bararray

proc barcode_codabar*(code:string): BarArray = 
  ## CODABAR barcodes.
  ## Older code often used in library systems, sometimes in blood banks
  ##
  ## code:string = code to represent
  ##
  ## return = array barcode representation.
  ## 
  var c = code
  var chrs = newStringTable()
  chrs["0"] = "11111221"
  chrs["1"] = "11112211"
  chrs["2"] = "11121121"
  chrs["3"] = "22111111"
  chrs["4"] = "11211211"
  chrs["5"] = "21111211"
  chrs["6"] = "12111121"
  chrs["7"] = "12112111"
  chrs["8"] = "12211111"
  chrs["9"] = "21121111"
  chrs["-"] = "11122111"
  chrs["$"] = "11221111"
  chrs[":"] = "21112121"
  chrs["/"] = "21211121"
  chrs["."] = "21212111"
  chrs["+"] = "11222221"
  chrs["A"] = "11221211"
  chrs["B"] = "12121121"
  chrs["C"] = "11121221"
  chrs["D"] = "11122211"
  var bararray:BarArray
  bararray.code = c
  bararray.maxWidth = 0
  bararray.maxHeight = 1
  var w: int
  var se:string
  c = "A" & toUpper(c) & "A"
  var l = c.len
  for i in 0..l - 1:
    if chrs.hasKey($c[i]) == false:
      raise newException(OSError, "Char " & $c[i] & " is unsupported")
    se = chrs[$c[i]]
    var drawBar: bool
    for j in 0..7:
      if j mod 2 == 0:
        drawBar = true
      else:
        drawBar = false
      w = parseInt($se[i])
      bararray.bars.add(Bars(drawBar:drawBar, width:w, height:1, positionVertical:0))
      inc(bararray.maxWidth, w)
  
  return bararray

proc barcode_code11*(code:string): BarArray = 
  ## CODE11 barcodes.
  ## Older code often used in library systems, sometimes in blood banks
  ##
  ## code:string = code to represent
  ##
  ## return = array barcode representation.
  ## 
  var c = code
  var chrs = newStringTable()
  chrs["0"] = "111121"
  chrs["1"] = "211121"
  chrs["2"] = "121121"
  chrs["3"] = "221111"
  chrs["4"] = "112121"
  chrs["5"] = "212111"
  chrs["6"] = "122111"
  chrs["7"] = "111221"
  chrs["8"] = "211211"
  chrs["9"] = "211111"
  chrs["-"] = "112111"
  chrs["S"] = "112211"
  var bararray:BarArray
  bararray.code = c
  bararray.maxWidth = 0
  bararray.maxHeight = 1
  var w: int
  var se:string
  var l = c.len
  # calculate check digit C
  var p = 1
  var check:string = "0"
  var digit:string
  var dval: int
  for i in countdown(l - 1, 0, 1):
    var digit = $c[i]
    if digit == "-":
      dval = 10
    else:
      dval = parseInt($digit)
    
    check = $(parseInt(check) + (dval * p))
    inc(p)
    if p > 10:
      p = 1

  check = $(parseInt(check) mod 11)

  if check == "10":
    check = "-"
  
  c = c & $check

  if l > 10:
    # calculate check digit k
    p = 1
    check = "0"
    for i in countdown(l, 0, 1):
      digit = $c[i]
      if digit == "-":
        dval = 10
      else:
        dval = parseInt($digit)
      check = $(parseInt(check) + (dval * p))
      inc(p)
      if p > 9:
        p = 1
    
    check = $(parseInt(check) mod 11)

    c = c & $check

    inc(l)
  
  c = "S" & c & "S"
  inc(l, 3)
  for i in 0..l - 1:
    if chrs.hasKey($c[i]) == false:
      raise newException(OSError, "Char " & $c[i] & " is unsupported")
    
    se = chrs[$c[i]]
    
    var drawBar: bool
    for j in 0..5:
      if j mod 2 == 0:
        drawBar = true
      else:
        drawBar = false
      
      w = parseInt($se[j])
      bararray.bars.add(Bars(drawBar:drawBar, width:w, height:1, positionVertical:0))
      inc(bararray.maxWidth, w)
      
  return bararray

proc barcode_pharmacode*(code:string): BarArray = 
  ## Pharmacode
  ## Contains digits (0 to 9)
  ##
  ## code:string = code to represent
  ##
  ## return = array barcode representation.
  ## 
  var c = parseInt($code)
  var se:string
  while c > 0:
    if c mod 2 == 0:
      se = se & "11100"
      c = c - 2
    else:
      se = se & "100"
      c = c - 1
    c = c div 2
  
  se = se[0..^2]
  # reverse string
  for i in 0 .. se.high div 2:
    swap(se[i], se[se.high - i])
  
  var bararray:BarArray
  bararray.code = $c
  bararray.maxWidth = 0
  bararray.maxHeight = 1

  return binseq_to_array(se, bararray)

proc barcode_pharmacode2t*(code:string): BarArray = 
  ## Pharmacode two-track
  ## Contains digits (0 to 9)
  ##
  ## code:string = code to represent
  ##
  ## return = array barcode representation.
  ## 
  var c = parseInt($code)
  var se :string
  while c != 0:
    case c mod 3:
      of 0:
        se = se & "3"
        c = (c - 3) div 3
      of 1:
        se = se & "1"
        c = (c - 1) div 3
      of 2:
        se = se & "2"
        c = (c - 2) div 3
      else:
        discard
  # reverse string
  for i in 0 .. se.high div 2:
    swap(se[i], se[se.high - i])

  var bararray:BarArray
  bararray.code = $c
  bararray.maxWidth = 0
  bararray.maxHeight = 2

  var l = se.len
  var p, h:int
  for i in 0..l - 1:
    case se[i]:
      of '1':
        p = 1
        h = 1
      of '2':
        p = 0
        h = 1
      of '3':
        p = 0
        h = 2
      else:
        discard
        
    bararray.bars.add(Bars(drawBar:true, width:1, height:h, positionVertical:p))
    bararray.bars.add(Bars(drawBar:false, width:1, height:2, positionVertical:0))
    inc(bararray.maxWidth, 2)
  
  bararray.bars.delete(bararray.bars.len)
  dec(bararray.maxWidth, 1)
  
  return bararray


proc barcode_imb*(code:string): BarArray = 
  ## IMB - Intelligent Mail Barcode - Onecode - USPS-B-3200
  ## Intelligent Mail barcode is a 65-bar code for use on mail in the United States.
  ## The fields are described as follows:
  ##  - The Barcode Identifier shall be assigned by USPS to encode the presort identification that is currently 
  ##    printed in human readable form on the optional endorsement line (OEL) as well as for future USPS use. This shall 
  ##    be two digits, with the second digit in the range of 0–4. The allowable encoding ranges shall be 00–04, 10–14, 
  ##    20–24, 30–34, 40–44, 50–54, 60–64, 70–74, 80–84, and 90–94.
  ##  - The Service Type Identifier shall be assigned by USPS for any combination of services requested on the mailpiece. 
  ##    The allowable encoding range shall be 000–999. Each 3-digit value shall correspond to a particular mail class with 
  ##    a particular combination of service(s). Each service program, such as OneCode Confirm and OneCode ACS, 
  ##    shall provide the list of Service Type Identifier values.
  ##  - The Mailer or Customer Identifier shall be assigned by USPS as a unique, 6 or 9 digit number that identifies a 
  ##    business entity. The allowable encoding range for the 6 digit Mailer ID shall be 000000-899999, 
  ##    while the allowable encoding range for the 9 digit Mailer ID shall be 900000000-999999999.
  ##  - The Serial or Sequence Number shall be assigned by the mailer for uniquely identifying and tracking mailpieces. 
  ##    The allowable encoding range shall be 000000000–999999999 when used with a 6 digit Mailer ID and 000000-999999 when
  ##    used with a 9 digit Mailer ID. e. The Delivery Point ZIP Code shall be assigned by the mailer for routing the
  ##    mailpiece. This shall replace POSTNET for routing the mailpiece to its final delivery point. The length may be
  ##    0, 5, 9, or 11 digits. The allowable encoding ranges shall be no ZIP Code, 00000–99999,  000000000–999999999,
  ##    and 00000000000–99999999999.
  ##
  ## code:string = code to represent. , separate the ZIP (routing code) from the rest using a minus char '-' (BarcodeID_ServiceTypeID_MailerID_SerialNumber-RoutingCode)
  ##
  ## return = array barcode representation.
  ## 
  var c = code
  var asc_chr = [4,0,2,6,3,5,1,9,8,7,1,2,0,6,4,8,2,9,5,3,0,1,3,7,4,6,8,9,2,0,5,1,9,4,3,8,6,7,1,2,4,3,9,5,7,8,3,0,2,1,4,0,9,1,7,0,2,4,6,3,7,1,9,5,8]
  var dsc_chr = [7,1,9,5,8,0,2,4,6,3,5,8,9,7,3,0,6,1,7,4,6,8,9,2,5,1,7,5,4,3,8,7,6,0,2,5,4,9,3,0,1,6,8,2,0,4,5,9,6,7,5,2,6,3,8,5,1,9,8,7,4,0,2,6,3]
  var asc_pos = [3,0,8,11,1,12,8,11,10,6,4,12,2,7,9,6,7,9,2,8,4,0,12,7,10,9,0,7,10,5,7,9,6,8,2,12,1,4,2,0,1,5,4,6,12,1,0,9,4,7,5,10,2,6,9,11,2,12,6,7,5,11,0,3,2]
  var dsc_pos = [2,10,12,5,9,1,5,4,3,9,11,5,10,1,6,3,4,1,10,0,2,11,8,6,1,12,3,8,6,4,4,11,0,6,1,9,11,5,3,7,3,10,7,11,8,2,10,3,5,8,0,3,12,11,8,4,5,1,3,0,7,12,9,8,10]
  var code_arr = c.split("-")
  var tracking_number = code_arr[0]
  var routing_code:string
  var binary_code: string
  if code_arr.len == 2:
    routing_code = code_arr[1]
  else:
    routing_code = ""
  
  # conversion of routing code
  case routing_code.len:
    of 0:
      binary_code = "0";
    of 5:
      binary_code = $(parseInt($routing_code) + 1)
    of 9:
      binary_code = $(parseInt($routing_code) + 100001)
    of 11:
      binary_code = $(parseInt($routing_code) + 1000100001)
    else:
      raise newException(OSError, "Routing Code Unknown")
  
  binary_code = $(parseInt(binary_code) * 10)
  binary_code = $(parseInt(binary_code) + parseInt($tracking_number[0]))
  binary_code = $(parseInt(binary_code) * 5)
  binary_code = $(parseInt(binary_code) + parseInt($tracking_number[1]))
  binary_code = binary_code & $tracking_number[2..tracking_number.high]
  # convert to hexadecimal
  binary_code = toHex(parseInt($binary_code))
  # pad to get 13 bytes
  binary_code = align(binary_code, 26, '0')
  # convert string to array of bytes
  var binary_code_arr:seq[string]
  for i in countup(0, binary_code.len - 1, 2):
    binary_code_arr.add(binary_code[i] & binary_code[i + 1])
  
  # calculate the check sequence
  var fcs = imb_crc11fcs(binary_code_arr)
  # exclude first 2 bits from first byte
  var first_byte =  align($((fromHex[int](binary_code_arr[0]) shl 2) shr 2), 2, '0')
  var binary_code_102bit = first_byte & binary_code[2..binary_code.high]
  
  # convert binary data to codewords
  var codewords: seq[int]
  var data = fromHex[int](binary_code_102bit)
  codewords.add((data mod 636) * 2)
  data = data div 636
  for i in 1..8:
    codewords.add(data mod 1365)
    data = data div 1365
  
  codewords.add(data)
  if fcs shr 10 == 1:
    codewords[9] = codewords[9] + 659

  # generate lookup tables
  var table2of13 = imb_tables(2, 78);
  var table5of13 = imb_tables(5, 1287);

  # convert codewards to characters
  var characters: seq[int]
  var bitmask = 512
  for k, val in codewords:
    var charcode: int
    if val <= 1286:
      charcode = table5of13[val]
    else:
      charcode = table2of13[val - 1287]
    
    if (fcs and bitmask) > 0:
      # bitwise invert
      charcode = ((not charcode) and 8191)
    
    characters.add(charcode)
    bitmask = bitmask div 2
  
  characters.reverse()
  
  # build bars
  var bararray:BarArray
  bararray.code = $c
  bararray.maxWidth = 0
  bararray.maxHeight = 3

  for i in 0..64:
    var asc, dsc: int
    if (characters[asc_chr[i]] and (2 ^ asc_pos[i])) > 0:
      asc = 1
    else:
      asc = 0
    
    if (characters[dsc_chr[i]] and (2 ^ dsc_pos[i])) > 0:
      dsc = 1
    else:
      dsc = 0

    var p, h: int
    if (asc and dsc) == 1:
      # full bar (F)
      p = 0
      h = 3
    elif asc == 1:
      # acender (A)
      p = 0
      h = 2
    elif dsc == 1:
      # descender (D)
      p = 1
      h = 2
    else:
      # tracker (T)
      p = 1
      h = 1
    
    bararray.bars.add(Bars(drawBar:true, width:1, height:h, positionVertical:p))
    bararray.bars.add(Bars(drawBar:false, width:1, height:2, positionVertical:0))
    inc(bararray.maxWidth, 2)

  bararray.bars.delete(bararray.bars.len)
  dec(bararray.maxWidth, 1)
  
  return bararray
  





proc imb_tables(n:int, size:int):Table[int, int] =
  var tab = initTable[int, int]()
  var lli = 0 # LUT lower index
  var lui = size - 1 # LUT upper index
  for count in 0..8191:
    var bit_count = 0
    for bit_index in 0..12:
      if (count and (1 shl bit_index)) != 0:
        bit_count = bit_count + 1
      else:
        bit_count = bit_count + 0
    
    # if we don't have the right number of bits on, go on to the next value
    if bit_count == n:
      var reverse = imb_reverse_us(count) shr 3

      if reverse >= count:
        # if count is symmetric, place it at the first free slot from the end of the list
        # otherwise, place it at the first free slot from the beginning of the list and place referce at the next free slot from the beginning of the list
        if reverse == count:
          if tab.hasKeyOrPut(lui, count):
            tab[lui] = count
          dec(lui)
        else:
          if tab.hasKeyOrPut(lli, count):
            tab[lli] = count
          inc(lli)
          if tab.hasKeyOrPut(lli, reverse):
            tab[lli] = reverse
          inc(lli)

  return tab

        

proc imb_reverse_us(num:int):int =
  var rev = 0
  var n = num
  for i in 0..15:
    rev = rev shl 1
    rev = rev or (n and 1)
    n = n shr 1

  return rev

proc imb_crc11fcs(code_array:seq[string]): int =
  var genpoly = 0x0F35 # generator polynominal
  var fcs = 0x07FF # frame check sequence

  # do most significant byte skipping the 2 most significant bits
  var data = fromHex[int](code_array[0]) shl 5
  for bit in 2..7:
    if ((fcs xor data) and 0x400) == 0x400:
      fcs = (fcs shl 1) xor genpoly
    else:
      fcs = fcs shl 1

    fcs = fcs and 0x7FF
    data = data shl 1

  # do rest of bytes
  for byt in 1..12: 
    data = fromHex[int](code_array[byt]) shl 3
    for bit in 0..7:
      if ((fcs xor data) and 0x400) == 0x400:
        fcs = (fcs shl 1) xor genpoly
      else:
        fcs = (fcs shl 1)
      
      fcs = fcs and 0x7FF
      data = data shl 1
  
  return fcs




proc checksum_s25*(code:string): string =
  var c = code
  var l = c.len
  var sum:int
  
  for i in countup(0, l - 1, 2):
    sum = sum + parseInt($c[i])
  
  sum = sum * 3

  for i in countup(1, l - 1, 2):
    sum = sum + parseInt($c[i])
  
  var r = sum mod 10
  if r > 0:
    r = 10 - r
  
  return $r


proc checksum_code93(code:string):string =
  ## Calculate CODE 93 checksum (modulo 47).
  ##
  ## code: string = code to represent
  ##
  ## return: string = checksum code
  var chars:array[0 .. 46, string]
  chars[0] = "0"
  chars[1] = "1"
  chars[2] = "2"
  chars[3] = "3"
  chars[4] = "4"
  chars[5] = "5"
  chars[6] = "6"
  chars[7] = "7"
  chars[8] = "8"
  chars[9] = "9"
  chars[10] = "A"
  chars[11] = "B"
  chars[12] = "C"
  chars[13] = "D"
  chars[14] = "E"
  chars[15] = "F"
  chars[16] = "G"
  chars[17] = "H"
  chars[18] = "I"
  chars[19] = "J"
  chars[20] = "K"
  chars[21] = "L"
  chars[22] = "M"
  chars[23] = "N"
  chars[24] = "O"
  chars[25] = "P"
  chars[26] = "Q"
  chars[27] = "R"
  chars[28] = "S"
  chars[29] = "T"
  chars[30] = "U"
  chars[31] = "V"
  chars[32] = "W"
  chars[33] = "X"
  chars[34] = "Y"
  chars[35] = "Z"
  chars[36] = "-"
  chars[37] = "."
  chars[38] = " "
  chars[39] = "$"
  chars[40] = "/"
  chars[41] = "+"
  chars[42] = "%"
  chars[43] = "<"
  chars[44] = "="
  chars[45] = ">"
  chars[46] = "?"

  # translate special cahracters
  var c = code.replace(chr(128) & chr(131) & chr(129) & chr(130), "<=>?")
  
  # calculate check digit C
  var p:int = 1
  var check:int = 0
  var i = c.len - 1
  while i >= 0:
    var k = chars.find($c[i]) 
    inc(check, k * p)
    inc(p)
    if p > 20:
      p = 1
    dec(i)
  
  check = check mod 47
  var check_digit_c = chars[check]
  c = c & check_digit_c

  # calculate check digit K
  p = 1
  check = 0
  i = c.len - 1
  while i >= 0:
    var k = chars.find($c[i]) 
    inc(check, k * p)
    inc(p)
    if p > 15:
      p = 1
    dec(i)

  check = check mod 47
  var check_digit_k = chars[check]
  var checksum = check_digit_c & check_digit_k
  checksum = checksum.replace("<=>?", chr(128) & chr(131) & chr(129) & chr(130))

  return checksum
  
proc checksum_code39*(code:string): string =
  var chars:array[0 .. 42, string]
  chars[0] = "0"
  chars[1] = "1"
  chars[2] = "2"
  chars[3] = "3"
  chars[4] = "4"
  chars[5] = "5"
  chars[6] = "6"
  chars[7] = "7"
  chars[8] = "8"
  chars[9] = "9"
  chars[10] = "A"
  chars[11] = "B"
  chars[12] = "C"
  chars[13] = "D"
  chars[14] = "E"
  chars[15] = "F"
  chars[16] = "G"
  chars[17] = "H"
  chars[18] = "I"
  chars[19] = "J"
  chars[20] = "K"
  chars[21] = "L"
  chars[22] = "M"
  chars[23] = "N"
  chars[24] = "O"
  chars[25] = "P"
  chars[26] = "Q"
  chars[27] = "R"
  chars[28] = "S"
  chars[29] = "T"
  chars[30] = "U"
  chars[31] = "V"
  chars[32] = "W"
  chars[33] = "X"
  chars[34] = "Y"
  chars[35] = "Z"
  chars[36] = "-"
  chars[37] = "."
  chars[38] = " "
  chars[39] = "$"
  chars[40] = "/"
  chars[41] = "+"
  chars[42] = "%"
  var sum = 0
  for i in 0..<code.len:
    var k = chars.find($code[i])
    inc(sum, k)
  var j = (sum mod 43)

  return chars[j]

proc get128ABsequence(code:string): seq[seq[string]] =

  var len = code.len
  var sequence:seq[seq[string]]
  # get sequences (if any)
  var numseq = findAll(code, re"([\x00-\x1f])") 
  var end_offset = 0
  if numseq.len > 0:
    for val in numseq:
      var v: string = val
      var offset = find(code, val, 0)
      if offset > end_offset:
        # B sequence
        sequence.add(@["B", code[end_offset..offset - end_offset - 1], $(offset - end_offset), "false"])
      # A sequence
      var slen = v.len
      inc(end_offset, offset + slen)
      sequence.add(@["A", code[offset..end_offset - 1], $(slen), "false"])
    
    if end_offset < len:
      sequence.add(@["B", code[end_offset..code.high], $(len - end_offset), "false"])

  else:
    # Only B sequence
    sequence.add(@["B", code, $len])

  return sequence


proc htmlBarcode*(code:string, tpye:int, widthFactor:int = 2, totalHeight:int = 30, color: string = "black"):string =
  ## html representation of barcode data. 
  ##
  ## code:string = code to represent.
  ## type:int = barcode type (see constants)
  ## widthFactor:int = width factor for bars
  ## totalHeight:int = total height of barcode
  ## color:string = HTML color of bars
  ##
  ## return = string of html representing barcode
  ## 
  ## This should give you an example of how to use the data to draw barcode.
  var barcodeData = getBarcodeData(code, tpye)
  var html = "<div style='font-size:0;position:relative;width:" & $(barcodeData.maxWidth * widthFactor) & "px;height:" & $totalHeight & "px;'>\n"
  var positionHorizontal = 0
  for bar in barcodeData.bars:
    var barWidth = bar.width * widthFactor
    var barHeight = bar.height * totalHeight div barcodeData.maxHeight
    
    if bar.drawBar:
      var positionVertical = bar.positionVertical * totalHeight div barcodeData.maxHeight
      html = html & "\t<div style='background-color: black;width:" & $barWidth & "px;height:" & $barHeight & "px;position:absolute;left:" & $positionHorizontal & "px;top:" & $positionVertical & "px;'>&nbsp;</div>\n"
    
    inc(positionHorizontal, barWidth)

  html = html & "</div>\n"

  return html