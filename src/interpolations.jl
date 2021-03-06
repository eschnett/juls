"""Linear interpolation of a variable u in the x-direction.
m,n = size(ux) must be m+1,n = size(u)."""
function Ix!(ux::AbstractMatrix,u::AbstractMatrix)
    m, n = size(ux)
    @boundscheck (m+1,n) == size(u) || throw(BoundsError())

    @inbounds for j ∈ 1:n
        for i ∈ 1:m
            ux[i,j] = one_half*(u[i+1,j] + u[i,j])
        end
    end
end

""" Linear interpolation a variable u in the y-direction.
    m,n = size(uy) must be m,n+1 = size(u)."""
function Iy!(uy::AbstractMatrix,u::AbstractMatrix)
    m,n = size(uy)
    @boundscheck (m,n+1) == size(u) || throw(BoundsError())

    @inbounds for j ∈ 1:n
        for i ∈ 1:m
            uy[i,j] = one_half*(u[i,j+1] + u[i,j])
        end
    end
end

""" Bilinear interpolation a variable u in x and y-direction.
m,n = size(uxy) must be m+1,n+1 = size(u). """
function Ixy!(uxy::AbstractMatrix,u::AbstractMatrix)
    m,n = size(uxy)
    @boundscheck (m+1,n+1) == size(u) || throw(BoundsError())

    @inbounds for j ∈ 1:n
        for i ∈ 1:m
            uxy[i,j] = one_quart*(u[i,j] + u[i+1,j] + u[i,j+1] + u[i+1,j+1])
        end
    end
end
