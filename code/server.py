from flask import Flask, request, jsonify
import util

app = Flask(__name__)

@app.route('/')
def index():
    return '<h1>Deployed to Heroku!!!</h1>'


@app.route('/get_location_names')
def get_location_names():
    response = jsonify({
        'locations': util.get_location_names()
    })
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response

@app.route('/predict_home_price', methods=['POST'])
def predict_home_price():
    location = request.form['location']
    no_of_rooms = request.form['noOfRooms']

    response = jsonify({
        'estimated_price': util.get_estimated_price(location, no_of_rooms)
    })

    response.headers.add('Access-Control-Allow-Origin', '*')

    return response;

if __name__ == "__main__":
    print("Starting Python Flask server for Home gram price prediction...")
    util.load_saved_artifacts()