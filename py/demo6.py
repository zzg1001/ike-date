import os
import re
import pandas as pd
from googletrans import Translator
import time

def get_all_excel_files(folder_path):
    """Recursively get a list of all Excel files in the specified folder and its subfolders."""
    print(f"Scanning folder: {folder_path}")
    excel_files = []
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            if file.endswith('.xlsx') or file.endswith('.xls'):
                file_path = os.path.join(root, file)
                print(f"Found Excel file: {file_path}")
                excel_files.append(file_path)
    print(f"Total {len(excel_files)} Excel files found.")
    return excel_files

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

def translate_file_names(excel_files):
    """Translate the file names from Chinese to English."""
    translator = Translator()
    translations = []
    modified_count = 0
    print("Translating file names...")
    for file_path in excel_files:
        file_name = os.path.basename(file_path)
        # Remove file extension
        base_name = os.path.splitext(file_name)[0]
        
        # Translate the name
        translation = translate_text(base_name, translator)
        
        # Replace spaces with underscores
        translation = translation.replace(' ', '_')
        
        # Handle numbers in the name
        match = re.search(r'\d+', base_name)
        if match:
            number_suffix = match.group()
            translation = re.sub(r'\d+', '', translation).strip() + '_' + number_suffix
        
        # Shorten the translation if necessary
        translation = shorten_name(translation)
        
        # Remove leading hyphen if present
        if translation.startswith('-'):
            translation = translation[1:].strip('_')
        
        # Add file extension back to the translation
        translated_name = translation + os.path.splitext(file_name)[1]
        
        translations.append((file_name, translated_name))
        if file_name != translated_name:
            modified_count += 1
        print(f"{file_name} -> {translated_name}")
    return translations, modified_count

def main():
    source_folder = '/Users/zhangzuogong/Desktop/历史数据-中臣零配件集成业务平台'
    target_folder = '/Users/zhangzuogong/Desktop/map表'
    
    print("Starting the process...")
    excel_files = get_all_excel_files(source_folder)
    translations, modified_count = translate_file_names(excel_files)
    
    # Convert to DataFrame and write to Excel
    print("Saving translations to Excel...")
    df = pd.DataFrame(translations, columns=['Chinese Name', 'English Name'])
    output_path = os.path.join(target_folder, 'translated_names.xlsx')
    df.to_excel(output_path, index=False)
    print(f"Translation completed. Results saved to {output_path}")
    print(f"Total modified file names: {modified_count}")

if __name__ == "__main__":
    main()
