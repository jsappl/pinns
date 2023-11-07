# This file was generated, do not modify it. # hide
using OrdinaryDiffEq, PlotlyJS

# parameters
ω = 1

# initial conditions
x₀ = [0.0]
dx₀ = [π/2]
tspan = (0.0, 2π)
ts = 0:0.05:2π

# known analytical solution
ϕ = atan((dx₀[1] / ω) / x₀[1])
A = √(x₀[1]^2 + dx₀[1]^2)
truesolution(t) = @. A * cos(ω * t - ϕ)

# define the problem
function harmonicoscillator(ddu, du, u, ω, t)
    return @. ddu = -ω^2 * u
end
prob = SecondOrderODEProblem(harmonicoscillator, dx₀, x₀, tspan, ω)

# pass to solvers
midpoint = solve(prob, Midpoint())
rk4 = solve(prob, RK4())
tsit5 = solve(prob, Tsit5())

# plot results
traces = [
    PlotlyJS.scatter(x=ts, y=truesolution(ts), name="true", mode="lines"),
    PlotlyJS.scatter(x=midpoint.t, y=last.(midpoint.u), name="midpoint", mode="lines+markers"),
    PlotlyJS.scatter(x=rk4.t, y=last.(rk4.u), name="rk4", mode="lines+markers"),
    PlotlyJS.scatter(x=tsit5.t, y=last.(tsit5.u), name="tsit5", mode="lines+markers"),
]
plt = PlotlyJS.plot(traces)
fdplotly(json(plt))  # hide