coffee_draw = (p5) ->
  p5.setup =  ->
    p5.size $(window).width(), $(window).height(), p5.P3D
    p5.createRandomGenerationData()
    p5.newGeneration()

  p5.newGeneration = ->
      # Ok, visualize the landscape space
    @land = new Landscape(p5)
    @theta = 0.0;
    
  
  #Change these values to affect the starting generation
  p5.createRandomGenerationData =  ->
    @curGenData = 
      cellSize : 10
      width : 800
      height : 400
    
  p5.draw =  ->
    p5.background(255)
    p5.pushMatrix()
    p5.translate(p5.width/2, p5.height/2+20, -160)
    p5.rotateX(p5.PI/3);
    p5.rotateZ(@theta)
    @land.render()
    p5.popMatrix()

    @land.calculate()

    @theta += 0.0025
    
    
  p5.skip =  ->
    p5.createRandomGenerationData()
    p5.newGeneration()

#Before we mate, make sure we have two parent generations already liked from which to mate from
#Also we need to save curGenBefore to prevGen before we modify it
  p5.like = ->
    # if @prevGenData? then @prevPrevGenData = @prevGenData
    # @prevGenData = @curGenData
    # if @prevPrevGenData? then p5.mate() else p5.newGeneration()


#Go through each value from previous two generations, which act as parents, and mate their results together
  # p5.mate = ->
  #   for key of @prevPrevGenData
  #     p5.mateAttribute(key)
  #     p5.newGeneration()


  # p5.mateAttribute = (key) ->
  #   @curGenData[key] = (@prevGenData[key] + @prevPrevGenData[key]) * 0.5
    


class Landscape
  #data we need to create beans
  constructor: (@p5) ->
    @landData = @p5.curGenData
    @numCols = @landData.width/@landData.cellSize
    @numRows = @landData.height/@landData.cellSize
    @heightValues = @createEmpty2DArray(@numCols, @numRows)
    @cellSize = @landData.cellSize
    @zoff = 2.0 #perlin noise argument

  #calculate height values
  calculate: ->
    xoff = 0
    for i in [0...@numCols] by 1
      yoff = 0
      for j in [0...@numRows] by 1
        @heightValues[i][j] = @p5.map(@p5.noise(xoff, yoff, @zoff), 0, 1, -120, 120);
        yoff += 0.1
      @zoff += 0.1


  #Render landscape as a grid of quads
  render: ->
    #every cell is an individual quad
    for x in [0...@heightValues.length-1] by 1
      for y in [0...@heightValues[x].length-1] by 1
        #one quad at a time
        #each quds color determined by height value at each vertex
        #@p5.stroke(255)
        @p5.fill(100, 100)
        @p5.pushMatrix()
        @p5.beginShape(@p5.QUADS)
        @p5.translate(x * @cellSize - @landData.width/2, y * @cellSize - @landData.height/2, 0) #finds current pos in grid?
        @p5.vertex(0, 0, @heightValues[x][y])
        @p5.vertex(@cellSize, 0, @heightValues[x+1][y])
        @p5.vertex(@cellSize, @cellSize, @heightValues[x+1][y+1])
        @p5.vertex(0, @cellSize, @heightValues[x][y+1])
        @p5.endShape()
        @p5.popMatrix()


  createEmpty2DArray: (numCols, numRows) ->
    for col in [0...numCols]
      for row in [0...numRows]
        0



$(document).ready ->
  canvas = document.getElementById "processing"
  processing = new Processing(canvas, coffee_draw)
  $('#Like').bind 'click' , (event) =>
    processing.like()

  $('#Skip').bind 'click' , (event) =>
    processing.skip()
