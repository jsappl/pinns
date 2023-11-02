+++
title = "Software"
hascode = false
+++

# Software

In both, Python and Julia, multiple options for implementing physics-informed neural networks are available. The choice depends on the specific requirements you have and how familiar you are with the programming language and libraries. Python is more mature and widely used, while Julia offers high-performance computing and convenient mathematical notation for scientific computing. Click on the links below to learn more about each of the following libraries.

## Python :snake:

1. **[DeepXDE](https://deepxde.readthedocs.io/en/latest/?badge=latest)**:
   A library for scientific machine learning and physics-informed learning.

1. **[IDRLnet](https://idrlnet.readthedocs.io/en/latest/)**:
   A machine learning library on top of PyTorch. Use IDRLnet if you need a machine learning library that solves both forward and inverse differential equations via physics-informed neural networks. IDRLnet is a flexible framework inspired by Nvidia Simnet.

1. **[maziarraissi/PINNs](https://github.com/maziarraissi/PINNs)**:
    The original implementation by the authors of the papers written in TensorFlow.

1. **[SciANN](https://www.sciann.com/)**:
   A high-level artificial neural networks API, written in Python using Keras and TensorFlow backends. It is developed with a focus on enabling fast experimentation with different networks architectures and with emphasis on scientific computations, physics-informed deep learning, and inversion.

## Julia

1. **[DiffEqFlux.jl](https://docs.sciml.ai/DiffEqFlux/stable/)**:
   An implicit deep learning library built using the SciML ecosystem. It is a high-level interface that pulls together all the tools with heuristics and helper functions to make training such deep implicit layer models fast and easy. It can be used to solve problems in physics-informed machine learning.

1. **[NeuralPDE.jl](https://docs.sciml.ai/NeuralPDE/stable/)**:
   NeuralPDE is a Julia package for solving PDEs using neural networks. While it's not exclusively tailored to PINNs, it can be used effectively for physics-informed problems.
