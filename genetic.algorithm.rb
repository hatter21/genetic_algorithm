require 'tk'
class GeneticAlgorithm
require 'rubygems'
require 'gruff'
@@size_population = 20
@@mutation_rate = 100/5   #5%
@@decision = []; @@answer = []; @@min_fitness =[]; @@max_fitness = []

 	def open(txt)
		@@file_array = []
		file = File.new(txt)
		@@file_array << file.gets
		@@length_file = @@file_array[0].to_i
		(1..@@length_file).each do |i|
			@@file_array[i] = file.gets
			@@file_array[i] = @@file_array[i].to_i
		end
		@@file_array.delete_at(0)
	end

	def create_binaty_structure
		@@binary_structure = []
		1.upto(@@length_file) { @@binary_structure << rand(2) }
	end

	def create_random_element_population
		@@element_population = []; array = [] 
		array.concat(@@binary_structure)
		max_random = array.size + 1
		(1..array.size).each do
			max_random -= 1
			random = rand(max_random)
			@@element_population << array[random]; array.delete_at(random) 
		end
	end 

	def create_population
		@@population = []
		create_binaty_structure
		(1..@@size_population).each do
			create_random_element_population
			@@population << @@element_population
		end
	end 

	def fitness(element_population)
		@@fitness = 0; left = []; right = []
		0.upto(@@length_file - 1) { |e| if element_population[e] == 0 then left << @@file_array[e] else right << @@file_array[e] end }
		summ_left = left.inject { |sum, x| sum + x}; summ_right = right.inject { |sum, x| sum + x}
		@@fitness = (summ_left.to_i - summ_right.to_i).abs
	end	

	def reproduction(population)
		@@children = []; pop = population.clone
		(1..@@size_population/2).each do |i|
			first_perent = pop[-1]; pop.delete_at(-1)
			second_perent = pop[-1]; pop.delete_at(-1)
			random = rand(@@length_file)
			child = []
			1.upto(random) { |i| child << first_perent[i] }; random.upto(@@length_file - 1) { |i| child << second_perent[i]}
			@@children << child
		end
	end

	def mutation(children)
		(1..@@size_population/@@mutation_rate).each do |k|
			random = rand(@@length_file)	
			mutation_rate = rand(@@mutation_rate)
			mutation_rate = @@mutation_rate * k - mutation_rate if k > 1
			(0..children.size - 1).each do |i|
				if i == mutation_rate
					mutation_child = children[i]
					new_child = []	
					0.upto(random - 1) { |x| new_child << mutation_child[x] }
					random.upto(@@length_file - 1) { |x| if mutation_child[x] == 0 then new_child << 1 else new_child << 0 end }
					children[i] = new_child
				end
			end
		end
		return children
	end

	def deadth(population)
		mass_fitness = []
		(0..@@size_population - 1).each do |i|
			element = @@population[i]
			fitness(element)
			mass_fitness << @@fitness
		end
		(1..@@size_population/2).each do
			max = mass_fitness.inject{ |max ,x| max > x ? max : x}
			index = mass_fitness.index(max)
			@@population.delete_at(index)
		end
	end

	def new_population(population, children)
		population = population.concat(children)
	end

	def fitness_population(population)
		mass_fitness_element = []; @@flag = false; @@min = 0; @@max = 0
		mass_element = population.clone
		(0..@@size_population - 1).each do |i|
			element_population = mass_element[i]
			fitness(element_population)
			fitness_element = @@fitness
			if fitness_element == 0
				puts "\n\nWe found the perfect solution!"; @@decision = element_population
				@@flag = true
			end
			mass_fitness_element << fitness_element
		end
			mass_fitness_element
			@@min = mass_fitness_element.inject{ |min ,x| min > x ? x : min}
			@@max = mass_fitness_element.inject{ |max ,x| max > x ? max : x}
			index = mass_fitness_element.index(@@min); @@element_population_with_the_smallest_fitness = population[index]
		[@@min, @@max,@@element_population_with_the_smallest_fitness]
	end

	def desision_problem(decision)
		left = []; right = []
		0.upto(@@length_file - 1) { |i| if decision[i] == 0 then left << @@file_array[i] else right << @@file_array[i] end }
		@@answer << left; @@answer << right
	end

	def genetic_algorithm
		create_population
		fitness_population(@@population)
		@@min_fitness << @@min; @@max_fitness << @@max
		(1..1000).each do
			reproduction(@@population)
			mutation(@@children)
			deadth(@@population)
			new_population(@@population, @@children)
			fitness_population(@@population)
			if @@flag == true
				@@min_fitness << @@min; @@max_fitness << @@max
				break
			elsif @@min == @@min_fitness[-1]
				create_population
			elsif @@min < @@min_fitness[-1]
				@@min_fitness << @@min; @@max_fitness << @@max
				@@decision =  @@element_population_with_the_smallest_fitness
			end
		end
		desision_problem(@@decision)
	end

	def output_results
		puts "\nFirst heap:"; p @@answer[0]
		puts "\nSecond heap:"; p @@answer[1]
		puts "\nArray elements with a minimum population of fitness:"; p @@min_fitness
		puts "\nArray of elements with the highest fitness population:"; p @@max_fitness
	end		
	
	def graph
		g = Gruff::Line.new 
		g.title = "Genetic Algorithm" 
		g.data("Graph MIN", @@min_fitness) 
		g.data("Graph MAX", @@max_fitness) 
		g.write('/home/hatter/Documents/University/Methods.and.algorithms.for.parallel.computation/Graph/genetic.algorithm.png')
	end
end

root = TkRoot.new
root.title = "Open File"
button_load_click = Proc.new {
f = GeneticAlgorithm.new
f.open(Tk.getOpenFile)
f.genetic_algorithm
f.output_results
f.graph
}

button_load = TkButton.new do
  text "load"
  pack('fill' => 'x')
end

TkButton.new {
  text 'Quit'
  command 'exit'
  pack('fill' => 'x')
}

button_load.command = button_load_click
Tk.mainloop
