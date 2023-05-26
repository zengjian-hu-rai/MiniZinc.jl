# Copyright (c) 2022 MiniZinc.jl contributors
#
# Use of this source code is governed by an MIT-style license that can be found
# in the LICENSE.md file or at https://opensource.org/licenses/MIT.

module MiniZinc

import Chuffed_jll
import MathOptInterface as MOI
import MiniZinc_jll

const ReifiedLessThan{T} = MOI.Reified{MOI.LessThan{T}}
const ReifiedGreaterThan{T} = MOI.Reified{MOI.GreaterThan{T}}
const ReifiedEqualTo{T} = MOI.Reified{MOI.EqualTo{T}}
const ReifiedBinPacking{T} = MOI.Reified{MOI.BinPacking{T}}
const ReifiedTable{T} = MOI.Reified{MOI.Table{T}}

MOI.Utilities.@model(
    Model,
    (MOI.ZeroOne, MOI.Integer),
    (MOI.EqualTo, MOI.GreaterThan, MOI.LessThan, MOI.Interval),
    (
        MOI.AllDifferent,
        MOI.Circuit,
        MOI.CountAtLeast,
        MOI.CountBelongs,
        MOI.CountDistinct,
        MOI.CountGreaterThan,
        MOI.Cumulative,
        MOI.Path,
        MOI.Reified{MOI.AllDifferent},
        MOI.Reified{MOI.CountAtLeast},
        MOI.Reified{MOI.CountBelongs},
        MOI.Reified{MOI.CountDistinct},
        MOI.Reified{MOI.CountGreaterThan},
        MOI.Reified{MOI.Cumulative},
    ),
    (
        MOI.BinPacking,
        MOI.Table,
        ReifiedBinPacking,
        ReifiedTable,
        ReifiedLessThan,
        ReifiedGreaterThan,
        ReifiedEqualTo,
    ),
    (),
    (MOI.ScalarAffineFunction,),
    (MOI.VectorOfVariables,),
    (MOI.VectorAffineFunction,)
)

function MOI.supports_constraint(
    ::Model{T},
    ::Type{MOI.VectorAffineFunction{T}},
    ::Type{<:MOI.AbstractVectorSet},
) where {T}
    return false
end

function MOI.supports(
    ::Model{T},
    ::MOI.ObjectiveFunction{F},
) where {
    T,
    F<:Union{
        MOI.VectorOfVariables,
        MOI.VectorAffineFunction{T},
        MOI.VectorQuadraticFunction{T},
    },
}
    return false
end

function MOI.supports_constraint(
    ::Model{T},
    ::Type{MOI.VectorAffineFunction{T}},
    ::Type{MOI.Reified{S}},
) where {T,S<:Union{MOI.LessThan{T},MOI.GreaterThan{T},MOI.EqualTo{T}}}
    return true
end

MOI.supports(::Model, ::MOI.NLPBlock) = true

function MOI.set(model::Model, ::MOI.NLPBlock, data::MOI.NLPBlockData)
    model.ext[:nlp_block] = data
    return
end

include("write.jl")
include("optimize.jl")

end # module
