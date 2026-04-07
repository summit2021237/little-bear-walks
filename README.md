# little-bear-walks
This is a dog walk scheduler that creates an optimal dog walking schedule using each person's preferences for each walk and generates importable calendar events.
## Installation
The dog walk scheduler can be installed and run from the source code.
### Prerequisites
- Docker
- Make
### Download
Clone the repository or download a ZIP file.
```
git clone https://github.com/summit2021237/little-bear-walks.git
```
## Usage
The dog walk scheduler takes in a configuration JSON file in the top-level directory and walk ratings in a `data` directory. It outputs an `output` directory containing a text file of Pyomo's solution, a CSV file with the walk assignments, and ICS files with calendar events for each person's walks.  

An example file tree after running the scheduler with person1, person2, and person3 is below.
```
.
├── config.json
├── data
│   ├── person1_ratings.csv
│   ├── person2_ratings.csv
│   └── person3_ratings.csv
├── Dockerfile
├── documentation
│   ├── config_example.json
│   ├── config_file.md
│   ├── model.pdf
│   └── model.tex
├── entrypoint.sh
├── Makefile
├── output
│   ├── assignments.csv
│   ├── person1.ics
│   ├── person2.ics
│   ├── person3.ics
│   └── solution.txt
├── README.md
├── requirements.txt
└── src
    ├── assignments_to_ics.pl
    ├── create_dat.pl
    ├── modeling_problem.py
    ├── solution_to_assignments.pl
    └── WalkConfig.pm
 ```
### Configuration File
See [config_file.md](https://github.com/summit2021237/little-bear-walks/blob/main/documentation/config_file.md) for an explanation of the configuration file.
### Rating Files
Each person can rate their preference for each walk on the scale 0-9 defined by
- 0: Unavailable and not possible to be available (ex: out of town)
- 1: Unavailable but possible and inconvenient to be available (ex: doctor’s appointment)
- 2: Between 1 and 3
- 3: Does not prefer this walk
- 4: Between 3 and 5
- 5: No preference
- 6: Between 5 and 7
- 7: Prefers this walk
- 8: Between 7 and 9
- 9: Some kind of special event (ex: annual bunny hunting day)  

There is one rating file per person, which goes in the `data` directory. The rating file must have the format
| Date       | Time1  | Time2  | ... | TimeN  |
| ---------- | ------ | ------ | --- | ------ |
| MM/DD/YYYY | Rating | Rating | ... | Rating |
| ...        | ...    | ...    | ... | ...    |
| MM/DD/YYYY | Rating | Rating | ... | Rating |
### Solving the Model
The model can be solved by running the following command in the same directory as `Makefile`.
```
make
```
That command removes the `output` directory (if it exists), creates a new `output` directory, and builds and runs the solver in a Docker container.
### Output
There are three types of output files
- `assignments.csv`
- `solution.txt`
- `*.ics`
#### `assignments.csv`
This file contains all the walk assignments, formatted as  
|            |       |       |     |       |
| ---------- | ----- | ----- | --- | ----- |
| MM/DD/YYYY | Name  | Name  | ... | Name  |
| ...        | ...   | ...   | ... | ...   |
| MM/DD/YYYY | Name  | Name  | ... | Name  |
#### `solution.txt`
This contains the solution output from Pyomo. It describes a termination condition, hopefully "optimal," and values assigned to the variables in the solution.
### `*.ics`
An ICS file is generated for each person. It contains calendar events for each walk they are assigned to so that the events can easily be imported into the person's calendar.
## Potential Features
Some potential features are
- Identify which walks cannot be assigned (when everyone rates a walk as 0)
- Variable number of walks per day
- Not distributing durations evenly (if some people agree to do more or less walks)
