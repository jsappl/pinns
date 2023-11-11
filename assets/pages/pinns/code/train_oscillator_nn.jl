# This file was generated, do not modify it. # hide
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