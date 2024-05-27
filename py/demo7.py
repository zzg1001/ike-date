import os
import re
import pandas as pd
from sqlalchemy import create_engine
import urllib
import logging
from googletrans import Translator
import time

def get_sqlalchemy_engine(server, database, username, password):
    """Create a SQLAlchemy engine for SQL Server."""
    params = urllib.parse.quote_plus(
        f"DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={database};UID={username};PWD={password};Trusted_Connection=no"
    )
    engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}", fast_executemany=True)
    return engine

def shorten_name(name, max_length=20):
    """Shorten the name if it exceeds max_length, except if it contains numbers."""
    if len(name) <= max_length:
        return name
    if any(char.isdigit() for char in name):
        return name
    words = name.split('_')
    abbreviated = ''.join([word[0] for word in words])
    return abbreviated if len(abbreviated) <= max_length else abbreviated[:max_length]

def translate_text(text, translator, retries=5, delay=5):
    """Translate text with retry mechanism."""
    for attempt in range(retries):
        try:
            translation = translator.translate(text, src='zh-cn', dest='en')
            return translation.text
        except Exception as e:
            print(f"Error translating text '{text}': {e}")
            if attempt < retries - 1:
                print(f"Retrying... ({attempt + 1}/{retries})")
                time.sleep(delay)
            else:
                print("Max retries reached. Skipping translation.")
                return text

def import_excel_to_db(excel_file, table_name, engine, chunksize=1000):
    """Import data from an Excel file to a database table."""
    try:
        df = pd.read_excel(excel_file)
        df.to_sql(table_name, con=engine, if_exists='replace', index=False, method='multi', chunksize=chunksize)
        print(f"Successfully imported {excel_file} into {table_name}")
        return True
    except Exception as e:
        print(f"Error importing {excel_file} into {table_name}: {e}")
        logging.error(f"Error importing {excel_file} into {table_name}: {e}")
        return False

def get_all_excel_files(folder_path):
    """Recursively get a list of all Excel files in the specified folder and its subfolders."""
    excel_files = []
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            if file.endswith('.xlsx') or file.endswith('.xls'):
                excel_files.append(os.path.join(root, file))
    return excel_files

def clean_table_name(name):
    """Clean and format the table name."""
    # Remove parentheses and replace with underscores
    name = re.sub(r'\(|\)', '', name)
    
    # Replace spaces with underscores
    name = name.replace(' ', '_')
    
    # Remove leading underscores
    name = name.lstrip('_')
    
    return name

def main():
    source_folder = '/Users/zhangzuogong/Desktop/历史数据-中臣零配件集成业务平台'
    mapping_output_file = '/Users/zhangzuogong/Desktop/map表文件夹/translated_mapping.xlsx'
    error_log_file = '/Users/zhangzuogong/Desktop/map表文件夹/error_log.txt'
    
    server = '139.196.89.86'
    database = 'yanji_备料'
    username = 'yanji_bl'
    password = 'Password.1'

    # Setup logging
    logging.basicConfig(filename=error_log_file, level=logging.ERROR, 
                        format='%(asctime)s %(levelname)s %(message)s')

    # Create database engine
    print("Creating database engine...")
    engine = get_sqlalchemy_engine(server, database, username, password)
    
    # Initialize translator
    print("Initializing translator...")
    translator = Translator()

    # Prepare mapping list
    mappings = []

    # Counters for success and failure
    success_count = 0
    failure_count = 0

    # Process each Excel file
    print(f"Scanning source folder: {source_folder}")
    excel_files = get_all_excel_files(source_folder)
    for excel_file in excel_files:
        file_path = excel_file
        base_name = os.path.splitext(os.path.basename(excel_file))[0]
        
        print(f"Processing file: {excel_file}")
        
        # Translate the name
        table_name = translate_text(base_name, translator)
        
        # Clean and format the table name
        table_name = clean_table_name(table_name)
        
        # Handle numbers in the name
        match = re.search(r'\d+', base_name)
        if match:
            number_suffix = match.group()
            table_name = re.sub(r'\d+', '', table_name).strip() + '_' + number_suffix
        
        # Shorten the table name if necessary
        table_name = shorten_name(table_name)
        
        # Import data to database
        print(f"Importing data to table: {table_name}")
        success = import_excel_to_db(file_path, table_name, engine)
        if success:
            success_count += 1
        else:
            failure_count += 1
            with open(error_log_file, 'a') as log_file:
                log_file.write(f"Failed to import {file_path} into {table_name}\n")
        
        # Add to mappings
        mappings.append((base_name, table_name))

    # Save mappings to Excel file
    print(f"Saving mapping file to: {mapping_output_file}")
    mapping_df = pd.DataFrame(mappings, columns=['Chinese Name', 'English Name'])
    mapping_df.to_excel(mapping_output_file, index=False)
    print(f"Mapping file saved to {mapping_output_file}")

    # Print summary
    print(f"Total tables successfully imported: {success_count}")
    print(f"Total tables failed to import: {failure_count}")

if __name__ == "__main__":
    main()
