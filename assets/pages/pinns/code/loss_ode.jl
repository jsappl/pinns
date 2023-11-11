# This file was generated, do not modify it. # hide
random_positions = [2*rand() - 1 for i in 1:100]
loss_ode() = sum(abs2, NNForce(x) - (-k*x) for x in random_positions)