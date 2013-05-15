coffee_draw = (p5) ->
  p5.setup =  ->
    p5.size $(window).width(), $(window).height(), p5.P3D
    p5.mutationRate = 0.1 #percentage of attributes likely to be mutated
    p5.mutationStrength = 2 #how much  on average to mutate the values of the attributes that are chosen to be mutated
    p5.createRandomGenerationData()
    p5.newGeneration()

  p5.newGeneration = ->
    @BeanNodes = []
    p5.background 0
    p5.numGenes = Object.keys(@curGenData)
    @curGenData.startingNodes = p5.round(@curGenData.startingNodes)
    @curGenData.drawFrequency = 1
    for x in [0...@curGenData.startingNodes] by 1
      @BeanNodes.push(new BeanNode(p5, @curGenData));
  
  #Change these values to affect the starting generation
  p5.createRandomGenerationData =  ->
    @curGenData = 
      x_offModifier : p5.random(-0.1, 0.1)
      y_offModifier : p5.random(-20, 20)
      x_offIncrementer : p5.random(-0.01, 0.01)
      y_offIncrementer : p5.random(-0.01, 0.01)
      vel : p5.random(0, 60)
      accel : -0.003
      hue : p5.random(0, 360)
      alpha : p5.random(4, 100)
      startingNodes : p5.round(p5.random(1, 5))
    
    
  p5.draw =  ->
    #p5.fade()
    beanNode.draw() for beanNode in @BeanNodes

  p5.addBeanNode = (event) ->
    @BeanNodes.push(new BeanNode(p5, @curGenData,  event.clientX, event.clientY));
    @curGenData.startingNodes++
    
  p5.fade =  ->
    #Larger the value, the longer the stuff stays on the screen!
    if p5.frameCount % 225 == 0
      p5.stroke(0, 0)
      p5.fill(0, 10)
      p5.rect(0, 0, p5.width, p5.height)

  p5.skip =  ->
    p5.createRandomGenerationData()
    p5.newGeneration()

#Before we mate, make sure we have two parent generations already liked from which to mate from
#Also we need to save curGenBefore to prevGen before we modify it
  p5.like = ->
    if @prevGenData? then @prevPrevGenData = @prevGenData
    @prevGenData = @curGenData
    if @prevPrevGenData? then p5.mateCrossover() else p5.createRandomGenerationData() and p5.newGeneration()


#Go through each value from previous two generations, which act as parents, and mate their results together
  p5.mateAverage = ->
    for key of @prevPrevGenData
      p5.mateAttribute(key)
      p5.newGeneration()

  p5.mateCrossover = ->
    midpoint = p5.round(p5.random(p5.numGenes)/2)
    i = 0
    for key of @prevPrevGenData
      if i > midpoint
        @curGenData[key] = @prevGenData[key]
      else
        @curGenData[key] = @prevPrevGenData[key]
      i++
    p5.mutateNewGeneration()  
    p5.newGeneration()

  p5.mateAttribute = (key) ->
    @curGenData[key] = (@prevGenData[key] + @prevPrevGenData[key]) * 0.5

  p5.mutateNewGeneration = ->
    for key of @curGenData
      if p5.random(1) < @mutationRate
        @curGenData[key] *= p5.random(@mutationStrength) 

    


class BeanNode
  #data we need to create beans
  constructor: (@p5, nodeData, x, y) ->
    @nodeData = nodeData
    @beans = []
    @x = x || @p5.random(100, @p5.width-100)
    @y = y || @p5.random(100, @p5.height-100)

  draw:  ->
    x_off = @p5.frameCount * @nodeData.x_offModifier
    y_off = x_off + @nodeData.y_offModifier
      
    if @p5.frameCount % @nodeData.drawFrequency == 0
      bean = new Bean(@p5, {
        x: @x
        y: @y
        x_off: x_off
        y_off: y_off
        vel: @nodeData.vel
        accel: @nodeData.accel
      })


      @beans.push(bean)
    
    bean.draw() for bean in @beans

    #Iterates through array and filters out all of the dead particles. (The one's that have stopped moving);
    @beans = @beans.filter (bean) -> bean.dead is false;
  




class Bean
  constructor: (@p5, opts) ->
    @x = opts.x
    @y = opts.y
    @dead = false
    
    @x_off = opts.x_off
    @y_off = opts.y_off
    
    @vel = opts.vel || 3
    @accel = opts.accel || -0.003
  
  draw:  ->
    @x += @p5.noise(@x_off) * @vel - @vel/2
    @y += @p5.noise(@y_off) * @vel - @vel/2
    if @vel != 0 and not @offScreen()
    
      @x_off += @p5.curGenData.x_offIncrementer
      @y_off += @p5.curGenData.y_offIncrementer
  
      @vel += @accel
      
      #Perlin noise is a random sequence generator producing a more natural ordered, 
      #harmonic succession of numbers compared to the standard random() function.”
      
      @set_color()
      @p5.point(@x, @y)

    else
      @dead = true 
    
    
  set_color:  ->
    @p5.colorMode(@p5.HSB, 360, 100, 100)
    h = @p5.map(@x + @y, 0, @p5.width + @p5.height, 0, 360)
    s = 100
    b = 100
    a = @p5.curGenData.alpha
    
    @p5.stroke(h, s, b, a)

  offScreen: ->
    @x > @p5.width or @x < 0 or @y > @p5.height or @y < 0


$(document).ready ->
  canvas = document.getElementById "processing"
  processing = new Processing(canvas, coffee_draw)
  $('#Like').bind 'click' , (event) =>
    processing.like()

  $('#Skip').bind 'click' , (event) =>
    processing.skip()
  $('#processing').bind 'mousedown', (event) =>
    processing.addBeanNode(event)
