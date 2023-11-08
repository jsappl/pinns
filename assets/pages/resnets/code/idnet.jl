# This file was generated, do not modify it. # hide
using Flux
using BenchmarkTools: @benchmark

actual(x) = x

x_train = hcat(-10:10...)
y_train = actual.(x_train)

dense = Chain(
    Dense(1 => 1, tanh),
    Dense(1 => 1, tanh),
    Dense(1 => 1, tanh),
    Dense(1 => 1, identity),
)

loader = Flux.DataLoader((x_train, y_train), batchsize=8, shuffle=true);

function loop(model)
    optim = Flux.setup(Adam(), model)

    for epoch in 1:10_000
        Flux.train!(model, loader, optim) do m, x, y
            y_hat = m(x)
            Flux.mse(y_hat, y)
        end

        Flux.mse(model(x_train), x_train) < 0.01 && break
    end

end

@benchmark loop(dense)