require 'csv'
require 'set'
require_relative 'dual_wordle_solver' # Ensure the solver and feedback logic are in this file

def feedback_fn(guess, target_1, target_2)
  def calculate_feedback(target, guess)
    feedback = Array.new(guess.length, 'gray')
    target_counts = Hash.new(0)

    target.chars.each_with_index do |t_char, i|
      g_char = guess[i]
      if t_char == g_char
        feedback[i] = 'green'
      else
        target_counts[t_char] += 1
      end
    end

    guess.chars.each_with_index do |g_char, i|
      if feedback[i] == 'gray' && target_counts[g_char] > 0
        feedback[i] = 'yellow'
        target_counts[g_char] -= 1
      end
    end

    feedback
  end

  feedback_1 = calculate_feedback(target_1, guess)
  feedback_2 = calculate_feedback(target_2, guess)
  [feedback_1, feedback_2]
end

def test_hard_words
  words_file = 'valid_solutions.csv'
  hard_word_pairs = [['nanny', 'riper'], ['jazzy', 'fuzzy'], ['apple', 'banal']]
  results = []

  hard_word_pairs.each do |target_1, target_2|
    puts "Testing with Wordle 1: #{target_1}, Wordle 2: #{target_2}"

    solver = DualWordleSolver.new(words_file)

    feedback_wrapper = proc { |guess| feedback_fn(guess, target_1, target_2) }

    guess_count = solver.solve(&feedback_wrapper)

    wordle_1_solution = solver.hypotheses_1.to_a.first
    wordle_2_solution = solver.hypotheses_2.to_a.first

    results << [target_1, target_2, wordle_1_solution, wordle_2_solution, guess_count]
  end

  puts "\n==== Hard Words Testing Results ===="
  results.each do |target_1, target_2, wordle_1_solution, wordle_2_solution, guess_count|
    puts "Wordle 1 Target: #{target_1}, Wordle 2 Target: #{target_2}"
    puts "Wordle 1 Solved: #{wordle_1_solution}, Wordle 2 Solved: #{wordle_2_solution}"
    puts "Total Guesses: #{guess_count}\n"
  end

  results
end

if __FILE__ == $0
  results = test_hard_words
  puts "\nFinal Results: #{results.inspect}"
end
