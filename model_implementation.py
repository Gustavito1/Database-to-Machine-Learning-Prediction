import os
import json
import pickle
from datetime import datetime

import pandas as pd
import pyodbc


# Function to retrieve connection string from environment variables
def get_connection_string():
    server = os.getenv("SQL_SERVER")
    database = os.getenv("SQL_DATABASE")
    username = os.getenv("SQL_USER")
    password = os.getenv("SQL_PASSWORD")

    driver = "{ODBC Driver 17 for SQL Server}"
    return f"DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password};"


# Function to retrieve data from a table using SQL query
def get_blob_to_df(table_name, connection_str):
    try:
        with pyodbc.connect(connection_str, autocommit=True) as conn:
            query = f"SELECT * FROM {table_name};"
            df = pd.read_sql(query, conn)
        return True, df
    except Exception as e:
        return False, str(e)


# Function to save predictions to a SQL table
def save_to_sql(predictions, model_name, table_sql, connection_str):
    try:
        with pyodbc.connect(connection_str, autocommit=True) as conn:
            cursor = conn.cursor()

            # Create SQL insert statement
            insert_query = f"INSERT INTO {table_sql} (person, forecast, model, fecha) VALUES (?, ?, ?, ?)"

            # Get current date
            d = datetime.now()

            # Insert data row by row
            for index, row in predictions.iterrows():
                cursor.execute(
                    insert_query, row["person"], row["predictions"], model_name, d
                )

            # Commit the transaction
            conn.commit()
            cursor.close()
        return True, "completado"
    except Exception as e:
        return False, str(e)


# Function to replace zeros with median values in specified columns
def replace_zeros_with_median(data, columns):
    for column in columns:
        median_value = data[column].median()
        data[column].replace(0, median_value, inplace=True)
    return data


# Function to retrieve a pickled model from the database
def get_pickle(file_name, connection):
    try:
        with pyodbc.connect(connection, autocommit=True) as conn:
            cursor = conn.cursor()
            query = f"SELECT FILE_PICKLE FROM ML.PICKLE WHERE file_name = ?"
            cursor.execute(query, (file_name,))
            result = cursor.fetchone()

            if result:
                obj = pickle.loads(result[0])
                return True, obj
            else:
                return False, f"No se encontró el archivo {file_name} en la base de datos."
    except Exception as e:
        return False, str(e)


# Main function
def main():
    # Get input as JSON string
    input_json = input()

    # Parse JSON and extract parameters
    try:
        params = json.loads(input_json)
        model_name = params["file_name"]
        table = params["table"]
    except json.JSONDecodeError as e:
        print("Error al parsear el JsSON:", e)
        return

    # Get connection string
    conn_str = get_connection_string()

    # Retrieve data from table and model from database
    data_success, df = get_blob_to_df(table_name=table, connection_str=conn_str)
    model_success, model = get_pickle(file_name=model_name, connection=conn_str)

    if not data_success or not model_success:
        return

    # Preprocess data
    df = replace_zeros_with_median(df.copy(), ["x", "y", "z"])
    df["volume"] = df["x"] * df["y"] * df["z"]
    X = df.drop(columns=["person"])
    X = pd.get_dummies(X, drop_first=True)

    # Make predictions using the model
    df["predictions"] = model.predict(X)

    # Save predictions to the SQL table
    save_to_sql(df[["person", "predictions"]], model_name, "ML.Prediction", conn_str)


if __name__ == "__main__":
    main()