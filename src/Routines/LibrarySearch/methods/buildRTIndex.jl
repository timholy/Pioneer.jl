struct rtIndexBin{T,U<:AbstractFloat}
    lb::T
    ub::T
    prec::Vector{Tuple{UInt32, U}}
end
getLow(r::rtIndexBin) = r.lb
getHigh(r::rtIndexBin) = r.ub
function compare_lb(rb::rtIndexBin{T,U}) where {T,U<:AbstractFloat}
    return rb.lb
end
getLB(rb::rtIndexBin{T,U}) where {T,U<:AbstractFloat} = rb.lb
getMZ(rb::rtIndexBin{T, U}) where {T,U<:AbstractFloat} = last(rb.prec)
getPrecID(rb::rtIndexBin{T, U}) where {T,U<:AbstractFloat} = first(rb.prec)

struct retentionTimeIndex{T,U<:AbstractFloat}
    rt_bins::Vector{rtIndexBin{T, U}}
end
getRTBins(rti::retentionTimeIndex) = rti.rt_bins
getRTBin(rti::retentionTimeIndex, rt_bin::Int) = rti.rt_bins[rt_bin]
function retentionTimeIndex(T::DataType, U::DataType) 
    return retentionTimeIndex(Vector{rtIndexBin{T, U}}())
end

function buildRTIndex(RTs::Vector{T}, prec_mzs::Vector{U}, prec_ids::Vector{I}, bin_rt_size::AbstractFloat) where {T,U<:AbstractFloat,I<:Integer}
    
    start_idx = 1
    start_RT =  RTs[start_idx]
    rt_index = retentionTimeIndex(T, U) #Initialize retention time index
    i = 1
    while i < length(RTs) + 1
        if ((RTs[min(i + 1, length(RTs))] - start_RT) > bin_rt_size) | (i == length(RTs))
            push!(rt_index.rt_bins, 
                    rtIndexBin(RTs[start_idx], #Retention time for first precursor in the bin
                          RTs[i],     #Retention time for last precursor in the bin
                        [(zero(UInt32), zero(Float32)) for _ in 1:(i - start_idx + 1)] #Pre-allocate precursors 
                        )
                )

            n = 1 #n'th precursor 
            for idx in start_idx:(min(i, length(RTs))) 
                rt_index.rt_bins[end].prec[n] = (prec_ids[idx], prec_mzs[idx]) #Add n'th precursor
                n += 1
            end

            sort!(rt_index.rt_bins[end].prec, by = x->last(x)) #Sort precursors by m/z
            i += 1
            start_idx = i
            start_RT = RTs[min(start_idx, length(RTs))]
            continue
        else
            i += 1
        end
    end


    function sortRTBins!(rt_index::retentionTimeIndex{T, U})
        for i in 1:length(rt_index.rt_bins)
            sort!(rt_index.rt_bins[i].prec, by = x->last(x));
        end
        return nothing
    end
    sortRTBins!(rt_index)
    return rt_index
end

buildRTIndex(PSMs::DataFrame; bin_rt_size::AbstractFloat = 0.1) = buildRTIndex(PSMs[:,:irt], PSMs[:,:prec_mz], PSMs[:,:precursor_idx], bin_rt_size)

buildRTIndex(PSMs::SubDataFrame; bin_rt_size::AbstractFloat = 0.1) = buildRTIndex(PSMs[:,:irt], PSMs[:,:prec_mz], PSMs[:,:precursor_idx], bin_rt_size)


function makeRTIndices(temp_folder::String,
                       psms_paths::Dictionary{String, String}, 
                       prec_to_irt::Dictionary{UInt32, @NamedTuple{irt::Float32, mz::Float32}},
                       rt_to_irt_splines::Any;
                       min_prob::AbstractFloat = 0.5)

    #Maps filepath to a retentionTimeIndex (see buildRTIndex.jl)
    rt_index_paths = Dictionary{String, String}()
    #Fill retention time index for each file. 
    for (key, psms_path) in pairs(psms_paths)
        psms = Arrow.Table(psms_path)
        rt_to_irt = rt_to_irt_splines[key]
        #Impute empirical iRT value for psms with probability lower than the threshold
        irts = zeros(Float32, length(prec_to_irt))
        mzs = zeros(Float32, length(prec_to_irt))
        prec_ids = zeros(UInt32, length(prec_to_irt))
        #map observec precursors to irt and probability score
        prec_set = Dict(zip(
            psms[:precursor_idx],
            map(x->(irt=first(x),prob=last(x)), zip(rt_to_irt.(psms[:RT]), psms[:prob]))
        ))

        Threads.@threads for (i, (prec_id, irt_mz)) in collect(enumerate(pairs(prec_to_irt)))
            prec_ids[i] = prec_id
            irt, mz = irt_mz::@NamedTuple{irt::Float32, mz::Float32}
            #Don't impute irt, use empirical
            if haskey(prec_set, prec_id)
                _irt_, prob = prec_set[prec_id]
                if (prob >= min_prob)
                    irts[i], mzs[i]  = _irt_, mz
                    continue
                end
            end
            #Impute irt from the best observed psm for the precursor accross the experiment 
            irts[i], mzs[i] = irt,mz
        end
        #Build RT index 
        rt_df = DataFrame(Dict(:irt => irts,
                                :prec_mz => mzs,
                                :precursor_idx => prec_ids))
        sort!(rt_df, :irt)
        temp_path =joinpath(temp_folder, key*"rt_indices.arrow")
        Arrow.write(
            temp_path,
            rt_df,
            )
        insert!(
            rt_index_paths,
            key,
            temp_path
        )
    end
    return rt_index_paths
end
