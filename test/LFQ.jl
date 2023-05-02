function Tol(a, b, ppm = 2)
    abs(a-b)<=(ppm*minimum((a, b))/1000000)
end

@testset "LFQ.jl" begin
prot = DataFrame(Dict(
    :peptides => ["A","A","A","B","B","B","C","C","C","D","D","D"],
    :protein => append!(split(repeat("A",9), ""), ["B","B","B"]),
    :file_idx => UInt32[1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3],
    :abundance => [10, 20, 40, 1, 2, 4, 100, 200, missing, 1000, 2000, 3000],
))

out = Dict(
    :protein => String[],
    :peptides => String[],
    :log2_abundance => Float64[],
    :experiments => UInt32[],
)

for (protein, data) in pairs(groupby(prot, :protein))
    println(typeof(protein[:protein]))
    getProtAbundance(string(protein[:protein]), 
                        collect(data[!,:peptides]), 
                        collect(data[!,:file_idx]), 
                        collect(data[!,:abundance]),
                        out[:protein],
                        out[:peptides],
                        out[:experiments],
                        out[:log2_abundance]
                    )
end

out[:log2_abundance][2] - out[:log2_abundance][2], 1.0

prot = DataFrame(Dict(
    :peptides => ["A","A","A","B","B","B","C","C","C","D","D","D"],
    :protein => append!(split(repeat("A",9), ""), ["B","B","B"]),
    :file_idx => UInt32[1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3],
    :abundance => [100, 200, 400, 100, 200, 400, 100, missing, missing, missing, missing, missing],
))

prot = DataFrame(Dict(
    :peptides => ["A","A","A","B","B","B","C","C","C","D","D","D"],
    :protein => append!(split(repeat("A",9), ""), ["B","B","B"]),
    :file_idx => UInt32[1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3],
    :abundance => [100, 200, 400, 100, 200, 400, 100, 200, 400, missing, missing, missing],
))

out = Dict(
    :protein => String[],
    :peptides => String[],
    :log2_abundance => Float64[],
    :experiments => UInt32[],
)
for (protein, data) in pairs(groupby(prot, :protein))
    println(typeof(protein[:protein]))
    getProtAbundance(string(protein[:protein]), 
                        collect(data[!,:peptides]), 
                        collect(data[!,:file_idx]), 
                        collect(data[!,:abundance]),
                        out[:protein],
                        out[:peptides],
                        out[:experiments],
                        out[:log2_abundance]
                    )
end

for col in eachcol(tm)
    col[ismissing.(col)] .= mean(skipmissing(col))
end

peptides = ["APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "APQHAQQSIR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "AAPVQQPR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "LQNETLHLAVNYIDR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR", "EDALAFNSAISLPGPR"]
file_idx = UInt32[0x00000015, 0x00000004, 0x00000003, 0x00000001, 0x0000002d, 0x00000002, 0x0000006f, 0x0000000a, 0x00000070, 0x00000029, 0x00000073, 0x0000006a, 0x0000001b, 0x00000067, 0x0000006e, 0x00000055, 0x00000008, 0x00000056, 0x00000027, 0x0000006b, 0x00000069, 0x0000000d, 0x00000072, 0x00000007, 0x0000000e, 0x00000028, 0x00000006, 0x0000002a, 0x0000003d, 0x00000074, 0x00000031, 0x0000006c, 0x0000006d, 0x00000071, 0x0000000b, 0x00000009, 0x00000018, 0x00000053, 0x0000002c, 0x00000041, 0x0000002e, 0x00000052, 0x0000001c, 0x00000068, 0x00000016, 0x00000066, 0x0000001d, 0x00000050, 0x00000023, 0x00000017, 0x0000004e, 0x00000030, 0x00000054, 0x00000037, 0x00000025, 0x0000004b, 0x0000004d, 0x00000044, 0x0000004f, 0x00000062, 0x00000034, 0x00000059, 0x00000024, 0x0000005b, 0x0000003b, 0x00000021, 0x00000060, 0x00000035, 0x0000002f, 0x00000058, 0x0000001e, 0x00000038, 0x0000005c, 0x0000003a, 0x00000040, 0x00000011, 0x00000042, 0x0000003e, 0x00000051, 0x00000020, 0x0000001a, 0x00000043, 0x00000039, 0x0000004c, 0x00000047, 0x0000005a, 0x00000032, 0x00000045, 0x00000014, 0x00000012, 0x0000003f, 0x0000000f, 0x00000057, 0x00000026, 0x00000046, 0x0000003c, 0x00000061, 0x00000022, 0x00000010, 0x00000001, 0x00000002, 0x00000003, 0x0000000c, 0x00000004, 0x00000029, 0x00000072, 0x00000070, 0x0000000d, 0x00000069, 0x00000005, 0x00000008, 0x0000006c, 0x00000073, 0x0000001b, 0x00000056, 0x00000027, 0x0000006e, 0x0000000a, 0x0000006f, 0x00000067, 0x00000006, 0x0000006b, 0x0000006d, 0x0000002a, 0x00000007, 0x00000028, 0x0000000e, 0x0000006a, 0x00000055, 0x0000002d, 0x00000015, 0x00000068, 0x0000000b, 0x00000009, 0x00000074, 0x00000011, 0x00000021, 0x00000013, 0x00000033, 0x00000030, 0x00000034, 0x00000026, 0x0000001a, 0x00000023, 0x0000001d, 0x0000001b, 0x00000017, 0x0000002b, 0x0000000a, 0x0000006f, 0x0000002e, 0x00000029, 0x00000072, 0x00000005, 0x00000014, 0x0000002c, 0x00000022, 0x00000003, 0x00000031, 0x00000001, 0x00000020, 0x0000000c, 0x00000012, 0x0000000f, 0x00000008, 0x00000027, 0x00000024, 0x00000035, 0x0000001e, 0x00000010, 0x0000002f, 0x0000002d, 0x00000006, 0x0000000d, 0x00000032, 0x00000059, 0x00000062, 0x00000070, 0x0000005c, 0x00000018, 0x0000001c, 0x0000000e, 0x0000004a, 0x0000005b, 0x0000004c, 0x00000016, 0x0000000b, 0x0000002a, 0x0000006e, 0x0000006b, 0x00000007, 0x00000050, 0x0000005e, 0x00000028, 0x00000052, 0x0000004f, 0x00000074, 0x0000005f, 0x0000004d, 0x00000068, 0x0000005a, 0x00000056, 0x00000053, 0x00000004, 0x00000002, 0x00000067, 0x00000009, 0x00000015, 0x00000058, 0x00000057, 0x00000051, 0x0000005d, 0x00000049, 0x00000060, 0x00000038, 0x00000055, 0x00000066, 0x00000048, 0x0000004b, 0x0000004e, 0x00000047, 0x00000043, 0x00000054, 0x00000044, 0x00000041, 0x00000040, 0x0000003b, 0x00000046, 0x0000003e, 0x00000037, 0x0000003a, 0x0000003d, 0x00000045, 0x0000003f, 0x00000042, 0x0000003c, 0x00000039, 0x00000036, 0x00000013, 0x00000021, 0x00000033, 0x00000011, 0x00000072, 0x0000002b, 0x0000001b, 0x0000006f, 0x00000030, 0x0000006c, 0x00000026, 0x0000002c, 0x0000001a, 0x00000070, 0x00000069, 0x00000034, 0x00000001, 0x00000020, 0x00000031, 0x00000027, 0x0000000a, 0x00000005, 0x00000073, 0x0000000c, 0x00000022, 0x0000001e, 0x0000000d, 0x0000002d, 0x00000006, 0x00000032, 0x0000000e, 0x00000010, 0x0000002f, 0x00000008, 0x00000035, 0x00000012, 0x0000006b, 0x00000062, 0x00000018, 0x0000001c, 0x00000071, 0x0000005b, 0x0000002a, 0x00000059, 0x00000016, 0x00000050, 0x00000007, 0x0000004f, 0x00000009, 0x0000000b, 0x00000074, 0x00000002, 0x0000004c, 0x00000061, 0x0000005e, 0x0000004a, 0x0000000f, 0x0000005f, 0x00000024, 0x0000005c, 0x00000068, 0x0000006d, 0x0000004d, 0x00000014, 0x00000056, 0x00000053, 0x00000004, 0x0000006a, 0x00000028, 0x00000058, 0x00000057, 0x00000067, 0x00000049, 0x0000005a, 0x0000005d, 0x00000063, 0x0000004b, 0x00000055, 0x00000054, 0x00000066, 0x0000004e, 0x00000038, 0x00000048, 0x00000047, 0x00000060, 0x00000040, 0x0000003b, 0x00000043, 0x00000041, 0x00000044, 0x0000003e, 0x00000046, 0x00000037, 0x0000003d, 0x00000015, 0x0000003a, 0x00000045, 0x00000042, 0x0000003f, 0x0000003c, 0x00000039, 0x00000036]
abundances = Union{Missing, Float64}[0.024747362272170413, 0.0133121225313627, 0.01467866353681324, 0.009966116735366296, 0.008470569618539944, 0.009595773834039058, 0.007402049336652764, 0.01067015106710168, 0.007836526902627249, 0.005459920702621162, 0.010920829252373556, 0.006808620794437804, 0.0183598615880923, 0.035573293526176934, 0.005578095596125945, 0.009902941048047854, 0.010757845105103785, 0.008372416671592496, 0.009886887891865204, 0.007198028363009034, 0.0057532498133782825, 0.008327278309195921, 0.0073671933155257585, 0.010160285591432353, 0.008562153357569288, 0.00829637800571425, 0.00828841412326265, 0.004097506674945959, 0.01279561094617945, 0.008622179582536431, 0.004269562156640626, 0.004505541536583709, 0.004301953302232933, 0.008505091644980015, 0.010421341995991117, 0.010200334154641609, 0.0064310596380986905, 0.0054701768579119995, 0.006152535628771099, 0.011847523958164533, 0.004675510924305074, 0.005806229533881643, 0.012870048193635323, 0.02971484600386963, 0.003936716110779359, 0.03323042749196845, 0.01206905333771921, 0.01587753492756163, 0.015048221175531755, 0.006223760703145961, 0.016825937201941442, 0.007240754381606509, 0.008506894181341929, 0.009750461168990632, 0.013738039128009213, 0.00681687588835829, 0.005311307883854637, 0.014548169650508829, 0.015436926739861235, 0.005268766181635017, 0.005579748966251646, 0.015518008851716924, 0.01643195260010495, 0.0021663263511647736, 0.011109707191274553, 0.017620612041610483, 0.006384879595203536, 0.006592401431675068, 0.005626142045488497, 0.016502542852094924, 0.014084743885306254, 0.011096344106158264, 0.0021914440465149003, 0.012184453390072908, 0.014522540969153667, 0.00665573645694075, 0.009624719963537236, 0.012077873448189938, 0.0069828514718133375, 0.01838123763584042, 0.014892650275580743, 0.010035991073020669, 0.010674260410195561, 0.0039797196296852315, 0.014818912238738614, 0.0019978732072539074, 0.004758596458289611, 0.014202836453600513, 0.0080926355754634, 0.0072846593028651555, 0.013487746313642048, 0.009439152357555559, 0.01163130868189052, 0.01717183983516007, 0.011507615214894767, 0.01398496985662813, 0.00675114110282824, 0.02471393751496781, 0.009392098500397421, 0.010833171269814345, 0.011422960061593287, 0.014733747374569695, 0.014938185441421408, 0.013396074194273806, 0.005381775646141853, 0.011665285325350268, 0.007941825184895092, 0.013290932226026913, 0.0070301287159154294, 0.010459701790407767, 0.02166650852365132, 0.007482785583746406, 0.01278626294232792, 0.015020483922523644, 0.007574129729916124, 0.006394646659516781, 0.007631207806113076, 0.018202099750638537, 0.008512426328708139, 0.031115278783248598, 0.015196576488665242, 0.008281737101301225, 0.008419445017388361, 0.00507855559995006, 0.011807677772670864, 0.008357977156623446, 0.015610800379389236, 0.00902698037223973, 0.009436626686552036, 0.007025201603351468, 0.003640617442276007, 0.03599636905799762, 0.020164050699518283, 0.021868241237405554, 0.013376284636696078, 0.0029036675564693276, 0.008937361512672697, 0.004245331698602125, 0.005933658767708578, 0.005597972957237027, 0.0048189236142338965, 0.007034792258058065, 0.005598309227397354, 0.001006662423283683, 0.005580680753374654, 0.004505666087196006, 0.004878384455626172, 0.0024691547633521735, 0.022958317514857995, 0.0009060810862202522, 0.002495773880994186, 0.002650292440050918, 0.0008907575224868691, 0.014913102845417909, 0.003253436361720345, 0.002832390287213311, 0.010128005394675265, 0.02035612830421988, 0.004615445772918782, 0.013171455462601662, 0.01578987111657384, 0.02210596440421302, 0.004406743143968856, 0.0039525291053978786, 0.02420567675864444, 0.0024829271920012394, 0.001506002857999581, 0.004945949097749108, 0.004768085505639654, 0.00344324549609794, 0.002510868089997013, 0.0032949431560401086, 0.014392099059379833, 0.02051006173886237, 0.005007258302307676, 0.011114106056319392, 0.009014210886517765, 0.0030988867783588066, 0.004902787349032581, 0.005009049054643734, 0.004295562086904286, 0.021167326782558425, 0.00396715784346082, 0.007254838989588672, 0.0023219722044073715, 0.00414522895059443, 0.022432836924245303, 0.0014238204212711815, 0.00209029142571124, 0.0010592968280212708, 0.015087783265378806, 0.011181087809527621, 0.006880648303145766, 0.0022642748824522403, 0.008285620757775954, 0.010954753476127945, 0.0016156812558637806, 0.006329629842590156, 0.00377115393148311, 0.026216273143767344, 0.0056090265731507044, 0.002447452669181639, 0.004951734490487995, 0.01842536608087428, 0.01667368270604576, 0.0316204167663597, 0.02453455805599261, 0.002362353533233303, 0.010482216440028525, 0.008446313313434683, 0.006939985635698091, 0.013441705388650565, 0.007831550592065206, 0.013625701268304966, 0.01659746482011409, 0.005234758783010407, 0.03842890291518114, 0.0049399439511972395, 0.0049402070216854185, 0.012849254779834127, 0.005823905329925264, 0.004347838245236511, 0.005070567132528185, 0.004485651050831598, 0.012765857938688088, 0.008728522452945075, 0.002763622982838081, 0.007058743578067633, 0.004434119778315, 0.014172775581352312, 0.00296057215544803, 0.004560708746935652, 0.008739742952455372, 0.004827525678883417, 0.0044488548298480006, 0.0031455367166093964, 0.002339679215256601, 0.01470018765834903, 0.006564929598095105, 0.013747012539346223, 0.005783536233964464, 0.005398245628517543, 0.0043054469373990205, 0.005064891432349212, 0.008107464495657654, 0.0035412027060852244, 0.003910310179376896, 0.0023874829732800106, 0.01082369156251601, 0.005149757443794978, 0.008688883852109152, 0.003365579404942934, 0.002773080571030237, 0.005427244625259974, 0.00594870402246519, 0.01226197505915378, 0.004210212840590989, 0.0049095069926450565, 0.01096579799452426, 0.007595296205295065, 0.005619630700058958, 0.008992725064573303, 0.014591864966551803, 0.008871480864903194, 0.009105609758421668, 0.004792643666231856, 0.006919958223357983, 0.002710850831954159, 0.010350956825183602, 0.004524229968629035, 0.003655407800572525, 0.013299728473434773, 0.004034109773315134, 0.004327565959690601, 0.0033183126206816366, 0.002129003560732086, 0.0038708173258740815, 0.008268844781347384, 0.004423179538164082, 0.006286437926794475, 0.0031155194055091755, 0.00931768748786513, 0.00236568278858075, 0.010330997885504763, 0.007171594197976467, 0.010418435007366481, 0.012431380457029788, 0.011184240868137104, 0.006550004595182469, 0.008153987203623517, 0.0029185798617839907, 0.001475073194084471, 0.010149831853964349, 0.0012401873986876645, 0.00608353669277136, 0.010679224880580877, 0.007071989735380544, 0.005288164104060255, 0.019814686304613905, 0.0027379919055463657, 0.003589382813584795, 0.0047138404595562, 0.004790495091518796, 0.003771529816601548, 0.007495691437349348, 0.0027197774457980686, 0.0039728156965690865, 0.01016304500127857, 0.008647879213534947, 0.02199481777232926, 0.0012257374355831424, 0.005714858291736368, 0.010846404580398615, 0.0003030257134858881, 0.0046489027903356015, 0.005520230406815676, 0.006036815868730568, 0.01945735962346134, 0.011248096310922315, 0.0031797724561837644, 0.0021488614473967266, 0.007227692051547384, 0.0010313074117156724, 0.006926496022172605, 0.005019323168922869, 0.005040222669352559, 0.0042480230499141085, 0.005752657514806876, 0.006347721823111044, 0.0062053038811324575, 0.0023967518086918118, 0.006130104680395323, 0.00321865738301661, 0.004724567352931292, 0.00622873852288219, 0.00521578970417897, 0.007794275960830358, 0.0059644540657796275, 0.00501045590485055, 0.0032992761324254975]
prot = DataFrame(Dict(
    :peptide => peptides,
    :protein => ["A" for x in 1:length(peptides)],
    :file_idx => file_idx,
    :abundance => abundances
))
out = Dict(
    :protein => String[],
    :peptides => String[],
    :log2_abundance => Float64[],
    :experiments => UInt32[],
)
for (protein, data) in pairs(groupby(prot, :protein))
    getProtAbundance(string(protein[:protein]), 
    collect(data[!,:peptide]), 
    collect(data[!,:file_idx]), 
    (collect(data[!,:abundance])),
                        out[:protein],
                        out[:peptides],
                        out[:experiments],
                        out[:log2_abundance]
                    )
    #println(protein[:parent])
end
display(DataFrame(out))

for pep in unique(prot.peptide)
    println(mean(prot[prot.peptide.==pep,:][!,:abundance]))
end

end