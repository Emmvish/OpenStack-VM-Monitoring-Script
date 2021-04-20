import json
with open('test1.json') as input_file:
    data = json.load(input_file)
    with open('diagnostic_logs.json', 'a+') as out_file:
        for e in data:
           json.dump(e, out_file)
           out_file.write('\n')
