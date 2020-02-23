import pickle
import json
import numpy as np

__model = pickle.load(open("./homegram_home_prices_model.pickle", 'rb'))
__data_columns = json.load(open("./columns.json"))['data_columns']

# __data_columns = ["number of rooms", "angwan rukuba, jos", "bauchi ring road, jos", "busa buji street, jos",
#                   "farin gada road, jos", "jos terminus, ahmadu bello way, jos", "lamingo road, jos",
#                   "old airport road, jos", "rayfield road, jos", "rock haven street, jos"]
__locations = __data_columns[1:]


def get_estimated_price(location, noOfRooms):
    try:
        loc_index = __data_columns.index(location.lower())
    except:
        loc_index = -1

    x = np.zeros(len(__data_columns))
    x[0] = noOfRooms
    if loc_index >= 0:
        x[loc_index] = 1

    return round(__model.predict([x])[0])

def get_location_names():
    return __locations

def load_saved_artifacts():
    print('Loading saved Artifacts...start')
    global __data_columns
    global __locations

    # __data_columns = json.load(open("./columns.json"))['data_columns']
    __data_columns = ["number of rooms", "angwan rukuba, jos", "bauchi ring road, jos", "busa buji street, jos", "farin gada road, jos", "jos terminus, ahmadu bello way, jos", "lamingo road, jos", "old airport road, jos", "rayfield road, jos", "rock haven street, jos"]
    __locations = __data_columns[1:]
    global __model
    __model = pickle.load(open("./homegram_home_prices_model.pickle", 'rb'))
    print("loading saved artifacts...done")

if __name__ == '__main__':
    print(get_location_names())
    print(get_estimated_price("bauchi ring road, jos", 3))