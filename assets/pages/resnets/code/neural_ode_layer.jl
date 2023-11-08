# This file was generated, do not modify it. # hide
using DiffEqFlux, PlotlyJS

u0 = Float32[2.; 0.]
n_samples = 16
tspan = (0.0f0, 1.5f0)

function trueODEfunc(du, u, p, t)
    true_A = [-0.1 2.0; -2.0 -0.1]
    du .= ((u.^3)'true_A)'
end
t = range(tspan[1], tspan[2], length=n_samples)
prob = DiffEqFlux.ODEProblem(trueODEfunc, u0, tspan)
ode_data = Array(solve(prob, Tsit5(), saveat=t))

model = Chain(
    x -> x.^3,
    Dense(2, 50, tanh),
    Dense(50, 2),
)

n_ode = NeuralODE(model, tspan, Tsit5(), saveat=t, reltol=1e-7, abstol=1e-9)
ps = Flux.params(n_ode)

loss_n_ode() = sum(abs2, ode_data .- n_ode(u0))

data = Iterators.repeated((), 25)  # epochs

Flux.train!(loss_n_ode, ps, data, ADAM(0.1))
pred = n_ode(u0)

traces = [
    scatter(x=t, y=ode_data[1, :], name="u_1", mode="lines+markers"),
    scatter(x=t, y=ode_data[2, :], name="u_2", mode="lines+markers"),
    scatter(x=t, y=pred[1, :], name="u_1 pred", mode="lines+markers"),
    scatter(x=t, y=pred[2, :], name="u_2 pred", mode="lines+markers"),
]

plt = plot(traces)
fdplotly(json(plt))  # hide