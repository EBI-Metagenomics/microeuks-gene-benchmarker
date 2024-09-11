# Use the official R base image
FROM rocker/r-ver:4.1.0

# Install required R packages
RUN R -e "install.packages(c('ggplot2', 'ggpubr', 'dplyr'), repos='http://cran.rstudio.com/')"

# Set the working directory
WORKDIR /usr/local/src

# Copy any required files into the container (if necessary)
# COPY . .

# Command to run R
CMD ["R"]