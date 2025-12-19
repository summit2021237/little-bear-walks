from __future__ import division # safety with double division
from pyomo.environ import *
from pyomo.opt import SolverFactory

# Instantiate and name the model
M = AbstractModel()
M.name = "Little Bear Walk Modeling Problem"

# Sets
M.People = Set()
M.Dates = Set()
M.Times = Set()

# Parameters
M.WalkNeeded = Param(M.Times, M.Dates, default=1, within=Binary)
M.Ratings = Param(M.Times, M.Dates, M.People, default=5, within=NonNegativeIntegers)
M.Lengths = Param(M.Times, within=NonNegativeIntegers)
M.MaxWalkFrac = Param(within=NonNegativeReals)
M.ThreeWalkFactor = Param(within=NonNegativeReals)

# Variables
M.Assignments = Var(M.Times, M.Dates, M.People, within=Binary)
M.IsThreeWalks = Var(M.Dates, M.People, within=Binary)

# Objective
def CalcSchedule(M):
    return sum(sum(sum(M.Ratings[t, d, p]*M.WalkNeeded[t, d]*M.Assignments[t, d, p] for p in M.People) for d in M.Dates) for t in M.Times) - M.ThreeWalkFactor*sum(sum(M.IsThreeWalks[d, p] for d in M.Dates) for p in M.People)
M.Schedule = Objective(rule=CalcSchedule, sense=maximize)

# Constraints
def EnsureOnePersonForWalk(M, t, d):
    return sum(M.Assignments[t, d, p] for p in M. People) == M.WalkNeeded[t, d]
M.OnePersonForWalk= Constraint(M.Times, M.Dates, rule=EnsureOnePersonForWalk)

def EnsureDurationsSimilar(M, p):
    return sum(sum(M.Lengths[t]*M.Assignments[t, d, p] for d in M.Dates) for t in M.Times) <= M.MaxWalkFrac*sum(sum(M.Lengths[t]*M.WalkNeeded[t, d] for d in M.Dates) for t in M.Times)
M.DurationsSimilar = Constraint(M.People, rule=EnsureDurationsSimilar)

def EnsurePersonUnavailable(M, t, d, p):
    return M.Assignments[t, d, p] <= M.Ratings[t, d, p]
M.PersonUnavailable = Constraint(M.Times, M.Dates, M.People, rule=EnsurePersonUnavailable)

def EnsureIsThreeWalksVarLower(M, d, p):
    return sum(M.Assignments[t, d, p] for t in M.Times) - 2 <= M.IsThreeWalks[d, p]
M.IsThreeWalksVarLower = Constraint(M.Dates, M.People, rule=EnsureIsThreeWalksVarLower)

def EnsureIsThreeWalksVarUpper(M, d, p):
    return sum(M.Assignments[t, d, p] for t in M.Times) >= 3*M.IsThreeWalks[d, p]
M.IsThreeWalksVarUpper = Constraint(M.Dates, M.People, rule=EnsureIsThreeWalksVarUpper)

# Create a problem instance
instance = M.create_instance("modeling_problem.dat")

# Indicate which solver to use
Opt = SolverFactory("glpk")

# Generate a solution
Soln = Opt.solve(instance)
instance.solutions.load_from(Soln)

# Print the output
print("Termination Condition was "+str(Soln.Solver.Termination_condition))
display(instance)
