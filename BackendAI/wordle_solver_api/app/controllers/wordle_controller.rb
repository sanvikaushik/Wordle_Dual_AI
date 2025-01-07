require_relative 'dual_wordle_solver' 

class WordleController < ApplicationController
  def solve
    puts "Raw Params: #{params.inspect}"
    word1 = params[:word1].downcase
    word2 = params[:word2].downcase

    solver = DualWordleSolver.new(File.join(__dir__, 'valid_solutions.csv'))

    unless solver.words.include?(word1) && solver.words.include?(word2)
      render json: { error: 'One or both words are not in the valid word list' }, status: :unprocessable_entity
      return
    end

    guesses_feedback = []

    feedback_wrapper = proc do |guess|
      feedback1 = solver.feedback_likelihood(word1, guess)
      feedback2 = solver.feedback_likelihood(word2, guess)

      guesses_feedback << { guess: guess, feedback_word1: feedback1, feedback_word2: feedback2 }

      [feedback1, feedback2]
    end

    solver.solve(&feedback_wrapper)

    last_guess_word1 = solver.hypotheses_1.to_a.first
    last_guess_word2 = solver.hypotheses_2.to_a.first

    unless guesses_feedback.any? { |entry| entry[:guess] == last_guess_word1 }
      guesses_feedback << {
        guess: last_guess_word1,
        feedback_word1: Array.new(last_guess_word1.length, "green"),
        feedback_word2: solver.feedback_likelihood(word2, last_guess_word1)
      }
    end

    unless guesses_feedback.any? { |entry| entry[:guess] == last_guess_word2 }
      guesses_feedback << {
        guess: last_guess_word2,
        feedback_word1: solver.feedback_likelihood(word1, last_guess_word2),
        feedback_word2: Array.new(last_guess_word2.length, "green")
      }
    end

    render json: {
      word1_solution: last_guess_word1,
      word2_solution: last_guess_word2,
      total_guesses: guesses_feedback.size,
      guesses_feedback: guesses_feedback
    }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
