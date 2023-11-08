# This file was generated, do not modify it. # hide
using OrdinaryDiffEq, PlotlyJS

function lotka_volterra(du, u, params, t)
    🐰, 🐺 = u
    α, β, δ, γ = params
    du[1] = d🐰 = α*🐰 - β*🐰*🐺
    du[2] = d🐺 = -δ*🐺 + γ*🐰*🐺
end

u0 = [1.0, 1.0]
tspan = (0.0, 15.0)
params = [1.5, 1.0, 3.0, 1.0]

prob = ODEProblem(lotka_volterra, u0, tspan, params)
sol = solve(prob, Tsit5(); saveat=0.2)

# plot results
layout = Layout(;
    xaxis_title="Time [d]",
    yaxis_title="Number",
)

rabbits = scatter(x=sol.t, y=first.(sol.u), name="rabbits")
wolves = scatter(x=sol.t, y=last.(sol.u), name="wolves")

plt = plot([rabbits, wolves], layout)
fdplotly(json(plt))  # hide