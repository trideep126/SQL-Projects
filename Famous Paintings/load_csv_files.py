import pandas as pd
from sqlalchemy import create_engine

conn_string = 'mysql+pymysql://root:365Pass@localhost/painting'
db = create_engine(conn_string)
conn = db.connect()

print("Connected to MySQL database successfully!")

df = pd.read_csv(r'C:\Users\chott\Downloads\SQL Project\Famous Paintings\artist.csv')
df.to_sql('artist', con = conn, if_exists='replace', index=False)

df = pd.read_csv(r'C:\Users\chott\Downloads\SQL Project\Famous Paintings\canvas_size.csv')
df.to_sql('canvas_size', con = conn, if_exists='replace', index=False)

df = pd.read_csv(r'C:\Users\chott\Downloads\SQL Project\Famous Paintings\image_link.csv')
df.to_sql('image_link', con = conn, if_exists='replace', index=False)

df = pd.read_csv(r'C:\Users\chott\Downloads\SQL Project\Famous Paintings\museum_hours.csv')
df.to_sql('museum_hours', con = conn, if_exists='replace', index=False)

df = pd.read_csv(r'C:\Users\chott\Downloads\SQL Project\Famous Paintings\product_size.csv')
df.to_sql('product_size', con = conn, if_exists='replace', index=False)

df = pd.read_csv(r'C:\Users\chott\Downloads\SQL Project\Famous Paintings\subject.csv')
df.to_sql('subject', con = conn, if_exists='replace', index=False)

df = pd.read_csv(r'C:\Users\chott\Downloads\SQL Project\Famous Paintings\work.csv')
df.to_sql('work', con = conn, if_exists='replace', index=False)

df = pd.read_csv(r'C:\Users\chott\Downloads\SQL Project\Famous Paintings\museum.csv')
df.to_sql('museum', con = conn, if_exists='replace', index=False)