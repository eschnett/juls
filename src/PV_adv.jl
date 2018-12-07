"""Potential vorticity calculated as q = (f + ∂v/∂x - ∂u/∂y)/h."""
function PV!(q,f_q,dvdx,dudy,h_q)
    m,n = size(q)
    @boundscheck (m,n) == size(f_q) || throw(BoundsError())
    @boundscheck (m+2,n+2) == size(dvdx) || throw(BoundsError())
    @boundscheck (m+2+ep,n+2) == size(dudy) || throw(BoundsError())
    @boundscheck (m,n) == size(h_q) || throw(BoundsError())

    @inbounds for j ∈ 1:n
        for i ∈ 1:m
            q[i,j] = (f_q[i,j] + dvdx[i+1,j+1] - dudy[i+1+ep,j+1]) / h_q[i,j]
        end
    end
end

"""Advection of potential voriticity qhv,qhu as in Sadourny, 1975
enstrophy conserving scheme."""
function PV_adv_Sadourny!(qhv,qhu,q,qα,qβ,qγ,qδ,q_u,q_v,U,V,V_u,U_v)
    Iy!(q_u,q)
    Ix!(q_v,q)
    Ixy!(V_u,V)
    Ixy!(U_v,U)

    m,n = size(qhv)
    @boundscheck (m+2-ep,n) == size(q_u) || throw(BoundsError())
    @boundscheck (m+2-ep,n) == size(V_u) || throw(BoundsError())

    @inbounds for j ∈ 1:n
        for i ∈ 1:m
            qhv[i,j] = q_u[i+1-ep,j] * V_u[i+1-ep,j]
        end
    end

    m,n = size(qhu)
    @boundscheck (m,n+2) == size(q_v) || throw(BoundsError())
    @boundscheck (m,n+2) == size(U_v) || throw(BoundsError())

    @inbounds for j ∈ 1:n
        for i ∈ 1:m
            qhu[i,j] = q_v[i,j+1] * U_v[i,j+1]
        end
    end
end

"""Advection of potential vorticity qhv,qhu as in Arakawa and Hsu, 1990
Energy and enstrophy conserving (in the limit of non-divergent mass flux) scheme with τ = 0."""
function PV_adv_ArakawaHsu!(qhv,qhu,q,qα,qβ,qγ,qδ,q_u,q_v,U,V,V_u,U_v)
    # Linear combinations α,β,γ,δ of potential vorticity q
    AHα!(qα,q)
    AHβ!(qβ,q)
    AHγ!(qγ,q)
    AHδ!(qδ,q)

    # Linear combinations of q and V=hv to yield qhv
    m,n = size(qhv)
    @inbounds for j ∈ 1:n
        for i ∈ 1:m
            qhv[i,j] = qα[1-ep+i,j]*V[2-ep+i,j+1] + qβ[1-ep+i,j]*V[1-ep+i,j+1] + qγ[1-ep+i,j]*V[1-ep+i,j] + qδ[1-ep+i,j]*V[2-ep+i,j]
        end
    end

    # Linear combinations of q and U=hu to yield qhu
    m,n = size(qhu)
    @inbounds for j ∈ 1:n
        for i ∈ 1:m
            qhu[i,j] = qα[i,j]*U[i,j+1] + qβ[i+1,j]*U[i+1,j+1] + qγ[i+1,j+1]*U[i+1,j+2] + qδ[i,j+1]*U[i,j+2]
        end
    end
end

""" Linear combination α of potential voriticity q according
to the energy and enstrophy conserving scheme of Arakawa and Hsu, 1990"""
function AHα!(α::AbstractMatrix,q::AbstractMatrix)
    m,n = size(α)
    @boundscheck (m+1,n+1) == size(q) || throw(BoundsError())

    @inbounds for j ∈ 1:n
        for i ∈ 1:m
            α[i,j] = one_twelve*(q[i,j] + q[i,j+1] + q[i+1,j+1])
        end
    end
end

""" Linear combination δ of potential voriticity q according
to the energy and enstrophy conserving scheme of Arakawa and Hsu, 1990 """
function AHβ!(β::AbstractMatrix,q::AbstractMatrix)
    m,n = size(β)
    @boundscheck (m,n+1) == size(q) || throw(BoundsError())

    @inbounds for j ∈ 1:n
        β[1,j] = one_twelve*(q[1,j] + q[1,j+1] + q[end,j+1])
        for i ∈ 2:m
            β[i,j] = one_twelve*(q[i,j] + q[i,j+1] + q[i-1,j+1])
        end
    end
end

""" Linear combination γ of potential voriticity q according
to the energy and enstrophy conserving scheme of Arakawa and Hsu, 1990 """
function AHγ!(γ::AbstractMatrix,q::AbstractMatrix)
    m,n = size(γ)
    @boundscheck (m,n+1) == size(q) || throw(BoundsError())

    @inbounds for j ∈ 1:n
        γ[1,j] = one_twelve*(q[1,j] + q[1,j+1] + q[end,j])
        for i ∈ 2:m
            γ[i,j] = one_twelve*(q[i,j] + q[i-1,j] + q[i,j+1])
        end
    end
end

""" Linear combination β of potential voriticity q according
to the energy and enstrophy conserving scheme of Arakawa and Hsu, 1990 """
function AHδ!(δ::AbstractMatrix,q::AbstractMatrix)
    m,n = size(δ)
    @boundscheck (m+1,n+1) == size(q) || throw(BoundsError())

    @inbounds for j ∈ 1:n
        for i ∈ 1:m
            δ[i,j] = one_twelve*(q[i,j] + q[i,j+1] + q[i+1,j])
        end
    end
end


# Sadourny, 1975 enstrophy conserving scheme
if adv_scheme == "Sadourny"
    PV_adv! = PV_adv_Sadourny!
elseif adv_scheme == "ArakawaHsu"
    PV_adv! = PV_adv_ArakawaHsu!
else
    throw(error("Advection scheme incorrectly specified. Only Sadourny or ArakawaHsu allowed."))
end
