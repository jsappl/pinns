# This file was generated, do not modify it. # hide
using Plots
gr()

function euler(f, x0, xn, y0, n)
    h = (xn - x0)/n
  
    xs = zeros(n+1)
    ys = zeros(n+1)
  
    xs[1] = x0
    ys[1] = y0
  
    for i in 1:n
      xs[i + 1] = xs[i] + h
      ys[i + 1] = ys[i] + h * f(xs[i], ys[i])
    end
  
    return xs, ys
end

f(x, y) = 0.1*√y + 0.4*x^2

x_0 = -2
x_n = 2
y_0 = 0.5

h_1 = 1.0
h_2 = 0.5

n_1 = floor(Int, (x_n-x_0) / h_1)
n_2 = floor(Int, (x_n-x_0) / h_2)

# hide
xs, ys, us, vs = [], [], [], []  # hide
for x in -2:0.5:2, y in 0:0.5:5  # hide
    push!(xs, x), push!(ys, y)  # hide
    v = f(x, y)  # hide
    norm = 3*(1 + v^2)^(1/2)  # hide
# hide
    push!(us, 1 / norm), push!(vs, v / norm)  # hide
end  # hide
plt = plot()
quiver!(xs, ys, quiver=(us, vs))  # hide
# hide
xs, ys = euler(f, x_0, x_n, y_0, n_1)
plot!(xs, ys, label="h=1.0", marker=(:circle))

xs, ys = euler(f, x_0, x_n, y_0, n_2)
plot!(xs, ys, label="h=0.5", marker=(:rect))
Plots.savefig(joinpath(@OUTPUT, "eulers_method.png"))  # hide