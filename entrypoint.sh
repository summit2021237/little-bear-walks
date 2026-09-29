#!/bin/bash
# Load and create dat file
perl ./src/create_dat.pl
if (($? != 0)); then
	exit 1
fi

# Solve model
cd /usr/local/app/src
../venv/bin/python3 modeling_problem.py > ../output/solution.txt
cd /usr/local/app

# Parse results
perl ./src/solution_to_assignments.pl

# Create ics files
perl ./src/assignments_to_ics.pl
