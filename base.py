from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv, find_dotenv

load_dotenv()

dbuser = os.getenv('DBUSER')
dbpass = os.getenv('DBPASS')
dbserver = os.getenv('DBSERVER')

#we are on localhost
if dbserver == "localhost":
    connstr = 'postgresql://{}:{}@{}:5432/canopus-db'.format(dbuser, dbpass, dbserver)
else: #we are on azure
    connstr = 'postgresql://{}:{}@{}.postgres.database.azure.com/canopus-db?sslmode=require'.format(dbuser, dbpass, dbserver)

engine = create_engine(connstr)
Session = sessionmaker(bind=engine)

Base = declarative_base()