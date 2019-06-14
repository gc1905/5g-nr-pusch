# 5G New Radio PUSCH Software Transceiver Model

The following repository incorporates a prototype MATLAB implementation of the transmitter and receiver chains of the 5G NR Physical Uplink Shared Channel (PUSCH) defined by 3GPP rel 15, specification documents TS 38.211-214.

Note that not all the configurations specified by the standard are supported. Implementation has the following limitations:
* MIMO configurations with up to 2 transmission layers or 2 receive antennas supported,
* DMRS subcarriers for different PUSCH antenna ports must be conveyed over different CDM groups,
* PTRS not supported,
* Transform precoding not supported,
* LBRM Rate Matching not supported.

If you find the content of this repository useful in your scientific research, please consider including the following reference in your references:

> G. Cisek and T. Zielinski, "Prototyping Software Transceiver for the 5G New Radio Physical Uplink Shared Channel," in *Signal Processing Symposium (SPSympo)*, Cracow, Poland, September 2019.

## Running the simulations

The fastest way to run the simulations is using a batch file *run_5g_nr_sim_sweep.m*. The user can edit the file manually and modify the simulation parameters accordingly. The link level simulation of PUSCH transmission with the main processing chain loop is implemented using *nr_sch_link_level_sim.m*. See the manual of the function for details.

The 38.212 LDPC codec simulation without baseband processing part can be run with *run_5gnr_codec.m* batch file. 

## MEX acceleration

Simulation time can be significantly reduced through acceleration with mex functions. In order to compile the mex function under MATLAB, execute the following commands from MATLAB command prompt with directory set to the repository's clone root:

```
cd mex
make_mex
```

Compilation of the mex functions is not mandatory to run the simulation, but the execution time grows drastically without the acceleration.