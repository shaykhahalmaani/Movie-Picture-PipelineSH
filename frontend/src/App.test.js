import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import axios from 'axios';
import App from './App';

jest.mock('axios');

describe('App Component', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders loading state initially', () => {
    axios.get.mockImplementation(() => new Promise(() => {}));
    render(<App />);
    expect(screen.getByText('Loading movies...')).toBeInTheDocument();
  });

  it('displays movies after successful fetch', async () => {
    const mockMovies = [
      {
        id: 1,
        title: 'Test Movie',
        year: 2024,
        genre: 'Action',
        director: 'Test Director',
        rating: 8.5
      }
    ];
    axios.get.mockResolvedValue({ data: mockMovies });
    
    render(<App />);
    
    await waitFor(() => {
      expect(screen.getByText('Test Movie')).toBeInTheDocument();
    });
  });

  it('displays error message on fetch failure', async () => {
    axios.get.mockRejectedValue(new Error('Network Error'));
    
    render(<App />);
    
    await waitFor(() => {
      expect(screen.getByText(/Failed to fetch movies/i)).toBeInTheDocument();
    });
  });
});

