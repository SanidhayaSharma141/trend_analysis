import csv
import json

def csv_to_json(csv_file_path):
    json_data = []
    with open(csv_file_path, 'r', encoding='utf-8-sig') as csv_file:
        csv_reader = csv.DictReader(csv_file)
        for row in csv_reader:
            json_data.append(row)
    return json_data

if __name__ == "__main__":
    csv_file_path = 'salaries.csv'
    json_file_path = 'output.json'

    json_data = csv_to_json(csv_file_path)
    with open(json_file_path, 'w') as json_file:
        json.dump(json_data, json_file, indent=4)
    print("CSV data converted to JSON and saved to", json_file_path)
