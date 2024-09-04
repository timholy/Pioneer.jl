#
#=
Have N of these tables. Need to combine into one sorted Arrow table without loading all tables
into memory at once. 
julia> DataFrame(Arrow.Table(readdir(second_quant_folder, join = true)[1]))
280488×11 DataFrame
    Row │ precursor_idx  prob      weight         target  irt_obs    missed_cleavage  isotopes_captured  scan_idx  ms_file_idx  peak_area   new_best_scan 
        │ UInt32         Float32   Float32        Bool    Float32    UInt8            Tuple{Int8, Int8}  UInt32    Int64        Float32     UInt32        
────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
      1 │       1468734  0.808784    201.467        true   0.659221                1  (0, 3)                49270            1     6.03541          50180
      2 │        262434  0.989585   2696.17         true   0.659221                0  (0, 3)                76753            1   121.201            76753
=#

getColNames(at::Arrow.Table) = keys(at)
getColTypes(at::Arrow.Table) = [eltype(at[col]) for col in getColNames(at)]
function getEmptyDF(at::Arrow.Table, N::Int)
    df = DataFrame()
    [df[!,Symbol(col)] = Vector{coltype}(undef, N) for (col, coltype) in zip(getColNames(at), getColTypes(at))]
    return df
end
    
function addPrecursorToHeap!(
    precursor_heap::BinaryMinHeap{Tuple{UInt32, UInt32, Int64}},
    first_sort_key::AbstractVector{UInt32},
    second_sort_key::AbstractVector{UInt32},
    table_idx::Int64,
    row_idx::Int64)
    push!(
        precursor_heap,
        (
        first_sort_key[row_idx],
        second_sort_key[row_idx],
        table_idx
        )
    )
end

function mergeSortedArrowTables(
    input_dir::String, 
    output_path::String,
    sort_keys::Tuple{Symbol, Symbol};
    N = 1000000)

    function fillColumn!(
        peptide_batch_col::Vector{R},
        col::Symbol,
        sorted_tuples::Vector{Tuple{Int64, Int64}},
        tables::Vector{Arrow.Table},
        n
    ) where {R<:Real}
        for i in range(1, max(min(length(peptide_batch_col), n - 1), 1))
            table_idx, idx = sorted_tuples[i]
            peptide_batch_col[i] = tables[table_idx][col][idx]::R
        end
    end

    function fillColumn!(
        peptide_batch_col::Vector{Union{Missing, R}},
        col::Symbol,
        sorted_tuples::Vector{Tuple{Int64, Int64}},
        tables::Vector{Arrow.Table},
        n
    ) where {R<:Real}
        for i in range(1, max(min(length(peptide_batch_col), n - 1), 1))
            table_idx, idx = sorted_tuples[i]
            peptide_batch_col[i] = tables[table_idx][col][idx]::Union{Missing, R}
        end
    end

    function fillColumn!(
        peptide_batch_col::Vector{String},
        col::Symbol,
        sorted_tuples::Vector{Tuple{Int64, Int64}},
        tables::Vector{Arrow.Table},
        n
    ) where {R<:Real}
        for i in range(1, max(min(length(peptide_batch_col), n - 1), 1))
            table_idx, idx = sorted_tuples[i]
            peptide_batch_col[i] = tables[table_idx][col][idx]::String
        end
    end


    function fillColumn!(
        peptide_batch_col::Vector{Union{Missing, String}},
        col::Symbol,
        sorted_tuples::Vector{Tuple{Int64, Int64}},
        tables::Vector{Arrow.Table},
        n
    )
        for i in range(1, max(min(length(peptide_batch_col), n - 1), 1))
            table_idx, idx = sorted_tuples[i]
            peptide_batch_col[i] = tables[table_idx][col][idx]::String
        end
    end


    function fillColumn!(
        peptide_batch_col::Vector{Tuple{R, R}},
        col::Symbol,
        sorted_tuples::Vector{Tuple{Int64, Int64}},
        tables::Vector{Arrow.Table},
        n
    ) where {R<:Real}
        for i in range(1, max(min(length(peptide_batch_col), n - 1), 1))
            table_idx, idx = sorted_tuples[i]
            peptide_batch_col[i] = tables[table_idx][col][idx]::Tuple{R, R}
        end
    end

    #Get all .arrow files in the input 
    input_paths = [path for path in readdir(input_dir, join=true) if endswith(path, ".arrow")]
    #Keep track of which tables have 
    tables = [Arrow.Table(path) for path in input_paths]
    table_idxs = ones(Int64, length(tables))

    peptide_batch = getEmptyDF(first(tables), N)
    sorted_tuples = Vector{Tuple{Int64, Int64}}(undef, N)
    peptide_batch_names = Symbol.(names(peptide_batch))
    precursor_heap = BinaryMinHeap{Tuple{UInt32, UInt32, Int64}}()
    for (i, table) in enumerate(tables)
        addPrecursorToHeap!(
            precursor_heap,
            table[first(sort_keys)],
            table[last(sort_keys)],
            i,
            1
        )
    end
    i = 1
    while length(precursor_heap) > 0
        _, _, table_idx = pop!( precursor_heap)
        table = tables[table_idx]
        idx = table_idxs[table_idx]
        sorted_tuples[i] = (table_idx, idx)
        table_idxs[table_idx] += 1
        idx = table_idxs[table_idx]
        if (idx > length(table[1]))
            continue
        end
        addPrecursorToHeap!(
            precursor_heap,
            table[first(sort_keys)],
            table[last(sort_keys)],
            table_idx,
            idx
        )
        i += 1
        if i > N
            for col in peptide_batch_names
                fillColumn!(
                    peptide_batch[!,col],
                    col,
                    sorted_tuples,
                    tables,
                    i
                )
            end
            Arrow.append(
                output_path,
                peptide_batch
            )
            i = 1
        end
    end
    for col in peptide_batch_names
        fillColumn!(
            peptide_batch[!,col],
            col,
            sorted_tuples,
            tables,
            i
        )
    end
    Arrow.append(
        output_path,
        peptide_batch[range(1, max(1, i - 1)),:]
    )
    return nothing
end

function addPrecursorToHeap!(
    precursor_heap::BinaryMinHeap{Tuple{Float32, Int64}},
    first_sort_key::AbstractVector{Float32},
    table_idx::Int64,
    row_idx::Int64)
    push!(
        precursor_heap,
        (
        first_sort_key[row_idx],
        table_idx
        )
    )
end

function addPrecursorToHeap!(
    precursor_heap::BinaryMinHeap{Tuple{Float32, Int64}},
    first_sort_key::AbstractVector{Union{Missing, Float32}},
    table_idx::Int64,
    row_idx::Int64)
    push!(
        precursor_heap,
        (
        coalesce(first_sort_key[row_idx], 0.0f0),
        table_idx
        )
    )
end

function sortAndFilterQuantTables(
    quant_psms_folder::String,
    merged_quant_path::String,
    best_traces::Set{@NamedTuple{precursor_idx::UInt32, isotopes_captured::Tuple{Int8, Int8}}})

    #Remove if present 
    if isfile(merged_quant_path)
        rm(merged_quant_path, force = true)
    end
    file_paths = [fpath for fpath in readdir(quant_psms_folder,join=true) if endswith(fpath,".arrow")]
    #Sort and filter each psm table 
    for fpath in file_paths
        psms_table = DataFrame(Tables.columntable(Arrow.Table(fpath)))

        #Indicator variable of whether each psm is from the best trace 
        psms_table[!,:best_trace] = zeros(Bool, size(psms_table, 1))
        for i in range(1, size(psms_table, 1))
            key = (precursor_idx = psms_table[i, :precursor_idx], isotopes_captured = psms_table[i, :isotopes_captured])
            if key ∈ best_traces
                psms_table[i,:best_trace]=true
            end
        end
        #Filter out unused traces 
        filter!(x->x.best_trace,psms_table)
        #Sort in descending order of probability
        sort!(psms_table, :prob, rev = true, alg=QuickSort)
        #write back
        Arrow.write(fpath, 
                    psms_table
                    )
    end
    return nothing
end

function mergeSortedArrowTables(
    input_dir::String, 
    output_path::String,
    sort_key::Symbol;
    N = 1000000)

    function fillColumn!(
        peptide_batch_col::Vector{R},
        col::Symbol,
        sorted_tuples::Vector{Tuple{Int64, Int64}},
        tables::Vector{Arrow.Table},
        n
    ) where {R<:Real}
        for i in range(1, max(min(length(peptide_batch_col), n - 1), 1))
            table_idx, idx = sorted_tuples[i]
            peptide_batch_col[i] = tables[table_idx][col][idx]::R
        end
    end

    function fillColumn!(
        peptide_batch_col::Vector{Union{Missing, R}},
        col::Symbol,
        sorted_tuples::Vector{Tuple{Int64, Int64}},
        tables::Vector{Arrow.Table},
        n
    ) where {R<:Real}
        for i in range(1, max(min(length(peptide_batch_col), n - 1), 1))
            table_idx, idx = sorted_tuples[i]
            peptide_batch_col[i] = tables[table_idx][col][idx]::Union{Missing, R}
        end
    end

    function fillColumn!(
        peptide_batch_col::Vector{String},
        col::Symbol,
        sorted_tuples::Vector{Tuple{Int64, Int64}},
        tables::Vector{Arrow.Table},
        n
    )
        for i in range(1, max(min(length(peptide_batch_col), n - 1), 1))
            table_idx, idx = sorted_tuples[i]
            peptide_batch_col[i] = tables[table_idx][col][idx]::String
        end
    end


    function fillColumn!(
        peptide_batch_col::Vector{Union{Missing, String}},
        col::Symbol,
        sorted_tuples::Vector{Tuple{Int64, Int64}},
        tables::Vector{Arrow.Table},
        n
    )
        for i in range(1, max(min(length(peptide_batch_col), n - 1), 1))
            table_idx, idx = sorted_tuples[i]
            peptide_batch_col[i] = tables[table_idx][col][idx]::String
        end
    end


    function fillColumn!(
        peptide_batch_col::Vector{Tuple{R, R}},
        col::Symbol,
        sorted_tuples::Vector{Tuple{Int64, Int64}},
        tables::Vector{Arrow.Table},
        n) where {R<:Real}
        for i in range(1, max(min(length(peptide_batch_col), n - 1), 1))
            table_idx, idx = sorted_tuples[i]
            peptide_batch_col[i] = tables[table_idx][col][idx]::Tuple{R, R}
        end
    end

    #Get all .arrow files in the input 
    input_paths = [path for path in readdir(input_dir, join=true) if endswith(path, ".arrow")]
    #Keep track of which tables have 
    tables = [Arrow.Table(path) for path in input_paths]
    table_idxs = ones(Int64, length(tables))

    peptide_batch = getEmptyDF(first(tables), N)
    sorted_tuples = Vector{Tuple{Int64, Int64}}(undef, N)
    peptide_batch_names = Symbol.(names(peptide_batch))
    precursor_heap = BinaryMinHeap{Tuple{Float32, Int64}}()
    for (i, table) in enumerate(tables)
        addPrecursorToHeap!(
            precursor_heap,
            table[sort_key],
            i,
            1
        )
    end
    i = 1
    while length(precursor_heap) > 0
        _, table_idx = pop!(precursor_heap)
        table = tables[table_idx]
        idx = table_idxs[table_idx]
        sorted_tuples[i] = (table_idx, idx)
        table_idxs[table_idx] += 1
        idx = table_idxs[table_idx]
        if (idx > length(table[1]))
            continue
        end
        addPrecursorToHeap!(
            precursor_heap,
            table[sort_key],
            table_idx,
            idx
        )
        i += 1
        if i > N
            for col in peptide_batch_names
                fillColumn!(
                    peptide_batch[!,col],
                    col,
                    sorted_tuples,
                    tables,
                    i
                )
            end
            Arrow.append(
                output_path,
                peptide_batch
            )
            i = 1
        end
    end
    for col in peptide_batch_names
        fillColumn!(
            peptide_batch[!,col],
            col,
            sorted_tuples,
            tables,
            i
        )
    end
    Arrow.append(
        output_path,
        peptide_batch[range(1, max(1, i - 1)),:]
    )
    return nothing
end

#=
@time mergeSortedArrowTables(
    second_quant_folder,
    "/Users/n.t.wamsley/Desktop/test.arrow",
    (:protein_idx,:precursor_idx)
    N = 1000000
)
=#
