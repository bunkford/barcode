
import barcode
import wNim/[wApp, wFrame, wPanel, wStaticBitmap, wImage, wBitmap, wMemoryDC, wBrush, wPen ]

proc generateBarcode(code: string, tpye:int, widthFactor: int = 2, totalHeight:int = 30, color: wColor = wBlack):wImage =
  var barcodeData = getBarcodeData(code, tpye)
  var bc = MemoryDC()
  var size:wSize
  size.height = totalHeight
  size.width = barcodeData.maxWidth * widthFactor
  var blank = Bitmap(size)

  bc.selectObject(blank)
  bc.setBackground(wWhiteBrush)
  bc.setBrush(wWhiteBrush)
  bc.setPen(Pen(color=wWhite, width=0))
  
  bc.drawRectangle(0, 0, size.width, size.height) # draw border

  bc.setPen(Pen(color=wBlack, width=1))
  bc.setBrush(wBlackBrush) # set fill to black


  var positionHorizontal = 0
  for bar in barcodeData.bars:
    var barWidth = bar.width * widthFactor
    var barHeight = bar.height * totalHeight div barcodeData.maxHeight

    if bar.drawBar:
      var positionVertical = bar.positionVertical * totalHeight div barcodeData.maxHeight
      bc.drawRectangle(positionHorizontal, positionVertical, barWidth, barHeight)

    inc(positionHorizontal, barWidth)


  return Image(blank)

let app = App()
let frame = Frame(title="wNim Barcode Example", size=(400, 300))
let panel = Panel(frame)
let img = generateBarcode("90210-12345", TYPE_IMB, widthFactor=1, totalHeight=50)
let bmp_barcode = StaticBitmap(panel, bitmap=Bitmap(img), style=wSbAuto, pos=(100,100))
frame.center()
frame.show()
app.mainLoop()
