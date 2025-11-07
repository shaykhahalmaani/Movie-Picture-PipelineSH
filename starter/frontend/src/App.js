import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001';

function App() {
  const [movies, setMovies] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchMovies();
  }, []);

  const fetchMovies = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_URL}/api/movies`);
      setMovies(response.data);
      setError(null);
    } catch (err) {
      setError('Failed to fetch movies. Please check if the backend is running.');
      console.error('Error fetching movies:', err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="App">
        <header className="App-header">
          <h1>Movie Picture Catalog</h1>
          <p>Loading movies...</p>
        </header>
      </div>
    );
  }

  return (
    <div className="App">
      <header className="App-header">
        <h1>Movie Picture Catalog</h1>
        {error && <div className="error-message">{error}</div>}
        <div className="movies-container">
          {movies.map((movie) => (
            <div key={movie.id} className="movie-card">
              <h2>{movie.title}</h2>
              <div className="movie-details">
                <p><strong>Year:</strong> {movie.year}</p>
                <p><strong>Genre:</strong> {movie.genre}</p>
                <p><strong>Director:</strong> {movie.director}</p>
                <p><strong>Rating:</strong> {movie.rating}/10</p>
              </div>
            </div>
          ))}
        </div>
      </header>
    </div>
  );
}

export default App;

