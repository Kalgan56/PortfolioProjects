# Python code to upload csv files to Microsoft SQL Server

import pandas as pd
import sqlalchemy
import pyodbc

#df=pd.read_csv('CovidDeaths.csv')
#df=pd.read_csv('CovidVaccinations.csv')
df=pd.read_csv('Nashville Housing Data for Data Cleaning (reuploaded).csv')
print(df)
print(df.columns)

db_username='sa'
db_password='tr4Ntor56'
db_ip='localhost'
db_name='FCC_SQL_Project_DBs'
db_conn=sqlalchemy.create_engine('mssql+pyodbc://{0}:{1}@{2}/{3}?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes'.format(db_username,db_password,db_ip,db_name))

#df.to_sql(name='CovidDeaths',con=db_conn,if_exists='replace')
#df.to_sql(name='CovidVaccinations',con=db_conn,if_exists='replace')
df.to_sql(name='NashvilleHousing',con=db_conn,if_exists='replace')
