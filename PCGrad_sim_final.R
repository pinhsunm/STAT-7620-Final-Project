library(torch)
library(ggplot2)
library(dplyr)
library(tidyr)

##Defining two loss functions with the Tragic Triad
##Suppose model parameters in R^2
loss1<-function(theta){
  0.5*(theta[1]+1)^2+5*theta[2]^2
}

loss2<-function(theta){
  10*(theta[1]-5)^2+0.5*(theta[2]-5)^2
}

##PCGrad

pcgrad_func<-function(g1,g2){
  inner_prod<-torch_dot(g1,g2)$item()
  if(inner_prod < 0){
    ##Compute gradient using PCGrad for g1 and g2
    denom2 <- torch_dot(g2,g2)$item() + 1e-8
    g1_pc<-g1-(inner_prod/denom2)*g2
    
    denom1 <- torch_dot(g1,g1)$item() + 1e-8
    g2_pc<-g2-(inner_prod/denom1)*g1
    
    return(g1_pc+g2_pc)
    
  } else {
    return(g1+g2)
  }
}

## simulation function
sim_fun<-function(theta_int,l_rate,steps, label =""){
  ##PCGrad
  # Initialize parameters
  theta <- torch_tensor(theta_int, requires_grad = TRUE)
  optimizer <- optim_sgd(list(theta), lr = l_rate)
  
  # path information
  path_pcgrad <- list()
  
  ##Training loop
  for (t in 1:steps) {
    # Obtain the gradient for task 1
    optimizer$zero_grad()
    l1<-loss1(theta)
    l1$backward(retain_graph = TRUE) ## Keep the computational graph for task 2
    g1<-theta$grad$clone() ##copy gradient
    
    
    # Obtain the gradient for task 2
    optimizer$zero_grad()
    l2<-loss2(theta)
    l2$backward()
    g2<-theta$grad$clone()
    
    ##Conduct PCGrad
    g_final <-pcgrad_func(g1,g2)
    
    ## Modify the gradient by using g_final
    with_no_grad({
      theta$grad<-g_final
    })
    
    ##Update weights
    optimizer$step()
    
    ## Record the path for parameter updates
    path_pcgrad[[t]] <- as.numeric(theta)
  }
  
  ##Standard SGD
  # Initialize parameters
  theta_sgd <- torch_tensor(theta_int, requires_grad = TRUE)
  opt_sgd <- optim_sgd(list(theta_sgd), lr = l_rate)
  path_sgd <- list()
  
  ##Training loop
  for (t in 1:200) {
    opt_sgd$zero_grad()
    
    # compute the two losses
    l1 <- loss1(theta_sgd)
    l2 <- loss2(theta_sgd)
    
    # total loss is the direct sum of the two gradients
    total_loss <- l1 + l2
    total_loss$backward()
    
    # Update weights
    opt_sgd$step()
    
    #record the path for parameter updates
    path_sgd[[t]] <- as.numeric(theta_sgd)
  }
  
  ##Combining data for visualization
  df_pcgrad<-as.data.frame(do.call(rbind, path_pcgrad))%>%mutate(method ="PCGrad",step= row_number())
  df_sgd<-as.data.frame(do.call(rbind, path_sgd))%>%mutate(method = "Standard SGD",step= row_number())
  
  init_df <- data.frame(V1 = theta_int[1], V2 = theta_int[2], step = 0)
  
  rbind(init_df %>% mutate(method = "PCGrad"), df_pcgrad , 
        init_df %>% mutate(method = "Standard SGD"), df_sgd) %>%
    rename(x = V1, y = V2) %>%
    mutate(exp_label = label, lr_val = l_rate)
}



##Simulations
# Four scenarios
scenarios <- list(
  list(pos = c(2, 2), steps = 200,  lr = 0.01, lab = "1. Initilal point (2,2) with learning rate 0.01"),
  list(pos = c(2, 2), steps=200,  lr = 0.05, lab = "2. Initilal point (2,2) with learning rate 0.05"),
  list(pos = c(0.5, 4), steps = 200, lr = 0.01, lab = "3. Initila point (0.5,4) with learning rate 0.01"),
  list(pos = c(0, 0), steps = 200,  lr = 0.05, lab = "4. Initila point (0,0) with learning rate 0.05")
)

# combine the results
all_results <- do.call(rbind, lapply(scenarios, function(s) {
  sim_fun(s$pos, s$lr, s$steps, label = s$lab)
}))

# Data for visualization
grid <- expand.grid(x = seq(-2, 6, length.out = 100), y = seq(-2, 6, length.out = 100))
contour_data <- grid %>% mutate(total_loss = (0.5*(x+1)^2+5*y^2) + (10*(x-5)^2+0.5*(y-5)^2))

ggplot(all_results, aes(x = x, y = y, color = method)) +
  # contour lines
  geom_contour(data = contour_data, aes(z = total_loss), color = "gray", bins = 40) +
  # path_info
  geom_path(aes(linetype = method), size = 1) +
  # starting point (step = 0)
  geom_point(data = filter(all_results, step == 0), color = "black", size = 2) +
  #Visulizing 4 plots
  facet_wrap(~exp_label, scales = "fixed") +
  coord_fixed() +
  scale_color_manual(values = c("PCGrad" = "blue", "Standard SGD" = "red")) +
  theme_minimal() +
  labs(title = "PCGrad v.s. SGD under the four scenarios")

