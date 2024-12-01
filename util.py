import pyodbc
import pickle
from pandas import read_sql, concat
import os

'''
def get_connection_string():
    server = os.getenv('SQL_SERVER')
    database = os.getenv('SQL_DATABASE')
    username = os.getenv('SQL_USER')
    password = os.getenv('SQL_PASSWORD')

    driver = '{ODBC Driver 17 for SQL Server}'
        
    return f'DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password};'
'''

def get_connection_string():
    server = os.getenv('SQL_SERVER')
    database = os.getenv('SQL_DATABASE')

    driver = '{ODBC Driver 17 for SQL Server}'
        
    return f'DRIVER={driver};SERVER={server};DATABASE={database};Trusted_Connection=yes;'

def get_blob_to_df(table_name : str, connection_str):
    try:
        with pyodbc.connect(connection_str, autocommit=True) as conn:
            query = f"SELECT * FROM {table_name};"
            df = read_sql(query, conn)

        return (True, df)
    except Exception as e:
        return (False, str(e))

def insert_pickle(obj, file_name, connection_string: str): 
    try: 
        serialized_obj = pickle.dumps(obj) 
 
        connection = pyodbc.connect(connection_string) 
        cursor = connection.cursor() 
 
        # Inserta los datos en la tabla especificada 
        cursor.execute(f"INSERT INTO ML.PICKLE (FILE_NAME, FILE_PICKLE) VALUES (?, ?)", (file_name, serialized_obj, )) 
        connection.commit() 
 
        # Cierra la conexión 
        connection.close() 
 
        return (True, "") 
    except Exception as e: 
        return (False, str(e))

def save_to_sql(train_data, val_data, target, glosa: str, table_sql: str, connection_str: str):
    try:
        train_person = train_data[[target]].copy(deep=True)
        val_person = val_data[[target]].copy(deep=True)

        train_person['origen'] = 'train'
        val_person['origen'] = 'validation'

        combined_data = concat([train_person, val_person], ignore_index=True)
        combined_data['glosa'] = glosa

        with pyodbc.connect(connection_str, autocommit=True) as conn:
            cursor = conn.cursor()  
            # Crear un comando SQL
            insert_query = f"INSERT INTO {table_sql} (person, origen, glosa) VALUES (?, ?, ?)"
            
            # Insertar los datos fila por fila
            for index, row in combined_data.iterrows():
                cursor.execute(insert_query, row['person'], row['origen'], row['glosa'])
            
            # Confirmar la transacción
            conn.commit()
            
            # Cerrar la conexión
            cursor.close()
            conn.close()

        return (True, 'completado')
    except Exception as e:
        return (False, str(e))
        

