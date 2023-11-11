# This file was generated, do not modify it. # hide
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