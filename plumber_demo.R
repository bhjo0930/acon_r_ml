#install.packages("plumber")
#library(plumber)

# plumber.R

#* Echo back the input
#* @param msg The message to echo
#* @get /echo
function(msg=""){
  list(msg = paste0("The message is: '", msg, "'"))
}

#* Plot a histogram
#* @png
#* @get /plot
function(){
  rand <- rnorm(100)
  hist(rand)
}

#* Return the sum of two numbers
#* @param a The first number to add
#* @param b The second number to add
#* @post /sum
function(a, b){
  as.numeric(a) + as.numeric(b)
}

r <- plumb("plumber.R")  # Where 'plumber.R' is the location of the file shown above
r$run(port=8000)
#You can visit this URL using a browser or a terminal to run your R function and get the results. 
#For instance http://localhost:8000/plot will show you a histogram, and 
#http://localhost:8000/echo?msg=hello will echo back the 'hello' message you provided.

#curl "http://localhost:8000/echo"
#curl "http://localhost:8000/echo?msg=hello"


