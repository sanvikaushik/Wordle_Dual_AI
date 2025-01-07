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

def test_random_words
  words_file = 'valid_solutions.csv'
  total_guesses = 0
  total_runs = 3000

  total_runs.times do |run|
    solver = DualWordleSolver.new(words_file)

    target_1 = solver.words.sample
    target_2 = solver.words.sample
    puts "Testing with Wordle 1: #{target_1}, Wordle 2: #{target_2}"

    feedback_wrapper = proc { |guess| feedback_fn(guess, target_1, target_2) }

    guess_count = solver.solve(&feedback_wrapper)
    total_guesses += guess_count
  end

  avg_guesses_per_duel = total_guesses.to_f / total_runs

  puts "\n==== Random Word Testing Results ===="
  puts "Total Runs: #{total_runs}"
  puts "Average Number of Guesses per Duel Wordle: #{avg_guesses_per_duel.round(2)}"

  {
    total_runs: total_runs,
    average_guesses_per_duel: avg_guesses_per_duel
  }
end

if __FILE__ == $0
  results = test_random_words
  puts "\nFinal Results: #{results}"
end
