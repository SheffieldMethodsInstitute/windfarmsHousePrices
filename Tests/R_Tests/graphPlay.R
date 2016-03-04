#library(network)
library(igraph)

#http://stackoverflow.com/questions/21648530/graph-that-average-degree-node-is-4-in-r
#test rel betw av degree and density
gsize = 100

# g5 <- random.graph.game(gsize, gsize * 8 / 2, type="gnm")
g <- erdos.renyi.game(gsize, gsize * 8 / 2, type="gnm")
mean(degree(g))
graph.density(g)

#http://stackoverflow.com/questions/8011678/2nd-degree-connections-in-igraph
G <- get.adjacency(g)

G2 <- G %*% G        # G2 contains 2-walks
diag(G2) <- 0        # take out loops
G2[G2!=0] <- 1 # normalize G2, not interested in multiplicity of walks

g2 <- graph.adjacency(G2)

length(V(g2))
mean(degree(g2))

hist(degree(g))
hist(degree(g2))

sd(degree(g))


#http://www.inside-r.org/packages/cran/igraph/docs/erdos.renyi.game

#20% labelled as yes for cluster
#g <- erdos.renyi.game(1000, 1/100)

# g <- erdos.renyi.game(1000, 1/100) %>%
g <- erdos.renyi.game(gsize, gsize * 8 / 2, type="gnm") %>%
  set_vertex_attr("inCluster", value = c (rep("yes",vcount(g)*0.2),rep("no",vcount(g)*0.8)) )

table(V(g)$inCluster)

mean(degree(g))

graph.density(g)

#hist(degree(g), breaks=15)


#select random edge where one is in in cluster, one out
#edges <- get.edgelist(g)

#edges[1,]


#Is one vertex in and one out?
# for(n in 1:length(V(g)) ) {
#   
# print( paste0(V(g)[edges[n,1]]$inCluster,",",V(g)[edges[n,2]]$inCluster) ) 
# 
# }


# inout <- c(0,0)
# 
# for(n in 1:length(V(g)) ) {
# 
# #This misses all the "no / yeses" of course
# if( (V(g)[edges[n,1]]$inCluster == "yes" && V(g)[edges[n,2]]$inCluster == "no")|
#    (V(g)[edges[n,1]]$inCluster == "no" && V(g)[edges[n,2]]$inCluster == "yes") ) {
#   
#   #print("Yes!")
#   inout[1] = inout[1] + 1
#   
#   
# } else {
#   #print("Newp!")
#   inout[2] = inout[2] + 1
# }
# 
# }#end for
# 
# inout

#So how does degree change if we re-assign?
#Here they are to start with
mean(degree(g, V(g)$inCluster == "yes"))
mean(degree(g, V(g)$inCluster == "no"))
hist(degree(g, V(g)$inCluster == "yes"), breaks=20)
hist(degree(g, V(g)$inCluster == "no"), breaks=20)

#http://www.inside-r.org/packages/cran/igraph/docs/iterators
#Both produce same result but appear to produce ordered pairs
edges2 <- E(g)[ (V(g)$inCluster=="yes") %--% (V(g)$inCluster=="no") ]
edges2 <- E(g)[ (V(g)$inCluster=="no") %--% (V(g)$inCluster=="yes") ]

#check in-cluster connections before and after
print("in cluster connections before:")
length(E(g)[ (V(g)$inCluster=="yes") %--% (V(g)$inCluster=="yes") ])

#http://stackoverflow.com/questions/34969528/from-igraph-es-edge-sequence-to-nodes-in-r
for (i in 1:length(edges2)){
  
  print( paste0( V(g)[ends(g, edges2[i])[1]]$inCluster,",", V(g)[ends(g, edges2[i])[2]]$inCluster  )  )
  
}

#Seemed to work! Now re-assign fraction of these from "no" to "yes" nodes.
#So just need to remove edge completely
#Keep record of "yes" node.
#Find another "yes" node to attach to.
removes = c()
addRandoms = c()
addInNode = c()

count = 1

#crude 50%
for (i in seq(from= 1, to  = length(edges2), by = 2)){
# for (i in 1:length(edges2)){
  
  
  #which node is in the cluster already? If it's not 1 it has to be 2
  if(V(g)[ends(g, edges2[i])[1]]$inCluster == "yes") {
    inClusterNode <- ends(g, edges2[i])[1]
  } else {
    inClusterNode <- ends(g, edges2[i])[2]
  }
  
  #remove the edge
  removes[count] = edges2[i]
  
  #replace with one internal to cluster
  randomVertex <- runif(n=1, min=1, max=length(V(g)))
  
  #While I'm failing to find a cluster node or that node is me...
  while(V(g)[randomVertex]$inCluster!="yes" | as.integer(randomVertex)==inClusterNode){
  
  randomVertex <- runif(n=1, min=1, max=length(V(g)))
  
  #If I'm in the cluster and I'm not trying to connect to myself...
  #if (V(g)[randomVertex]$inCluster=="yes" && as.integer(randomVertex)!=inClusterNode){
    #print("myself!")
    
    #don't need to set attribute, we know it's "yes" already
    
  #} 
  
  }#end while
  
  #adds[i] <- c(inClusterNode,as.integer(randomVertex))
  addRandoms[count] <- as.integer(randomVertex)
  addInNode[count] <- inClusterNode
  
  count = count + 1 
  
}#end for

#http://stackoverflow.com/questions/23732591/make-list-of-vectors-by-joining-pair-corresponding-elements-of-2-vectors-efficie
adds <- mapply(c, addRandoms, addInNode, SIMPLIFY=F)

g <- delete_edges(g, removes)

#clearly must be a better way than this!
for(i in 1:length(adds)){
  g <- add_edges(g, c(adds[[i]][1],adds[[i]][2]))
}

print("in cluster connections after:")
length(E(g)[ (V(g)$inCluster=="yes") %--% (V(g)$inCluster=="yes") ])

mean(degree(g, V(g)$inCluster == "yes"))
mean(degree(g, V(g)$inCluster == "no"))


length(E(g)[ (V(g)$inCluster=="yes") %--% (V(g)$inCluster=="no") ])
length(E(g)[ (V(g)$inCluster=="yes") %--% (V(g)$inCluster=="yes") ])
length(E(g)[ (V(g)$inCluster=="no") %--% (V(g)$inCluster=="no") ])


















