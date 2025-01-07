# Dual Wordle Solver

This repository contains a full-stack application for solving dual Wordle puzzles using Bayesian inference. The backend is written in Ruby, while the frontend is built with React. The backend provides an API to calculate optimal guesses and refine hypotheses, and the frontend offers an interactive interface for users to input guesses and view results.


## Requirements

- **Backend:**
  - Ruby 3.x
  - Bundler
  - Puma

- **Frontend:**
  - Node.js (v16 or higher)
  - npm or Yarn

## Setup and Running Instructions

### 1. Backend (Ruby)

#### Step 1: Install Ruby Dependencies
Navigate to the `wordle_solver_api` directory and run:

```bash
cd wordle_solver_api
bundle install
```

#### Step 2: Start the Backend Server
```bash
rails server
```
By default, the backend will be available at http://localhost:5000


### 2. Frontend (React)
####  Step 1: Install Node Dependencies
Navigate to the react-frontend directory and run
```bash
cd react-frontend
npm install
```
#### Step 2: Start the Frontend Server
Run the following command to start the development server:
```bash
npm start
```
This will open the React app in your default browser at http://localhost:3000

## Running Tests
#### Test Hard Word Pairs:
Run the following command in the backend directory to test hard word pairs:
```bash
ruby test_hard_words.rb
```

#### Test Random Word Pairs:
Run the following command in the backend directory to test random word pairs:
```bash
ruby test_random_words.rb
```


