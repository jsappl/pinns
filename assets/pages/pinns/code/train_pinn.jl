# This file was generated, do not modify it. # hide
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