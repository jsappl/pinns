# This file was generated, do not modify it. # hide
resnet = Chain(
    SkipConnection(
        Chain(
            Dense(1 => 1, tanh),
            Dense(1 => 1, tanh),
            Dense(1 => 1, tanh),
        ),
        +
    ),
    Dense(1 => 1, identity),
)

@benchmark loop(resnet)