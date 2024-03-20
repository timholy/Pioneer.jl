function findFirstFragmentBin(frag_index_bins::Arrow.Struct{FragIndexBin, Tuple{Arrow.Primitive{Float32, Vector{Float32}}, Arrow.Primitive{Float32, Vector{Float32}}, Arrow.Primitive{UInt32, Vector{UInt32}}, Arrow.Primitive{UInt32, Vector{UInt32}}}, (:lb, :ub, :first_bin, :last_bin)}, 
                                frag_bin_range::UnitRange{UInt32},
                                frag_min::Float32, 
                                frag_max::Float32) #where {T<:AbstractFloat}
    #Binary Search
    lo, hi = first(frag_bin_range), last(frag_bin_range)
    potential_match = nothing
    #mid = max((lo + hi) ÷ 8, lo + 1) #Should be closer to the begining of the range
    @inbounds @fastmath while lo <= hi

        mid = (lo + hi) ÷ 2

        if (frag_min) <= getHigh(frag_index_bins[mid])
            if (frag_max) >= getHigh(frag_index_bins[mid]) #Frag tolerance overlaps the upper boundary of the frag bin
                potential_match = UInt32(mid)
            end
            hi = mid - 1
        elseif (frag_max) >= getLow(frag_index_bins[mid]) #Frag tolerance overlaps the lower boundary of the frag bin
            if (frag_min) <= getLow(frag_index_bins[mid])
                potential_match = UInt32(mid)
            end
            lo = mid + 1
        end

    end

    return potential_match
end

function searchPrecursorBin!(prec_id_to_score::Counter{UInt32, UInt8}, 
                            fragments::Arrow.Struct{IndexFragment, Tuple{Arrow.Primitive{UInt32, Vector{UInt32}}, Arrow.Primitive{Float32, Vector{Float32}}, Arrow.Primitive{UInt8, Vector{UInt8}}, Arrow.Primitive{UInt8, Vector{UInt8}}}, (:prec_id, :prec_mz, :score, :charge)},
                            frag_id_range::UnitRange{UInt32},
                            window_min::Float32, 
                            window_max::Float32)

    
        #N = getLength(precursor_bin)
        N =  last(frag_id_range)
        #lo, hi = 1, N
        lo, hi = first(frag_id_range), N
        @inbounds @fastmath begin 
            while lo <= hi
                mid = (lo + hi) ÷ 2
                if getPrecMZ(fragments[mid]) < window_min
                    lo = mid + 1
                else
                    hi = mid - 1
                end
            end

            window_start = (lo <= N ? lo : return)


            if getPrecMZ(fragments[window_start]) > window_max
                return 
            end
            
            lo, hi = window_start, N

            while lo <= hi
                mid = (lo + hi) ÷ 2
                if getPrecMZ(fragments[mid]) > window_max
                    hi = mid - 1
                else
                    lo = mid + 1
                end
            end

            window_stop = hi
        end
        #=
        window_stop = window_start
        @inbounds @fastmath while getPrecMZ(fragments[window_stop]) < window_max
            window_stop += 1
        end
        window_stop = max(window_stop - 1, window_start)
        =#
    function addFragmentMatches!(prec_id_to_score::Counter{UInt32, UInt8}, 
                                    fragments::Arrow.Struct{IndexFragment, Tuple{Arrow.Primitive{UInt32, Vector{UInt32}}, Arrow.Primitive{Float32, Vector{Float32}}, Arrow.Primitive{UInt8, Vector{UInt8}}, Arrow.Primitive{UInt8, Vector{UInt8}}}, (:prec_id, :prec_mz, :score, :charge)}, 
                                    matched_frag_range::UnitRange{UInt32})# where {T,U<:AbstractFloat}
        @inline @inbounds for i in matched_frag_range
            frag = fragments[i]
            inc!(prec_id_to_score, getPrecID(frag), getScore(frag))
        end
    end
    
    #Slower, but for clarity, could have used searchsortedfirst and searchsortedlast to get the same result.
    #Could be used for testing purposes. 
    addFragmentMatches!(prec_id_to_score, fragments, UInt32(window_start):UInt32(window_stop))

    return 

end

function queryFragment!(prec_id_to_score::Counter{UInt32, UInt8}, 
                        frag_bin_range::UnitRange{UInt32},
                        frag_index::FragmentIndex{Float32}, 
                        frag_min::Float32, frag_max::Float32, 
                        prec_bounds::Tuple{Float32, Float32})# where {T,U<:AbstractFloat}
    
    #First frag_bin matching fragment tolerance
    frag_bin_idx = findFirstFragmentBin(getFragBins(frag_index), 
                                    frag_bin_range, #Range of Fragment Bins to Search
                                    frag_min, frag_max)

    #No fragment bins contain the fragment m/z
    #println("no frags")
    if (frag_bin_idx === nothing)
        return first(frag_bin_range)
    end
    #println("some frags $frag_bin_idx")
    #Search subsequent frag bins until no more bins or untill a bin is outside the fragment tolerance
    while (frag_bin_idx <= last(frag_bin_range))
        #Fragment bin is outside the fragment tolerance
        frag_bin = getFragmentBin(frag_index, frag_bin_idx)
        if (getLow(frag_bin) > frag_max)
            #println("last frag bin $frag_bin_idx")
            return UInt32(frag_bin_idx)
        else
            frag_id_range = getSubBinRange(frag_bin)
            #Search the fragment range for fragments with precursors in the precursor tolerance
            searchPrecursorBin!(prec_id_to_score, 
                                getFragments(frag_index),
                                frag_id_range, 
                                first(prec_bounds), 
                                last(prec_bounds)
                            )
            #println("searched precursor bin")
            frag_bin_idx += 1
        end
    end
    #Only reach this point if frag_bin exceeds length(frag_index)
    return UInt32(frag_bin_idx - 1)
end

function searchScan!(prec_id_to_score::Counter{UInt32, UInt8}, 
                    frag_index::FragmentIndex{Float32}, 
                    masses::AbstractArray{Union{Missing, U}}, intensities::AbstractArray{Union{Missing, U}}, 
                    rt_bin_idx::Int64,
                    irt_high::Float32, 
                    ppm_err::Float32, 
                    mass_err_model::MassErrorModel{Float32},
                    min_max_ppm::Tuple{Float32, Float32},
                    prec_mz::Float32, 
                    prec_tol::Float32, 
                    isotope_err_bounds::Tuple{Int64, Int64}; 
                    min_score::UInt8 = zero(UInt8)) where {U<:AbstractFloat}
    
    function getFragTol(mass::Float32, 
                        ppm_err::Float32, 
                        intensity::Float32, 
                        mass_err_model::MassErrorModel{Float32},
                        min_max_ppm::Tuple{Float32, Float32})
        mass -= Float32(ppm_err*mass/1e6)
        ppm = mass_err_model(intensity)
        ppm = max(
                    min(ppm, last(min_max_ppm)), 
                    first(min_max_ppm)
                    )
        tol = ppm*mass/1e6
        return Float32(mass - tol), Float32(mass + tol), Float32(mass - last(min_max_ppm)*mass/1e6)
    end

    function filterPrecursorMatches!(prec_id_to_score::Counter{UInt32, UInt8}, min_score::UInt8)
        match_count = countFragMatches(prec_id_to_score, min_score)
        prec_count = getSize(prec_id_to_score) - 1
        sortCounter!(prec_id_to_score);
        return match_count, prec_count
    end

    prec_min = Float32(prec_mz - prec_tol - NEUTRON*first(isotope_err_bounds)/2)
    prec_max = Float32(prec_mz + prec_tol + NEUTRON*last(isotope_err_bounds)/2)

    while getLow(getRTBin(frag_index, rt_bin_idx)) < irt_high
        #println("rt_bin_idx $rt_bin_idx irt_high $irt_high getRTBin(frag_index, rt_bin_idx) ", getRTBin(frag_index, rt_bin_idx))
        sub_bin_range = getSubBinRange(getRTBin(frag_index, rt_bin_idx))
        min_frag_bin, max_frag_bin = first(sub_bin_range), last(sub_bin_range)
        old_min_frag_bin = min_frag_bin
        for (mass, intensity) in zip(masses, intensities)
            mass, intensity = coalesce(mass, zero(U)),  coalesce(intensity, zero(U))
            #Get intensity dependent fragment tolerance
            frag_min, frag_max, MIN_ALL_FRAGS = getFragTol(mass, ppm_err, intensity, mass_err_model, min_max_ppm)
            #Don't avance the minimum frag bin if it is still possible to encounter a smaller matching fragment 
            if getHigh(getFragmentBin(frag_index, (min_frag_bin))) >= MIN_ALL_FRAGS
                min_frag_bin = old_min_frag_bin
            end
            #println("frag_min $frag_min, frag_max $frag_max, MIN_ALL_FRAGS $MIN_ALL_FRAGS")
            old_min_frag_bin = min_frag_bin

            min_frag_bin = queryFragment!(prec_id_to_score, 
                                            min_frag_bin:max_frag_bin, 
                                            frag_index, 
                                            frag_min, frag_max, 
                                            (prec_min, prec_max)
                                        )
          

            #println("min_frag_bin post $min_frag_bin")
        end
        rt_bin_idx += 1
        #Cannot exceed number of rt bins 
        if rt_bin_idx >length(getRTBins(frag_index))
            rt_bin_idx = length(getRTBins(frag_index))
            break
        end 
    end
    #return 0
    return filterPrecursorMatches!(prec_id_to_score, min_score)
end

