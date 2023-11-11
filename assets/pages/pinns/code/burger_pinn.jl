# This file was generated, do not modify it. # hide
using NeuralPDE, Lux, Optimization, OptimizationOptimJL
import ModelingToolkit: Interval

@parameters t, x
@variables u(..)
Dt = Differential(t)
Dx = Differential(x)
Dxx = Differential(x)^2

# Space and time domains
domains = [
    t ∈ Interval(0.0, 1.0),
    x ∈ Interval(-1.0, 1.0),
]

eq = Dt(u(t, x)) + u(t, x) * Dx(u(t, x)) - (0.01 / pi) * Dxx(u(t, x)) ~ 0

# Initial and boundary conditions
bcs = [
    u(0, x) ~ -sin(pi * x),
    u(t, -1) ~ 0.0,
    u(t, 1) ~ 0.0,
    u(t, -1) ~ u(t, 1),
]

# Neural network
model = Lux.Chain(
    Lux.Dense(2, 16, Lux.σ),
    Lux.Dense(16, 16, Lux.σ),
    Lux.Dense(16, 1),
)

# Discretization
dx = 0.05
discretization = PhysicsInformedNN(model, GridTraining(dx))

@named pde_system = PDESystem(eq, bcs, domains, [t, x], [u(t, x)])
prob = discretize(pde_system, discretization)

# optimizer
opt = OptimizationOptimJL.BFGS()

res = Optimization.solve(prob, opt, maxiters=1024)
phi = discretization.phi