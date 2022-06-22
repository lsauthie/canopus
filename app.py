'''
Application Canopus
Ludovic Sauthier

Step: Alfa
'''

import flask
from flask import request, jsonify
import similarities as sim
from bs4 import BeautifulSoup

app = flask.Flask(__name__)
app.config["DEBUG"] = True


@app.route('/', methods=['GET'])
def home():
    
    url_root = request.url_root
    
    link3 = url_root + "canopus?strings=the sun is the brightest start in the sky, sirius is the second brightest star in the sky, canopus is the third brightest star in the sky, earth is not a star"
    
    welcome = """ <h1>Welcome on projet "Canopus"</h1>
    
    <a href="{}">/canopus?strings=the sun is the brightest start in the sky, sirius is the second brightest star in the sky, canopus is the third brightest star in the sky, earth is not a star</a>
    
   
    """.format(link3)
    
    return welcome

    
@app.route('/canopus', methods=['GET'])
def canopus():
    if 'strings' in request.args:
        arg_strings = request.args['strings']
        
        if bool(BeautifulSoup(arg_strings, "html.parser").find()):#check for html tags
            return 'Error: Please avoid html tags in strings'
        else:
            strings = [i.strip() for i in arg_strings.split(',')]
            #compare strings
            res = sim.sim(strings, 0.8) #list of strings and similarity ratio               
        
    else:
        return 'Error: Please provide strings, i.e. /api/v1/canopus?strings=string1, string2, string3'
        
    return jsonify(res)
    	
if __name__ == '__main__':
    app.run(host='0.0.0.0',port=5000)
    
