import React, { useState } from "react";
import "./App.css"; // Ensure this file contains the styles

function App() {
  const [word1, setWord1] = useState("");
  const [word2, setWord2] = useState("");
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);

  const handleSolve = async () => {
    try {
      const response = await fetch("http://127.0.0.1:5000/solve", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ word1, word2 }),
      });

      const data = await response.json();

      if (response.ok) {
        setResult(data);
        setError(null);
      } else {
        setError(data.error);
        setResult(null);
      }
    } catch (err) {
      setError("Failed to connect to the backend.");
    }
  };

  const handleClear = () => {
    setWord1("");
    setWord2("");
    setResult(null);
    setError(null);
  };

  return (
    <div className="app">
      <h1 className="title">AI Wordle Solver</h1>
      <div className="input-container">
        <input
          className="input-field"
          type="text"
          placeholder="Enter Word 1"
          value={word1}
          onChange={(e) => setWord1(e.target.value)}
        />
        <input
          className="input-field"
          type="text"
          placeholder="Enter Word 2"
          value={word2}
          onChange={(e) => setWord2(e.target.value)}
        />
        <button className="solve-button" onClick={handleSolve}>
          Solve
        </button>
        <button className="clear-button" onClick={handleClear}>
          Clear
        </button>
      </div>

      {error && <p className="error-message">{error}</p>}

      {result && (
        <div className="results-container">
          <h2>Results</h2>
          <p>Wordle 1 Solution: <strong>{result.word1_solution}</strong></p>
          <p>Wordle 2 Solution: <strong>{result.word2_solution}</strong></p>
          <p>Total Guesses: <strong>{result.total_guesses}</strong></p>

          <h3>Guesses and Feedback</h3>
          <div className="grid">
            {result.guesses_feedback.map((guessData, index) => (
              <div key={index} className="row">
                <p className="guess">{guessData.guess.toUpperCase()}</p>
                <div className="feedback-container">
                  <div className="feedback-column">
                    <p>Feedback for Wordle 1:</p>
                    <div className="feedback-grid">
                      {guessData.feedback_word1.map((feedback, i) => (
                        <div
                          key={i}
                          className={`tile ${feedback.toLowerCase()}`}
                        >
                          {guessData.guess[i].toUpperCase()}
                        </div>
                      ))}
                    </div>
                  </div>
                  <div className="feedback-column">
                    <p>Feedback for Wordle 2:</p>
                    <div className="feedback-grid">
                      {guessData.feedback_word2.map((feedback, i) => (
                        <div
                          key={i}
                          className={`tile ${feedback.toLowerCase()}`}
                        >
                          {guessData.guess[i].toUpperCase()}
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

export default App;
