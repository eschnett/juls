#= This script includes all modules and functions, sets up the grid parameters
etc, and runs the model =#

using Dates
using NetCDF
using FileIO
using Statistics

if VERSION == v"0.7.0"
    using Printf
end

#using MPI
#using SigmoidNumbers

# Finite16nonu
#include("/home/kloewer/julia/FiniteFloats.jl/src/FiniteFloats.jl")

# PARAMETERS, GRID, CONSTANTS and DOMAIN DECOMPOSITION
include("parameters.jl")
include("src/grid.jl")
include("src/constants.jl")
#include("src/domain_decomposition.jl")

# OPERATORS and everything that is needed for the RHS
include("src/gradients.jl")
include("src/interpolations.jl")
include("src/PV_adv.jl")
include("src/bottom_friction.jl")
include("src/diffusion.jl")
include("src/tracer_adv.jl")
include("src/coriolis.jl")
include("src/forcing.jl")
include("src/bottom_topography.jl")
include("src/rhs.jl")
include("src/time_integration.jl")
include("src/ghost_points.jl")
include("src/initial_conditions.jl")
include("src/preallocate.jl")

# OUTPUT AND FEEDBACK
include("src/feedback.jl")
include("src/output.jl")

# INITIALISE
for ens_mem in 1:20
	global run_id,runpath
	run_id,runpath = get_run_id_path("fill")
	starti = load(initpath*"starti.jld2")["starti"][run_id+1]
	println("Ensemble member $ens_mem, start from $starti")

	u,v,η,sst = initial_conditions(starti)
	u,v,η,sst = time_integration(u,v,η,sst)

	println()
end
