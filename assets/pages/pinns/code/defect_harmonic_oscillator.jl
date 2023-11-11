# This file was generated, do not modify it. # hide
using OrdinaryDiffEq, PlotlyJS

k = 1.0

force(dx, x, k, t) = -k*x + 0.1*sin(x)

prob = SecondOrderODEProblem(force, 1.0, 0.0, (0.0, 10.0), k)
sol = solve(prob, RK4())

traces = [
    scatter(x=sol.t, y=first.(sol.u), name="velocity", mode="lines+markers"),
    scatter(x=sol.t, y=last.(sol.u), name="position", mode="lines+markers"),
]

plt = plot(traces)
fdplotly(json(plt))  # hide