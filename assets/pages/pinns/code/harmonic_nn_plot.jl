# This file was generated, do not modify it. # hide
force_plot = [force(state[1],state[2],k,t) for state in data_plot]
learned_force_plot = NNForce.(positions_plot)

traces = [
    scatter(x=plot_t, y=force_plot, name="true force"),
    scatter(x=plot_t, y=learned_force_plot, name="predicted force"),
    scatter(x=t, y=force_data, name="samples", mode="markers"),
]

plt = plot(traces)
fdplotly(json(plt))  # hide