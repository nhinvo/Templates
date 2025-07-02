# Python
## Useful Python commands 
- To turn directories into web page - easier to view .html files
    - `python3 -mhttp.server 8081` or `python3 -m https.server 8000` or `python3 -m https.server 8050`

## Parallel Programming in Python 
You want to run function `process_file(file_path)` in parallel. By itself, `process_file()` function takes in `file_path` as input, a string to input file to process.  
To set this up paralellization:  

```
with Pool(processes=NUM_CPU) as pool:
    pool.map(process_file, file_paths)  
```

`file_paths` is a list of input file paths to process through the function `process_file()` in parallel.  
All together, your script would look like this: 

```
def process_file(file_path):
    """
    Example of function to run in parallel. 
    Count number of lines in input file. 
    """
    line_count = 0

    with open(file_path, 'r') as input_file:
        # count lines
        for line in file:
            line_count += 1

    print(line_count)

def main():
    file_paths = ['fileA.txt', 'fileB.txt']

    # run function in parallel with 5 CPUs
    with Pool(processes=5) as pool:
        pool.map(process_file, file_paths)  

main()
```

If you want to pass in more than 1 variable:  
```
def process_file(input_tuple):
    """
    Example of function to run in parallel. 
    Count number of lines in input file. 
    """
    input_path = input_tuple[0]
    output_path = output_tuple[1]

    # code to perform processing on input file 
    # coee to save data to output file 

def main():
    # input list can contain tuple
    process_file_inputs = [
        ('fileA.in', 'fileA.out'), 
        ('fileB.out', 'fileB.out), 
    ]

    # run function in parallel with 5 CPUs
    with Pool(processes=5) as pool:
        pool.map(process_file, process_file_inputs)  

main()
```

Using a dict instead of tuple: 
```
def process_file(input_dict):
    """
    Example of function to run in parallel. 
    Count number of lines in input file. 
    """
    input_path = input_dict['input']
    output_path = input_dict['output']

    # code to perform processing on input file 
    # coee to save data to output file 

def main():
    # input list can contain dict
    process_file_inputs = [
        {'input': 'fileA.in', 'output': 'fileA.out'}, 
        {'input': 'fileB.in', 'output': 'fileB.out'}, 
    ]

    # run function in parallel with 5 CPUs
    with Pool(processes=5) as pool:
        pool.map(process_file, process_file_inputs)  

main()
```

