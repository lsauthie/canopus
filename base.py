from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv, find_dotenv

#step 3
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential

load_dotenv()

dbuser = os.getenv('DBUSER')
dbpass = os.getenv('DBPASS')
dbserver = os.getenv('DBSERVER')

#we are on localhost
if dbserver == "localhost":
    connstr = 'postgresql://{}:{}@{}:5432/canopus-db'.format(dbuser, dbpass, dbserver)
else: #we are on azure

    #begin: keyvault block
    keyVaultName = "dole8953-keyvault" #this could be stored in an env. variable as well

    KVUri = "https://{}.vault.azure.net".format(keyVaultName)
    credential = DefaultAzureCredential()
    client = SecretClient(vault_url=KVUri, credential=credential)

    secretName = 'secret-sauce'
    dbpass = client.get_secret(secretName).value
    #end: keyvault block


    connstr = 'postgresql://{}:{}@{}.postgres.database.azure.com/canopus-db?sslmode=require'.format(dbuser, dbpass, dbserver)

engine = create_engine(connstr)
Session = sessionmaker(bind=engine)

Base = declarative_base()