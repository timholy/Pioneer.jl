<img src="https://github.com/nwamsley1/Pioneer.jl/blob/main/figures/PIONEER_LOGO.jpg" align="right" width="150px"/>
<h1>Pioneer: Fast and Open-Source Analysis of Data-Indepdendent Aquisition Proteomics Experiments

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://nwamsley1.github.io/Pioneer.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://nwamsley1.github.io/Pioneer.jl/dev/)
[![Build Status](https://github.com/nwamsley1/Pioneer.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/nwamsley1/Pioneer.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/nwamsley1/Pioneer.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/nwamsley1/Pioneer.jl)
</h1>


##  Development Aims
  Pioneer is a cross-platform and open-source tool fully implemented 
in Juilia that identifies and quantifies proteins and peptides from data independent acquisition (DIA) experiments. Given a 
spectral library of fragment ion intensities and retention time estimates on an arbitrary scale, Pioneer employs a spectrum-centric 
algorithm and heuristics to statistically infer the identification status and abundance of each library precursor in the data. We develop Pioneer with the following goals:

- **Open-Source:** Methods should be understood and open to scrutiny by users
- **Cross-Platform:** All steps of analysis, including vendor file conversion, should run on all major operating systems
- **High-Performance:** The sensitivity, FDR control, and quantitative precision and accuracy should be competitive with state-of-the-art commercial software packages
- **Scalability:** Should scale to very large experiments with hundreds to thousands of raw files
- **Fast:** Use of simple heuristics and carefully implemented, efficient algorithms should ensure that data can be analyzed many times faster than it is aquired for typical experiments

## Instalation
1) Pioneer requires Julia 1.10. Download [julia](https://pages.github.com/) and add it to the PATH. 
2) Open an instance of the julia REPL
3) Type ";" to activate the shell from within the REPL. Then, navigate to the desired directory and clone the Pioneer.jl repository.
```
shell> git clone https://github.com/nwamsley1/Pioneer.jl.git
```
and not move into the package directory
```
shell> cd Pioneer.jl
```
4) Return to julia by hitting the backspace key. Activate the julia package manager by typing "]" into the REPL and enter the following:
```
(@v1.10) pkg> activate
(@v1.10) pkg> develop ./
(@v1.10) pkg> add ./
```

## Usage
Pioneer exports three the "SearchDIA" method, which takes a single argument, that is a file path to a .json parameters files (examples included). To access these methods
import the Pioneer package from within the Julia REPL. 
```
julia> using Pioneer
```

### File Conversion
`Pioneer` requires Thermo .raw files be converted to an Apache .arrow format with a specific column specification. Use [PioneerConverter](https://github.com/nwamsley1/PioneerConverter) to convert .raw files. 

### Parameters JSON
An Example prameters file is given below. Most default parameters should apply to a broad range of experiments; however, a few important parameters are singled out. 

##### Key parameters specification
- first_search_params - max_precursors_passing: Needs to be set to roughly 2-3x the number of precursors that are expected to be identified. For bulk proteome lysates on the Astral, 400K-500K are reasonable settings. For QExactive/Exploris instruments, 125K-250K are reasonable.
- first_search_params - n_frag_isotopes: for the first search, additional isotopes do not tend to increase identifications. 1 is the most reasonable choice
- quant_search_params - n_frag_isotopes: Adding the M1 and M2 fragment isotopes can improve quantitation at the cost of slower runtime. 2-3 are reasonable choices.
- summarize_first_search_params - max_precursors: A single list of the best 'n' precursors are assembled based on the first search of all raw files. Only these 'n' precursors are quantified and scored in the second search. This should be set to the same as `first_search_params - max_precursors_passing` (see above).
- summarize_first_search_params - min_inference_points: mimimum number of datapoints needed to estimate the fwhm. Could be set smaller than for an experiments where fewer ID's are expected, such as a IP-MS experiment.
  
##### Full parameters specification
```
{
    "isotope_err_bounds":[1, 0], 
    "choose_most_intense": false, //If multiple peaks match a single theoretical fragment choose either the most intense or nearest m/z
    "q_value": 0.01, //q-value threshold for the experiment 
    "presearch_params": //The presearch estimates library-to-empirical retention time mappings and left and right hand fragment mass tolerances 
    {
        "min_index_search_score": 22, //Minimum fragment index score for a precursor to pass the presearch
        "n_frag_isotopes": 1, //Number of fragment isotopes to consider (1 = M0, 2 = M0 + M1, etc. up to 5)
        "min_frag_count": 7, //Minimum number of matched fragments for a precursor to pass the presearch
        "min_log2_matched_ratio": 1.5, //Log2 of ratio of sum of matched fragment predicted intensities to sum of unmatched fragment predicted intensities  
        "min_spectral_contrast": 0.9, // u*v/(||u||*||v||). Cosine simmilarity of predicted spectrum to observation
        "min_topn_of_m": [3, 3], //At least m of the top n predicted fragments must match to the spectrum
        "max_best_rank": 1, // A fragment ranking 'n' or better in the predicted spectrum must match to the empirical spectrum
        "sample_rate": 0.02, //Sample this proportion of the total scans in the pre-search
        "frag_tol_ppm": 30.0, //Initial guess for fragment tolerance. ~30-40 ppm for low resolution orbitrap or Astral MS2 scans 
        "max_qval": 0.01, //Only estimate presearch parameters with precursors below this q-value score int eh presearch
        "min_samples": 3500, //Need at least this many examples to estimate parameters 
        "frag_err_quantile": 0.01, //Fragment tolerance is based on this quantile of fragment m/z errors
        "max_presearch_iters": 10 //
    },
    "first_search_params":
    {
        "min_index_search_score": 15, //Minimum fragment index score for a precursor to pass the presearch 
        "min_frag_count": 4, //Minimum number of matched fragments for a precursor to pass the presearch
        "min_topn_of_m": [2, 3],  //At least m of the top n predicted fragments must match to the spectrum
        "n_frag_isotopes": 2, //Number of fragment isotopes to consider (1 = M0, 2 = M0 + M1, etc. up to 5) 
        "min_log2_matched_ratio": 0.0, //Log2 of ratio of sum of matched fragment predicted intensities to sum of unmatched fragment predicted intensities
        "min_spectral_contrast": 0.5, // u*v/(||u||*||v||). Cosine simmilarity of predicted spectrum to observation
        "max_best_rank": 1,  //A fragment ranking 'n' or better in the predicted spectrum must match to the empirical spectrum
        "n_train_rounds_probit": 2, //Number of rounds of probit regression to score psms for each raw file 
        "max_iter_probit":20, //Number of multiplicative updates for each round of probit regression
        "max_q_value_probit_rescore": 0.01, //In subsequent rounds of probit rescoring, train only on all decoys + the subset of targets passing this q_value threshold in the prior iteration
        "max_precursors_passing": 500000 //Record only top 'n' scoring precursors for each raw file. Each precursor is represented by its best scoring psm. 
    },
    "summarize_first_search_params":
    {
        "max_precursors": 500000,
        "scan_count_range": [4, 10],
        "max_q_val_for_irt": 0.01,
        "max_prob_to_impute": 0.75,
        "min_inference_points": 1000,
        "fwhm_nstd":4,
        "irt_nstd": 4,
        "default_irt_width": 1.0,
        "peak_width_quantile": 0.95,
        "max_irt_bin_size": 0.1
    },
    "quant_search_params":
    {
        "WH_smoothing_strength": 1.0,
        "min_frag_count": 3,
        "min_y_count": 2,
        "min_log2_matched_ratio": -1.7,
        "min_spectral_contrast": 0.0,
        "min_topn_of_m": [2, 3],
        "n_frag_isotopes": 2,
        "max_best_rank": 3,
        "n_pad": 20,
        "max_apex_offset": 2
    },
    "irt_mapping_params": 
    {
        "n_bins": 200,
        "bandwidth": 0.25,
        "n_sigma_tol":4,
        "min_prob": 0.95
    },
    "deconvolution_params":         
    {
        "lambda": 0.0,
        "huber_delta": 0,
        "huber_delta0": 300,
        "huber_delta_exp": 1.5,
        "huber_delta_iters": 15,
        "max_iter_newton": 100,
        "max_iter_bisection": 100,
        "max_iter_outer": 100,
        "accuracy_newton": 10,
        "accuracy_bisection": 10,
        "max_diff": 0.01
    },
    "qc_plot_params":
    {
        "n_files_per_plot": 12
    },
    "normalization_params":
    {
        "n_rt_bins": 100,
        "spline_n_knots": 7
    },
    "xgboost_params":
    {
        "max_n_samples": 10000000,
        "min_best_trace_prob": 0.75,
        "precursor_prob_spline_points_per_bin": 500,
        "precursor_q_value_interpolation_points_per_bin": 10,
        "pg_prob_spline_points_per_bin": 500,
        "pg_q_value_interpolation_points_per_bin": 10

    },
    "quad_transmission":
    {
        "fit_from_data": false,
        "overhang": 0.25,
        "smoothness":5.0
    },
    "benchmark_params":
    {   
        "results_folder": "/Users/n.t.wamsley/Desktop/testresults"
    },
    "output_params":
    {
        "write_csv": true,
        "delete_temp": true
    },
    "library_folder": "/Users/n.t.wamsley/RIS_temp/ASMS_2024/ASTRAL_THREE_PROTEOME/unispec_chronologer_1mc_1var_by_052724/spec_lib/pioneer_lib.pion",
    "ms_data_dir":"/Users/n.t.wamsley/TEST_DATA/PXD046444/arrow/astral_test"
}
```

### SearchDIA

###### .pion Spectral Library
`SearchDIA` requires a properly formated spectral library. Spectral libraries are contained in folders with the `.pion` extension. The contents include the following. 
```
╭─n.t.wamsley@3225-AD-00020.local ~/RIS_temp/ASMS_2024/ASTRAL_THREE_PROTEOME/unispec_chronologer_1mc_1var_by_052724/spec_lib/pioneer_lib.pion  
╰─➤  ls
config.json                           f_index_rt_bins.arrow                 presearch_f_index_fragments.arrow
detailed_fragments.jld2               precursor_table.arrow                 presearch_f_index_rt_bins.arrow
f_index_fragment_bins.arrow           precursor_to_fragment_indices.jld2    simple_fragments.arrow
f_index_fragments.arrow               presearch_f_index_fragment_bins.arrow
```
- detailed_fragments.jld2
```
julia> spec_lib["f_det"].frags[1:5]
5-element Vector{DetailedFrag{Float32}}:
DetailedFrag{Float32}(0x00000001, 329.6432f0, Float16(1.0), 0x02, false, 0x02, 0x06, 0x02, 0x01, 0x00)
DetailedFrag{Float32}(0x00000001, 543.2522f0, Float16(0.976), 0x02, false, 0x01, 0x05, 0x02, 0x02, 0x00)
DetailedFrag{Float32}(0x00000001, 358.1539f0, Float16(0.809), 0x02, false, 0x02, 0x07, 0x02, 0x03, 0x00)
DetailedFrag{Float32}(0x00000001, 658.2791f0, Float16(0.4597), 0x02, false, 0x01, 0x06, 0x02, 0x04, 0x00)
DetailedFrag{Float32}(0x00000001, 456.2201f0, Float16(0.4324), 0x02, false, 0x01, 0x04, 0x02, 0x05, 0x00)

julia> spec_lib["f_det"].prec_frag_ranges[1:5]
5-element Vector{UnitRange{UInt32}}:
0x00000001:0x00000013
0x00000014:0x00000027
0x00000028:0x00000039
0x0000003a:0x0000004d
0x0000004e:0x0000005c
```
- f_index_fragment_bins.arrow
```
Julia> spec_lib["f_index"].fragment_bins
1187912-element Arrow.Struct{FragIndexBin, Tuple{Arrow.Primitive{Float32, Vector{Float32}}, Arrow.Primitive{Float32, Vector{Float32}}, Arrow.Primitive{UInt32, Vector{UInt32}}, Arrow.Primitive{UInt32, Vector{UInt32}}}, (:lb, :ub, :first_bin, :last_bin)}:
FragIndexBin{Float32}(172.0717f0, 172.0717f0, 0x00000001, 0x00000017)
FragIndexBin{Float32}(173.5953f0, 173.5953f0, 0x00000018, 0x00000018)
FragIndexBin{Float32}(179.6079f0, 179.6079f0, 0x00000019, 0x00000019)
FragIndexBin{Float32}(181.0713f0, 181.0713f0, 0x0000001a, 0x0000001a)
```
- f_index_fragments.arrow
```
julia> spec_lib["f_index"].fragments
62231372-element Arrow.Struct{IndexFragment, Tuple{Arrow.Primitive{UInt32, Vector{UInt32}}, Arrow.Primitive{Float32, Vector{Float32}}, Arrow.Primitive{UInt8, Vector{UInt8}}, Arrow.Primitive{UInt8, Vector{UInt8}}}, (:prec_id, :prec_mz, :score, :charge)}:
IndexFragment{Float32}(0x00007028, 379.6988f0, 0x02, 0x02)
IndexFragment{Float32}(0x000009f8, 380.6941f0, 0x01, 0x02)
IndexFragment{Float32}(0x00000a69, 381.6818f0, 0x01, 0x02)
IndexFragment{Float32}(0x00000b20, 383.6736f0, 0x01, 0x02)
```
- f_index_rt_bins.arrow
These make up the fragment index for the initial search. 
```
julia> spec_lib["f_index"].rt_bins
20-element Arrow.Struct{FragIndexBin, Tuple{Arrow.Primitive{Float32, Vector{Float32}}, Arrow.Primitive{Float32, Vector{Float32}}, Arrow.Primitive{UInt32, Vector{UInt32}}, Arrow.Primitive{UInt32, Vector{UInt32}}}, (:lb, :ub, :first_bin, :last_bin)}:
FragIndexBin{Float32}(-1.3982847f0, 0.60170865f0, 0x00000001, 0x00006f72)
FragIndexBin{Float32}(0.6017635f0, 2.6017632f0, 0x00006f73, 0x000162e7)
FragIndexBin{Float32}(2.6017723f0, 4.6017694f0, 0x000162e8, 0x00027f1d)
FragIndexBin{Float32}(4.6017733f0, 6.601769f0, 0x00027f1e, 0x0003b678)
```
- precursors_table.arrow
A table with one row per precursor in the library. Each precursor has a unique id that corresponds to a row in this table. 
```
julia> precursors
Arrow.Table with 8893001 rows, 12 columns, and schema:
:irt                   Float32
:mz                    Float32
:is_decoy              Bool
:proteome_identifiers  String
:accession_numbers     String
:sequence              String
:structural_mods       String
:isotopic_mods         String
:prec_charge           UInt8
:missed_cleavages      UInt8
:length                UInt8
:sulfur_count          UInt8
```
- precursor_to_fragment_indices.jld2
- presearch_f_index_fragment_bins.arrow
- presearch_f_index_fragments.arrow
- presearch_f_index_rt_bins.arrow
- simple_fragments.arrow

## Status
- We are excited to present preiminary results at ASMS 2024 in Anaheim, California! See a copy of the poster below.
- Pioneer is in an early stage of development and not yet ready for use in research. If curious, please contact us at n.t.wamsley@wustl.edu.
- Updates will be continuously added to github as the project progresses.
- Cross-platform conversion of Thermo RAW files to Pioneer compatible Apache Arrow tables. https://github.com/nwamsley1/ThermoRawFileToParquetConverter
  
<h1>Goldfarb Lab </h1>
 Pioneer is developed in the Goldfarb Lab: https://goldfarblab.wustl.edu   <img src="https://github.com/nwamsley1/Pioneer.jl/blob/main/figures/goldfarb.png" align="left" width="125px"/> 
<br><br><br><br><br>

## ASMS 2024
<img src="https://github.com/nwamsley1/Pioneer.jl/blob/main/figures/asms_2024_image.jpg"/>

## US HUPO 2024
<img src="https://github.com/nwamsley1/Pioneer.jl/blob/main/figures/HUPO_POSTER_2024_FORFEDEX.jpg"/>
