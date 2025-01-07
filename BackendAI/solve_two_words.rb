require 'set'
require 'csv'
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

def main
  if ARGV.length != 2
    puts "Usage: ruby solve_two_words.rb <word1> <word2>"
    exit(1)
  end

  target_1 = ARGV[0].downcase
  target_2 = ARGV[1].downcase

  words_file = 'valid_solutions.csv'
  solver = DualWordleSolver.new(words_file)

  unless solver.words.include?(target_1) && solver.words.include?(target_2)
    puts "Error: One or both words are not in the word list."
    exit(1)
  end

  puts "Solving Wordle 1: #{target_1}, Wordle 2: #{target_2}"

  feedback_wrapper = proc { |guess| feedback_fn(guess, target_1, target_2) }

  guess_count = solver.solve(&feedback_wrapper)

  if guess_count
    puts "\n==== Results ===="
    puts "Wordle 1 Solution: #{solver.hypotheses_1.to_a.first}"
    puts "Wordle 2 Solution: #{solver.hypotheses_2.to_a.first}"
    puts "Total Guesses: #{guess_count}"
  else
    puts "Solver failed to solve the puzzles."
  end
end

if __FILE__ == $0
  main
end
