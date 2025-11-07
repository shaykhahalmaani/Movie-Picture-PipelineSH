import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_movies_endpoint_returns_200(client):
    """Test that movies endpoint returns 200 status"""
    response = client.get('/movies')
    assert response.status_code == 200

def test_movies_endpoint_returns_json(client):
    """Test that movies endpoint returns JSON"""
    response = client.get('/movies')
    assert response.is_json

def test_movies_endpoint_returns_valid_data(client):
    """Test that movies endpoint returns valid movie data"""
    response = client.get('/movies')
    data = response.get_json()
    assert 'movies' in data
    assert isinstance(data['movies'], list)
    assert len(data['movies']) > 0
    assert 'id' in data['movies'][0]
    assert 'title' in data['movies'][0]

