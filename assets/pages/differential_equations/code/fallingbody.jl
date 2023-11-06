# This file was generated, do not modify it. # hide
using OrdinaryDiffEq, PlotlyJS

# parameters
g = 9.81  # earth's gravity

# initial conditions
s₀ = [55.86]  # Leaning Tower of Pisa [m]
ds₀ = [20.0]  # average baseball throw [m/s]
tspan = (0.0, 7.0)  # time [s]

# define the problem
fallingbody!(dds, ds, s, p, t) = @. dds = -g

# pass to solvers
prob = SecondOrderODEProblem(fallingbody!, ds₀, s₀, tspan)
sol = solve(prob, DPRKN6(); saveat=0.5)

# define analytical solution
trueposition(t) = @. -1/2*g*t^2 + ds₀*t + s₀

# plot results
layout = Layout(;
    xaxis_title="Time [s]",
    yaxis_title="Position [m]",
)
trace1 = scatter(x=sol.t, y=max.(0, trueposition(sol.t)), name="true", mode="lines")
trace2 = scatter(x=sol.t, y=max.(0, last.(sol.u)), name="numerical")
plt = plot([trace1, trace2], layout)
fdplotly(json(plt))  # hide