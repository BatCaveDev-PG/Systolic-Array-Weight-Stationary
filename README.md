## Weight-Stationary Systolic Array for Matrix Multiplication

This repository contains the VHDL implementation and testbench for a systolic array architecture. The design targets efficient dense matrix-matrix multiplication by minimizing weight movement across processing elements (PEs). Developed as part of Sparse Packing Sysytolic Array research work focused on hardware dataflow optimization.

### Dependencies

    VHDL 2008: The modules are written in VHDL'08; use simulators that support this standard.

    Simulation Tools: ModelSim.

    Synthesis : Cadence Innovus.


### Project Structure

    /src/ – VHDL source files for PEs and systolic controller

    /tb/ – Testbench for validating matrix multiplication

    /docs/ – Optional diagrams, architecture notes

### References

The design approach follows established systolic array concepts with emphasis on local reuse and timing efficiency. Key inspiration includes:

    Kung, H. T. "Why Systolic Architectures?" (1982)

    Jouppi et al., "In-Datacenter Performance Analysis of a Tensor Processing Unit" (2017)