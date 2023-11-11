# This file was generated, do not modify it. # hide
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