# Automaton:
# A simple demo of elementary (one-dimensional, two-state) cellular automata.
#
# Read more about cellular automata and some rules to try on Wikipedia:
# http://en.wikipedia.org/wiki/Elementary_cellular_automaton

class Row
  attr_accessor :rule, :cells
  PATTERNS = %w{111 110 101 100 011 010 001 000}
  
  def initialize(cells='', rule=nil)
    self.cells = cells
    self.rule = rule
  end
  
  def rule=(rule)
    if rule.is_a?(Fixnum)
      @rule = {}
      binary = rule.to_s(2).rjust(8, '0')
      binary.scan(/./).each_with_index do |state, i|
        @rule[PATTERNS[i]] = state
      end
    else
      @rule = rule
    end
  end
  
  def randomize
    self.cells = Array.new(cells.length) { rand(2).to_s }.join
  end
  
  def next
    new_cells = ''
    cells.scan(/./).each_with_index do |state, i|
      left = i == 0 ? '0' : cells[i-1, 1]
      right = i == cells.length-1 ? '0' : cells[i+1, 1]
      new_cells += rule[left + state + right]
    end
    self.class.new(new_cells, rule)
  end
  
  def draw(image)
    cells.scan(/./).each_with_index do |state, i|
      image.fill state == '1' ? image.black : image.white
      image.rect CELL_WIDTH*i, 0, CELL_WIDTH, CELL_HEIGHT
    end
  end
end

Shoes.app :title => "Automaton", :width => 380, :height => 470, :resizable => false do
  CELL_WIDTH = 12
  CELL_HEIGHT = 12
  
  # Draw a row, then get the next one
  def step
    @seed.text = @row.cells
    
    @canvas.append do
      image width, CELL_HEIGHT do
        @row.draw(self)
      end
    end
    @canvas.scroll_top = @canvas.scroll_max
    
    @row = @row.next
  end
  
  stack do
    flow do
      para " Rule:"
      @rule = edit_line('90', :width => 40).change do
        @row.rule = @rule.text.to_i
      end
      
      para " Seed:"
      @seed = edit_line('0'*13 + '1' + '0'*13, :width => 220).change do
        @row.cells = @seed.text
      end
    end
    
    flow do
      button("Step") { step }
      button("Start/Stop") { @animation ||= animate(10) { step }; @animation.toggle }
      button("Clear") { @canvas.clear }
      button("Randomize") { @row.cells = @seed.text = @row.randomize }
    end
    
    nostroke
    @canvas = stack :margin => 10, :height => 400, :scroll => true
  end
  
  start { @row = Row.new(@seed.text, @rule.text.to_i) }
end