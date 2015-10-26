export entropyknn

using KDTrees

"""
Estimates the entropy of a continuous data set using the
algorithm outlined in: Kraskov A, Stögbauer H, Grassberger P.
Estimating mutual information. Physical Review E. 2004;
69(6):066138, previously implemented in Python:
http://www.isi.edu/~gregv/npeet.html.

Parameters:

data - dxn Array{Float64,2} - Data array where n is the number
of data points and d is the dimensionality of the data. KDTree
requires an array of this shape.

k - Int - The degree of nearest neighbours to find. Must be
smaller n.

base - Int - The base of the logarithm, i.e. the units.

intens - Float - A multiplier for adding noise.
"""
function entropyknn(data::Array{Float64,2}, k=3, base=2, intens=1e-10)
	d, n = size(data)
	assert(k < n)

	# Add noise to each data point
	data = data + rand(d, n) * intens

	# Make the KD tree
	tree = KDTree(data)

	# Make array of distances to kth nearest neighbour for each
	# data point
	distances = Array(Float64, 0)
	for i in 1:n
		# Query the tree for the k nearest neighbours using knn
		# (requires the data to be reshaped)
		point = reshape(data[1:d, i:i], d)
		push!(distances, knn(tree, point, k + 1)[2][k + 1])
	end

	# Substitute distances into the equation
	c = digamma(n) - digamma(k) + d * log(2)
	(c + d * mean(log(distances))) / log(base)
end
