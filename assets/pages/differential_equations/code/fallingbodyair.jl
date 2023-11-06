# This file was generated, do not modify it. # hide
using OrdinaryDiffEq, PlotlyJS

# parameters of Apollo 15 experiment
g = 9.81  # earth's gravity
k = 1.0
m_feather = 0.03  # [kg]
m_hammer = 1.32  # [kg]

# initial conditions
s₀ = [55.86]  # Leaning Tower of Pisa [m]
ds₀ = [0.0]  # drop [m/s]
tspan = (0, 15)  # [s]

# define the problems
function fallingbodyair!(dds, ds, s, p, t)
    k, m = p

    return @. dds = -m*g + k*ds
end

# pass to solvers
prob = SecondOrderODEProblem(fallingbodyair!, ds₀, s₀, tspan, [k, m_feather])
sol_feather = solve(prob, DPRKN6(); saveat=0.1)
prob = SecondOrderODEProblem(fallingbodyair!, ds₀, s₀, tspan, [k, m_hammer])
sol_hammer = solve(prob, DPRKN6(); saveat=0.1)

# plot results
layout = Layout(;
    xaxis_title="Time [s]",
    yaxis_title="Position [m]",
)

trace1 = scatter(x=sol_feather.t, y=max.(0, last.(sol_feather.u)), name="feather")
trace2 = scatter(x=sol_hammer.t, y=max.(0, last.(sol_hammer.u)), name="hammer")

plt = plot([trace1, trace2], layout)
fdplotly(json(plt))  # hide