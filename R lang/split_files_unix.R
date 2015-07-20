# Lopp will split dataframe into parts
# name: SAN_DOCULIVE_20150412112703.sf
# f_split_file(WYNIK, 2,10)
# f_split_file(WYNIK, 2,10000, "trash")

f_split_file <- function(c_table, n_start,n_part, c_name )
{
	n_rows <- nrow(c_table)
	n_ite  <- n_rows %/% n_part
	n_rest <- n_rows %% n_part
	n_low  <- n_start
	n_high <- n_low + n_part - 1 
	
	for ( i in 1:n_ite ) {
		n_range <- c(n_low:n_high)
		c_file_name <- paste(c_name, i , ".sf",sep="")
		f_file = file(c_file_name, "wb")
		write.table(file=f_file, c_table[n_range,] , row.names = FALSE , col.names = FALSE , eol = "\n" )
		n_low <- n_low + n_part
		n_high <- n_high + n_part
		close(f_file)
	}
	if ( n_rest > 0)
	{
		i <- i + 1
		n_low <- n_high - n_part + 1
		n_high <- n_rows
		n_range <- c(n_low:n_high)
		c_file_name <- paste(c_name, i , ".sf",sep="")
		f_file = file(c_file_name, "wb")
		write.table(file=f_file, c_table[n_range,] , row.names = FALSE , col.names = FALSE , eol = "\n" )
		close(f_file)
	}
}