import sys
# import psycopg2
from sqlalchemy import create_engine, text
import pandas as pd

if (len(sys.argv) < 3):
    sys.exit()


script = sys.argv[1]
result = sys.argv[2]

# conn = psycopg2.connect(
#     "dbname=tx_property_tax user=keymaker password=br0@dw@y")
# cursor = conn.cursor()

engine = create_engine(
    'postgresql://keymaker:"br0@dw@y"@localhost/tx_property_tax')

query = ""
with open(script) as file:
    query = file.read()

df = pd.read_sql_query(text(query), engine)

df.to_csv(result, index=False)


print("")
print(df)
print("")
