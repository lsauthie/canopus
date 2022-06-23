'''
Application Canopus
Ludovic Sauthier

'''

import flask
from flask import request, jsonify
import similarities as sim
from bs4 import BeautifulSoup

#step2
from flask_sqlalchemy import SQLAlchemy
from dbcanopus import Canopus
from base import Session, engine, Base

app = flask.Flask(__name__)
app.config["DEBUG"] = True

#Instantiate the connection with the DB - and create the table if not existing
#this function needs to be outside __name__ otherwise it would work when calling "python app.py" but not "flask run"
Base.metadata.create_all(engine)

@app.route('/', methods=['GET'])
def home():
    
    url_root = request.url_root
    
    link1 = url_root + "canopus/flush"
    
    link2 = url_root + "canopus/all"
    
    link3 = url_root + "canopus?strings=the sun is the brightest start in the sky, sirius is the second brightest star in the sky, canopus is the third brightest star in the sky, earth is not a star"
    
    
    
    welcome = """ <h1>Welcome on projet "Canopus"</h1>
    
    <a href="{}">/canopus/flush</a></br>
    <a href="{}">/canopus/all   </a></br>
    <a href="{}">/canopus?strings=the sun is the brightest start in the sky, sirius is the second brightest star in the sky, canopus is the third brightest star in the sky, earth is not a star</a>
    
   
    """.format(link1, link2, link3)
    
    return welcome
    
@app.route('/canopus/flush', methods=['GET'])
def dole_flush():
    session = Session()
    session.query(Canopus).delete()
    session.commit()
    session.close()
    return "Canopus table has been flushed"
    
@app.route('/canopus/all', methods=['GET'])
def dole_all():
    session = Session()
    canopus = session.query(Canopus).all()
    
    d = {}
    for i in canopus:
        reference = i.reference
        sentence = i.sentence
        ratio = i.ratio
        t = (sentence, ratio)
        
        if reference in d:
            if t not in d[reference]:
                d[reference].append(t)
        else:
            d[reference] = [t]
    
    session.close()
    return jsonify(d)

    
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

            #populate the DB
            session = Session()
            for reference, l in res.items():
                if len(l) == 0:
                    db_row = Canopus(reference, "", -1)
                    session.add(db_row)
                else:
                    for item in l:
                        db_row = Canopus(reference, item[0], item[1])
                        session.add(db_row)
            
            
            session.commit()
            session.close()
        
    else:
        return 'Error: Please provide strings, i.e. /api/v1/canopus?strings=string1, string2, string3'
        
    return jsonify(res)
    	
if __name__ == '__main__':
    app.run(host='0.0.0.0',port=5000)
    
