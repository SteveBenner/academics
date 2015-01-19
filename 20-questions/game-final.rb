#!/usr/bin/env ruby

# Stephen Benner
# CPTR 246 LAB
# 2013.05.28 - first draft
# 2013.06.01 - intermediate draft

# 'Guessing Game' or '20 Questions'

# classes
class Knowledge_tree
end

class EmptyKT < Knowledge_tree
  # @return [NodeAnswer] A new answer node
  def play
    puts "Actually, I don't know jack. Let's fire up the learn-o-nator 5000! What were you in fact thinking of?"
    new_thing = gets.chomp
    puts "Holy $#!&*, looks like I learned something new today!!!\nI now know what '#{new_thing}' is!"
    NodeAnswer.new new_thing
  end

  def traverse_tree(addition = "\n")
    yield addition + '[Empty node]' unless !$print_empty
  end

  def height
    0
  end

  def num_nodes
    0
  end
end

class NodeAnswer < Knowledge_tree
  attr_accessor :value

  def initialize(value)
    self.value = value
  end

  # Recursively plays a game using given tree, returning modified tree as a result
  # @return [Knowledge_tree] A game tree with state reflecting the actions of a single play-through
  def play
    puts "Are you thinking of '#{self.value}' by any chance? (Y/N)"
    if gets.chomp =~ /Y|y/
      puts 'Awwwwwwwwwwwwwwwwww yea, givin Stephen Hawking a run for his money now!'
      self
    else
      puts 'IMPOSSIBRU!!!!!!'
      learn_new_thang
    end
  end

  # Initializes global hash with values for a new node, so it may be created as the root of a new tree
  def learn_new_thang
    puts 'I give up... You be one sneaky beezy. What were you thinking of?'
    new_answer = gets.chomp
    puts "Help me out here... Ask me a question I can use to discern between '#{new_answer}' and everything else."
    new_question = gets.chomp
    puts "If I ask you '#{new_question}', and you're thinking of '#{new_answer}', what is you're answer? (Y/N)"
    distinction = gets.chomp
    puts "Holy $#!&*, looks like I learned something new today!!!\nI now know what '#{new_answer}' is!"
    distinction =~ /Y|y/ ?
        NodeQuestion.new(new_question, NodeAnswer.new(new_answer), EmptyKT.new) :
        NodeQuestion.new(new_question, EmptyKT.new, NodeAnswer.new(new_answer))
  end

  def traverse_tree(addition = "\n")
    yield addition + "A: #{self.value}"
  end

  def height
    1
  end

  def num_nodes
    1
  end
end

class NodeQuestion < Knowledge_tree
  attr_accessor :value, :yes, :no

  def initialize(value, yes = EmptyKT.new, no = EmptyKT.new)
    self.value = value
    self.yes = yes
    self.no = no
  end

  # Recursively plays a game using given tree, returning modified tree as a result
  # @return [Knowledge_tree] A game tree with state reflecting the actions of a single play-through
  def play
    puts self.value
    gets.chomp =~ /Y|y/ ?
        NodeQuestion.new(value, self.yes.play, self.no) :
        NodeQuestion.new(value, self.yes, self.no.play)
  end

  # this traversal function recursively calls itself down throughout the tree, using 'yield' to evaluate the given
  # procedure object, (a Ruby code block). When called with an argument, 'yield' passes it into the code block to be
  # used as a parameter, allowing for arbitrary specification within each implementation of the method. This allows
  # for some incredibly flexible coding tricks. In this case, each class calls 'yield' with a value specific to itself,
  # which is the node value or empty. However, we can also prepend to this an argument received from the traversal
  # method, meaning what gets evaluated at each node can be specified arbitrarily from previous callers in
  # the recursion process, so that the method can exhibit different behavior depending on where in the tree hierarchy
  # it gets evaluated. Thus, beautiful output in an outstandingly elegant and powerful fashion.
  def traverse_tree(addition = "\n", &proc)
    yield addition =~ /\t/ ?
        addition + "Q: #{self.value}" :
        "Q: #{self.value}"
    #depth = $total_height - self.height
    # add 1 to depth because the root node has a depth of 0
    self.yes.traverse_tree(addition + "\t", &proc)
    self.no.traverse_tree(addition + "\t", &proc)
  end

  def height
    1 + [self.yes.height, self.no.height].max
  end

  def num_nodes
    1 + self.yes.num_nodes + self.no.num_nodes
  end

  alias :num_questions :num_nodes
end

# functions

def fname_incr(fname)
  !File.exists?(fname) ?
      fname :
      /([0-9]+)\./.match(fname) ?
          fname_incr(fname.sub(/([0-9]+)/) { |m| (m.to_i+1).to_s }) :
          fname_incr(fname.sub(/[^\.]*/) { |m| m+'1' })
end

def parse_tree(lines)
  line = lines.shift.strip! # take the first line from the array and remove whitespace
  lines.shift if $print_with_newline
  # note the use of || to default to using 'Q: ' as our base case here if the return value from 'slice!' is nil
  case line.slice!(0..2) || 'Q: '
    when 'Q: '
      NodeQuestion.new(line, parse_tree(lines), parse_tree(lines))
    when 'A: '
      NodeAnswer.new(line)
    else
      EmptyKT.new
  end
end

# data
tree1 = NodeQuestion.new('Does it bark?',
                         NodeAnswer.new('a dog'),
                         NodeAnswer.new('a cat'))
tree2 = NodeQuestion.new('Does it bark?',
                         NodeQuestion.new('Is it furry?',
                                          NodeQuestion.new('is it mans best friend?',
                                                           NodeAnswer.new('a dog'),
                                                           NodeAnswer.new('a rodent'))),
                         NodeQuestion.new('Does it quack?',
                                          NodeAnswer.new('a duck'),
                                          NodeAnswer.new('a cat')))
tree = tree2

# play game
$print_empty = true
$print_with_newline = true
opt = 1
while (1..5) === opt
  begin
    puts "\nWelcome to Stephen's guessing game!\n"
    puts '1 - Play the game'
    puts '2 - View current game tree'
    puts '3 - Save game to text file'
    puts '4 - Load game from text file'
    puts "5 - Quit\n"
    opt = gets.chomp.to_i
    # read in user input
    # ran into the issues of determining how deep a node was in the tree, for printing structured output correctly,
    # so for now I thought it best to solve the problem using a somewhat 'hacky' but effective approach; globals!
    # gross! haha. But it works and makes sense. The game is only processing one tree at a time, so it just maintains
    # the current 'total' tree height and the traversal method calculates the node depth based on the difference.
    # Obviously this breaks the flavor of our recursive program, but makes sense in as an exception since the information
    # is not representable per tree-instance. I thought about using a class variable but what's the point? =)
    $total_height = tree.height
    case opt
      when 1 then
        puts "Think of something and I'll try to guess it."
        puts "When you're ready, enter 'Y' or 'N'"
        tree = tree.play if gets.chomp =~ /Y|y/
      when 2 then
        puts ''
        tree.traverse_tree { |val| print val }
        puts ''
      when 3 then
        puts 'Enter a filename, including extension:'
        fname = gets.chomp
        if File.exists? fname
          puts 'File already exists - overwrite?'
          file = (gets.chomp =~ /Y|y/) ?
              File.open(fname, 'w+') :
              File.open(fname_incr(fname), 'w+')
        else
          file = File.open(fname, 'w+')
        end
        tree.traverse_tree { |val| file.print !$print_with_newline ? val : val + "\n" }
        file.close
        puts "Game data saved to '#{file.path}'"
      when 4 then
        puts 'Enter a filename, with or without extension:'
        fname = gets.chomp
        files = Dir.glob(fname)
        if files.empty?
          puts 'File does not exist.'
        else
          file = File.open(files.first)
          if file.gets.strip[0..2] == 'Q: '
            file.rewind
            tree = parse_tree(file.readlines)
          else
            puts("Game data improperly formatted; root node must be of type 'NodeQuestion'")
          end
        end
      when 5 then
        exit
      else
        puts 'Enter a valid option.'
    end
  end
end
