# A color-mixing cellular automaton.
# Ported from Derrick Staples' JS+Canvas implementation here:
# http://atinybird.com/experiments/coloution/
Shoes.app :resizable => false, :width => 400, :height => 400 do
  @mutation_degree = 0.1
  @box_width = 3
  @box_height = 3
  @wait = 10
  
  @cells = []
  @rows = []
  @mutation_hi = (256 * @mutation_degree).floor
  @mutation_low = -1 * (256 * @mutation_degree * 0.5).floor
  
  # create a random row of cells
  def randomize
    @cells = []
    0.upto(width) do
      @cells << Array.new(3) { rand(256) }
    end
  end
  
  # generate a new row of cells from the last row
  def iterate
    line = []
    
    0.upto(width) do |i|
      color = [0, 0, 0]
      parents = []
      
      parents << @cells[i]
      if i == 0
        parents << ((rand > 0.5) ? @cells[i] : @cells[i+1])
        parents << @cells[i+1]
      elsif i == width
        parents << @cells[i-1]
        parents << ((rand > 0.5) ? @cells[i] : @cells[i-1])
      else
        parents << @cells[i-1]
        parents << @cells[i+1]
      end
      
      # Get a single but random unique color from each parent
      3.times do |j|
        r = rand(parents.size)
        color[j] = parents[r][j]
        parents.delete_at(r)
      end
      
      # Mutate a bit
      r = rand(3)
      s = (rand * @mutation_hi).floor + @mutation_low
      color[r] += s
      color[r] = 0 if color[r] < 0
      color[r] = 255 if color[r] > 255
      
      line << color
    end
    @cells = line
  end
  
  # draw one row of cells
  def draw
    image(width, @box_height, :top => @box_height, :attach => @rows.last || self) do
      0.upto(width) do |i|
        fill rgb(*@cells[i])
        stroke rgb(*@cells[i])
        rect(i*@box_width, 0, @box_width, @box_height)
      end
    end
  end
  
  translate 0, -@box_height
  randomize
  
  animate(30) do
    @rows << draw
    iterate
    
    # remove offscreen rows
    if @rows.size > height/@box_height
      @rows.shift.remove
      @rows.first.top = 0
    end
  end
end