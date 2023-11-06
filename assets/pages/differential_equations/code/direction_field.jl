# This file was generated, do not modify it. # hide
using Plots
gr()

xs, ys, us, vs = [], [], [], []
f(x, y) = 0.2*x*y

space = -5:1.0:5

for x in space, y in space
    push!(xs, x), push!(ys, y)

    v = f(x, y)
    norm = (1 + v^2)^(1/2)

    push!(us, 1 / norm), push!(vs, v / norm)
end

quiver(xs, ys, quiver=(us, vs))

Plots.savefig(joinpath(@OUTPUT, "direction_field.png"))  # hide