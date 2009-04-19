Shoes.app :width => 600, :height => 600 do
  radius = self.width / 2.0
  nostroke
  background gray
  
  @ovals = []
  16.times do |i|
    i += 1
    fill rgb(*[i%2.to_f]*3)
    @ovals << oval(:center => true, :radius => radius - i*20)
  end
  
  motion do |x, y|
    @x, @y = x.to_f, y.to_f
  end
  
  animate(24) do |frame|
    @ovals.each_with_index do |shape, i|
      i += 1
      slowness = 200.0 / i
      radians = (2*PI) * (frame / slowness) 
      shape.left = radius + (@x-radius)*(i-4)/10 + Math.cos(radians)*(i-2)
      shape.top = radius + (@y-radius)*(i-4)/10 + Math.sin(radians)*(i-2)
    end
  end
end
