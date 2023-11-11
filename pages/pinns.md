+++
title = "PINNs"
hascode = true
noeval = false
hasplotly = true
reeval = false
+++

# Physics-Informed Neural Networks

\tableofcontents

## Introduction

After introducing [DEs](/pages/differential_equations/) including ODEs and PDEs we saw how to [numerically solve](/pages/numerical_methods/) such (systems of) equations. The [ResNet architecture](/pages/resnets/) can be reformulated as an ODE problem and solved using said numerical schemes. This approach naturally led to [neural ODEs](/pages/resnets/#neural_odes) where a neural network is trained to approximate not the solution, but the dynamics of the underlying ODE based on data samples. However, do these algorithms actually understand the scientific problems they are trying to solve? In this chapter we explain physics-informed neural networks, which are a powerful way of incorporating physical principles into machine learning.

Machine learning has caused a fundamental shift in the scientific method. Traditionally, scientific research has revolved around theory and experiment. After a well-defined theory is formulated it is continuously refined using experimental data and analysis to make new predictions. But today, with rapid advances in the field of machine learning and increasing amounts of scientific data, data-driven approaches have become very popular. Here, an existing theory is not required, and instead a machine learning algorithm can be used to analyze a scientific problem using data alone.

## Preliminary Example: Part I

DEs encoding physical laws can be utilized inside of loss functions for systems which we believe should approximately follow some physical law. But first, let us investigate how a model trained on data without any physical information behaves. For that purpose we will again consider the [harmonic oscillator](/pages/numerical_methods/#example_comparing_solvers).

We take measurements of position and force of some real one-dimensional spring pushing and pulling against a wall.
But instead of the simple spring, we assume we had a more complex spring, that is

\begin{equation*}
F(x) = -kx + 0.1 \sin x\,,
\end{equation*}

where the extra term is due to some deformities in the metal. Then by Newton's law of motion we have a second-order ODE

\begin{equation*}
x'' = -kx + 0.1\sin x\,.
\end{equation*}

As a reminder we use the `OrdinaryDiffEq.jl` package to solve this DE and see what the physical system looks like.

```julia:defect_harmonic_oscillator
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
```
\textoutput{defect_harmonic_oscillator}

We want to learn how to predict the force $F(x)$ applied on the spring at each point in space. Assume that we only have six measurements, which includes the information about position, velocity, and force at evenly spaced times.

```julia:harmonic_samples
plot_t = 0:0.01:10
data_plot = sol(plot_t)
positions_plot = [state[2] for state in data_plot]

t = 0:3.3:10
force_data = [force(state[1], state[2], k, t) for state in sol(t)]

traces = [
    scatter(x=plot_t, y=[force(state[1], state[2], k, t) for state in data_plot], name="true force", mode="lines"),
    scatter(x=t, y=force_data, name="samples", mode="markers"),
]

plt = plot(traces)
fdplotly(json(plt))  # hide
```
\textoutput{harmonic_samples}

We define a neural network to be $F(x)$ and see if it can learn the force function.

```julia:train_oscillator_nn
using Flux

NNForce = Chain(
    x -> [x],
    Dense(1 => 32, tanh),
    Dense(32 => 1),
    first,
)

position_data = [state[2] for state in sol(t)]
loss() = sum(abs2, NNForce(position_data[i]) - force_data[i] for i in 1:length(position_data))

opt = Flux.Descent(0.01)
data = Iterators.repeated((), 128)  # epochs

Flux.train!(loss, Flux.params(NNForce), data, opt)
```

Plot the result of the trained neural network.

```julia:harmonic_nn_plot
force_plot = [force(state[1],state[2],k,t) for state in data_plot]
learned_force_plot = NNForce.(positions_plot)

traces = [
    scatter(x=plot_t, y=force_plot, name="true force"),
    scatter(x=plot_t, y=learned_force_plot, name="predicted force"),
    scatter(x=t, y=force_data, name="samples", mode="markers"),
]

plt = plot(traces)
fdplotly(json(plt))  # hide
```
\textoutput{harmonic_nn_plot}

The neural network almost exactly matched the data set, but it failed to actually learn the real force function. The problem is that a neural network can approximate any function, so it approximated a function that fits the data, but not the correct function. In order to alleviate this issue the idea is to introduce the neural network to physical laws.

## Problem Setup

Let us consider a parametrized nonlinear partial differential equation of the general form

\begin{equation*}
u_t + \mathcal{N}[u;\lambda] = 0\,,
\end{equation*}

where $u(t,x)$ denotes the unknown solution and $\mathcal{N}[\cdot;\lambda]$ is a nonlinear differential operator parametrized by $\lambda$. This formulation covers a wide range of problems in mathematical physics including conservation laws, diffusion processes, advection-diffusion-reaction systems, and kinetic equations. As a motivating example, the one dimensional Burgers’ equation, which we will again see later, corresponds to

\begin{equation*}
\mathcal{N}[u;\lambda] = \lambda_1 uu_x - \lambda_2 u_{xx}\text{ and }\lambda = (\lambda_1, \lambda_2)\,.
\end{equation*}

Given noisy measurements of the system, we are interested in the solution of two distinct problems. The first problem is that of predictive inference, filtering and smoothing, or data-driven solutions of PDEs which states:

@@colbox-blue
Given fixed model parameters $\lambda$ what can be said about the unknown hidden state $u(t, x)$ of the system?
@@

The second problem is that of learning, system identification, or data-driven discovery of PDEs stating:

@@colbox-blue
What are the parameters $\lambda$ that best describe the observed data?
@@

For the first question, we focus on computing data-driven solutions to PDEs of the general form
\begin{equation}\label{eq:general_form}
u_t + \mathcal{N}[u] = 0\,,\ x\in \Omega\,,\ t\in[0,T]\,,
\end{equation}

where $\Omega$ is a subset of $\mathbb{R}^D$ and $T>0$ is the end point in time.

We inform the neural network about any physical laws governing the underlying system via the loss function. The shared parameters between the neural network $u(t, x)$ and $f(t, x)$ are then trained by minimizing the mean squared error loss

\begin{equation*}
\mathcal{L} = \frac{1}{N_u} \sum_{j=1}^{N_u} \big| u(t_u^j, x_u^j) - u^j \big|^2
+ \frac{1}{N_f} \sum_{j=1}^{N_f} \big| f(t_f^j, x_f^j) \big|^2
\end{equation*}

Here, $(t_u^j, x_u^j, u^j)_{j=1}^{N_u}$ denote the initial and boundary training data on $u(t,x)$ and $(t_f^j, x_f^j)_{j=1}^{N_f}$ specify the collocation points for $f(t,x)$. The first term in $\mathcal{L}$ corresponds to a regular regression problem on the initial and boundary data, whereas the second term enforces the structure imposed by the DE at a finite set of collocation points.

## Preliminary Example: Part II

Recall the preliminary results about the harmonic oscillator from [Part I](/pages/pinns/#preliminary_example_part_i) at the beginning of this chapter.
According to Hooke's law an idealized spring should satisfy $F(x) = -kx$.
This is a decent hypothesis for the evolution of the system even if the measured samples actually are from a deformed spring.
As a useful non-data assumption we can add it to improve the fitting. So, assuming we know $k$, we can regularize this fitting by having a term that states our neural network should be the solution to the DE.

```julia:loss_ode
random_positions = [2*rand() - 1 for i in 1:100]
loss_ode() = sum(abs2, NNForce(x) - (-k*x) for x in random_positions)
```

If this term is zero then $F(x) = -kx$ and the neural network satisfies the DE. We combine this loss with the regular regression loss from before

```julia:composed_loss
λ = 0.1
composed_loss() = loss() + λ*loss_ode()
```

where $\lambda$ is some weight factor to control the regularization against the physics assumption. Now we can train the physics-informed neural network.

```julia:train_pinn
opt = Flux.Descent(0.01)
data = Iterators.repeated((), 128)
t = 0:3.3:10  # hide

Flux.train!(composed_loss, Flux.params(NNForce), data, opt)

traces = [
    scatter(x=plot_t, y=force_plot, name="true force"),
    scatter(x=plot_t, y=NNForce.(positions_plot), name="predicted force"),
    scatter(x=t, y=force_data, name="samples", mode="markers"),
]

plt = plot(traces)
fdplotly(json(plt))  # hide
```
\textoutput{train_pinn}

## Continuous Time Models

Define the function $f(t,x)$ to be given by the LHS of \eqref{eq:general_form}, that is

\begin{equation*}
f \coloneqq u_t + \mathcal{N}[u]
\end{equation*}

and proceed by approximating the unknown solution $u(t,x)$ by a (deep) neural network. This assumption results in a physics-informed neural network. This network can be derived by applying the chain rule for differentiating compositions of functions using automatic differentiation.

### Example (Burgers' Equation)

As mentioned above the 1D Burgers' equation along with Dirichlet boundary conditions reads as

\begin{equation*}
\begin{aligned}
u_t + uu_x - (0.001 / \pi)u_{xx} &= 0\,,\quad x \in [-1,1]\,,\quad t\in[0,1]\,, \\
u(0,x) &= -\sin(\pi x)\,, \\
u(t, -1) &= u(t,1) = 0\,.
\end{aligned}
\end{equation*}

We are going to set up this equation step by step using the [`NeuralPDE.jl`](https://docs.sciml.ai/NeuralPDE/stable/) framework. For a general overview of libraries see also the [Software](/pages/software/overview/) chapter.

Julia define parameters time $t$ and space $x$ along with all the differentials occurring in the PDE
```julia:burger_pinn
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
```

Plot the results from solving Burgers' equation with a PINN.

```julia:plot_pinn
using Plots
gr()

ts, xs = [infimum(d.domain):dx:supremum(d.domain) for d in domains]

u_predict = reshape(
    [phi([t, x], res.u)[1] for t in ts for x in xs],
    (length(xs), length(ts)),
)

Plots.contour(
    ts, xs,
    u_predict,
    fill=true,
)
Plots.savefig(joinpath(@OUTPUT, "plot_pinn.png"))  # hide
```
\fig{plot_pinn.png}

## Discrete Time Models

A limitation of the continuous time neural network models stems from the need to use a large number of collocation points $N_f$ in order to enforce physics-informed constraints in the entire spatio-temporal domain. Although this poses no significant issues for problems in one or two spatial dimensions, it may introduce a severe bottleneck in higher dimensional problems, as the total number of collocation points needed to globally enforce a physics-informed constrain, i.e., in our case a PDE, increases exponentially. Hence, in this section, a different approach that circumvents the need for collocation points by introducing a more structured neural network representation leveraging the classical [Runge-Kutta](/pinns/pages/numerical_methods/#runge-kutta_methods) time-stepping schemes is introduced.

\figenv{Architecture of the RK-PINN.}{/assets/pinns/Architecture-of-the-RK-PINN.png}{100%}

The discrete time-stepping scheme is part of the training process. Instead of training the network to approximate a continuous-time solution, we discretize the time domain and update the network at specific time steps.

The basic algorithm works as follows.
1. Define a set of discrete time points at which you want to evaluate the solution. This can be achieved using a fixed or variable time step $\Delta t$.
1. Use the neural network to predict the RK-stages from which we then construct the state prediction $\hat x^1$.
1. Use some RK scheme update rule with known coefficients and compare the numerical result with the neural network output.
1. Evaluate the error element-wise for each RK-stage and train the neural network based on these.

## References
- \biblabel{moseley2021physics}{Moseley (2021)} **Moseley**, So, what is a physics-informed neural network?, 2021, <https://benmoseley.blog/my-research/so-what-is-a-physics-informed-neural-network/>.
- \biblabel{rackauckas2022parallel}{Rackauckas et al. (2022)} **Rackauckas**, **Vaverka** et al., Parallel Computing and Scientific Machine Learning (SciML): Methods and Applications, 2022, <https://book.sciml.ai/>.
- \biblabel{raissi2017aphysics}{Raissi et al. (2017)} **Raissi**, **Perdikaris** and **Karniadakis**, Physics Informed Deep Learning (Part I): Data-driven Solutions of Nonlinear Partial Differential Equations, 2017.
- \biblabel{raissi2017bphysics}{Raissi et al. (2017)} **Raissi**, **Perdikaris** and **Karniadakis**, Physics Informed Deep Learning (Part II): Data-driven Discovery of Nonlinear Partial Differential Equations, 2017.
- \biblabel{raissi2019physics}{Raissi et al. (2019)} **Raissi**, **Perdikaris** and **Karniadakis**, Physics-informed neural networks: A deep learning framework for solving forward and inverse problems involving nonlinear partial differential equations, 2019.
- \biblabel{ray2023lecture}{Ray et al. (2023)} **Ray**, **Pinti** and **Oberai**, Deep Learning and Computational Physics (Lecture Notes), 2023, <https://arxiv.org/pdf/2301.00942.pdf>.
- \biblabel{stiasny2021learning}{Stiasny} **Stiasny**, **Chevalier** and **Chatzivasileiadis**, Learning without Data: Physics-Informed Neural Networks for Fast Time-Domain Simulation, 2021, <https://arxiv.org/pdf/2106.15987.pdf>.
