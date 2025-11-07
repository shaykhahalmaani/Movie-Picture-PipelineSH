from flask import jsonify
from flask.views import MethodView

# Dummy database to hold movie examples
movies = {
    "123": {
        "title": "Top Gun: Maverick",
        "description": "Fighter planes"
    },
    "456": {
        "title": "Sonic the Hedgehog",
        "description": "Blue Sega character"
    },
    "789": {
        "title": "A Quiet Place",
        "description": "Scary monsters"
    },
    "101": {
        "title": "The Matrix",
        "description": "Red pill or blue pill"
    },
}


class Movies(MethodView):
    def get(self, movie_id):
        if movie_id is None:
            # Return a list of all movies
            movie_list = [
                dict({"title": movie["title"]}, **{"id": i})
                for i, movie in movies.items()
            ]
            return jsonify({"movies": movie_list})
        else:
            # Return the details of a specific movie
            return jsonify({"movie": movies[str(movie_id)]})
