require 'csv'

class DualWordleSolver
  attr_reader :words, :hypotheses_1, :hypotheses_2, :priors_1, :priors_2, :guessed_words

  def initialize(words_file)
    @words = load_words(words_file)
    @hypotheses_1 = @words.clone.to_set
    @hypotheses_2 = @words.clone.to_set
    @priors_1 = @words.map { |word| [word, 1.0 / @words.size] }.to_h
    @priors_2 = @words.map { |word| [word, 1.0 / @words.size] }.to_h
    @guessed_words = Set.new
  end

  def load_words(file_path)
    CSV.read(file_path, headers: true).map { |row| row['word'].strip.downcase }
  end

  def feedback_likelihood(target, guess)
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

  def update_posteriors_with_bayes(guess, feedback, priors, hypotheses)
    posteriors = {}
    total = 0.0

    hypotheses.each do |h|
      likelihood = feedback_likelihood(h, guess) == feedback ? 1.0 : 0.0
      posteriors[h] = likelihood * priors[h]
      total += posteriors[h]
    end

    posteriors.transform_values! { |v| v / (total.nonzero? || 1) }
  end

  def update_posteriors(guess, feedback_1, feedback_2)
    @priors_1 = update_posteriors_with_bayes(guess, feedback_1, @priors_1, @hypotheses_1)
    @hypotheses_1.select! { |word| @priors_1[word] > 0 }

    @priors_2 = update_posteriors_with_bayes(guess, feedback_2, @priors_2, @hypotheses_2)
    @hypotheses_2.select! { |word| @priors_2[word] > 0 }
  end

  def select_next_guess
    candidates = []
  
    max_score = -1
    @words.each do |word|
      next if @guessed_words.include?(word)
  
      score_1 = @priors_1[word] || 0
      score_2 = @priors_2[word] || 0
      total_score = score_1 + score_2
  
      if total_score > max_score
        max_score = total_score
        candidates = [word]
      elsif total_score == max_score
        candidates << word
      end
    end
  
    # Randomly pick a word if there are multiple candidates with even odds
    best_guess = candidates.sample
    @guessed_words.add(best_guess) if best_guess
    best_guess
  end
  

  def solve(&feedback_fn)
    guess_count = 0

    while !@hypotheses_1.empty? && !@hypotheses_2.empty?
      guess = select_next_guess
      puts "Next Guess: #{guess}"
      guess_count += 1

      feedback_1, feedback_2 = feedback_fn.call(guess)
      puts "Feedback for Wordle 1: #{feedback_1}"
      puts "Feedback for Wordle 2: #{feedback_2}"

      update_posteriors(guess, feedback_1, feedback_2)

      puts "\nTop 10 Words for Wordle 1:"
      @priors_1.sort_by { |_word, prob| -prob }.first(10).each_with_index do |(word, prob), i|
        puts "#{i + 1}. #{word}: #{prob.round(6)}"
      end

      puts "\nTop 10 Words for Wordle 2:"
      @priors_2.sort_by { |_word, prob| -prob }.first(10).each_with_index do |(word, prob), i|
        puts "#{i + 1}. #{word}: #{prob.round(6)}"
      end

      if @hypotheses_1.size == 1 && @hypotheses_2.size == 1
        puts "Solved Wordle 1: #{@hypotheses_1.to_a.first}"
        puts "Solved Wordle 2: #{@hypotheses_2.to_a.first}"
        puts "Solved in #{guess_count} guesses!"
        return guess_count
      end
    end
  end
end

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


if __FILE__ == $0
    solver = DualWordleSolver.new('valid_solutions.csv')
    solver.solve do |guess|
      feedback_fn(guess, 'apple', 'apple') # Replace with actual targets
    end
  end
  