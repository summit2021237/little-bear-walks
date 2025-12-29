#!/bin/bash
# Solve model
cd /usr/local/app/src
../venv/bin/python3 modeling_problem.py > ../output/solution.txt
cd /usr/local/app

# Parse results
perl ./src/solution_to_assignments.pl

perl ./src/assignments_to_ics.pl
