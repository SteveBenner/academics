# Unique Ruby implementations of traditional sorting algorithms

# The Ruby file inclusion terms are different than C. 'require' loads (runs) a file as per the C 'include' directive.
# Ruby's 'include', on the other hand, deals with 'modules', a collection of methods, constants, and variables. Calling
# 'include' is normally done within a module or class, and it has interesting behavior. It appends the code of the
# module to the context it is called within, extending the capabilities thereof. Called within a class (or module),
# it applies to instances only, so included methods are instance methods. The function 'extend' is used to include a
# the module's contents at the class level (class methods, etc.). 'Math' allows use of the '**' operator (exponent).
require 'benchmark'
include Math

# DATA
COUNT = 10000
rng = Random.new
data = Array.new(COUNT) {|i| i = rng.rand(COUNT)}

# Note: In Ruby the last expression evaluated in a block is the return value, so there is no explicit return statement

# INSERTION SORT
def insertion_sort(a)
  # probably my favorite example; I used 'reduce', which is like a special 'map'. It not only executes the code block
  # upon each member of the collection, but also maintains a 'helper object' (called 'memo' in documentation) who's
  # value is set to the return value of the code block after each iteration. When given a single parameter, 'reduce'
  # uses it as the initial value of the 'memo', and the return value is the concatenated results of the enumeration.
  (a.reduce([a.min]) do |sorted, i|
    # j is used when iterating backwards over the sorted sub-list to represent the location to insert i into
    j = sorted.length - 1
    # iterate backwards comparing key 'i' with sorted list elements
    while j > -1 && sorted[j] > i do j-=1 end
    # each key is inserted in to 'sorted', the 'memo' list built by 'reduce' by the 'insert' function
    sorted.insert(j+1, i)
  end).slice(1..a.length)
end

# SELECTION SORT
def selection_sort(a)
  # iterate through given collection, removing the smallest item and appending it to the growing 'sorted' array each
  # iteration. The innermost function is 'min', which selects the smallest value in a collection. This is passed to
  # 'index' so that we may in turn pass the index of this element to 'slice!'. 'slice!' returns the value at the given
  # index, and when called with bang appended, removes that element from the list as well. Thus we essentially are
  # parsing the unsorted list into a sorted one. Obviously this suffers from significant performance losses due to the
  # many calls (excessive iterations), but this is more of an exercise in brevity. This example nicely illustrates
  # how an algorithm can can be simplified to a single line of code in Ruby without losing clarity.
  sorted = []
  until a.empty? do sorted << a.slice!(a.index(a.min)) end
  sorted
end

# QUICKSORT
def quicksort(a)
  # base case for recursion
  return a if a.length <= 1
  # 'shift' removes the first element of the array and returns it. According to wikipedia, this is noted to produce
  # worst case results in an already-sorted array (which should be intuitive given an understanding of the procedure)
  # but it's nice to be able to use a single command to simplify a low-level process which is normally two steps.
  pivot = a.shift
  # 'partition' divides an array into two sub-arrays and returns them, using the evaluation of the passed block as a
  # criterion for determining placement. It places all elements for which the block returns 'true' into the first
  # sub-array, so in this case, the divide-and-conquer portion of quicksort can be accomplished in one command!
  split = a.partition {|i| i < pivot}
  # concatenate the result of recursive quicksorts calls on each sub-array (and the pivot of course). Then 'flatten'
  # is called, which recursively transforms a multi-dimensional (nested) array into a flat array. This is necessary due
  # to the recursive array construction. I think it is fantastic that a relatively complex algorithm like quicksort
  # can be implemented in just FOUR LINES in Ruby, and still maintain purity of essence. This function comes close to
  # maximum efficiency compared to a low-level implementation, as can be witnessed by the benchmarking in this program.
  # For more comparison, the pseudocode on wikipedia is EIGHT lines long, and yet the Ruby code is just as expressive.
  (quicksort(split[0]) << pivot << (quicksort(split[1]))).flatten
end

p 'Original data'
p data
d = Array.new(10) {|arr| arr = data.dup}
t1 = Benchmark.realtime {selection_sort(d[0])}
p "selection sort: #{t1*1000} ms"
p selection_sort d[0]
t2 = Benchmark.realtime {insertion_sort(d[1])}
p "insertion sort: #{t2*1000} ms"
p insertion_sort d[2]
t3 = Benchmark.realtime {quicksort(d[3])}
p "quicksort: #{t3*1000} ms"
p quicksort d[3]
