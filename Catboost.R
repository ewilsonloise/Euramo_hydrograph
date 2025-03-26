# Introduction to CatBoost Algorithm

#snippet from: Enhancing Flood Management Through Machine Learning: A Comprehensive Analysis of the CatBoost Application
# https://doi.org/10.38124/ijisrt/IJISRT24JUN1770

# CatBoost (Categorical Boosting) is a Gradient Boosting Decision Trees (GBDT) algorithm 
# designed to handle categorical features efficiently during training (Dorogush et al., 2018). 
# It is widely used for prediction, recommendation, and ranking tasks (Peretz, 2018). 

# Unlike traditional GBDT methods, CatBoost processes categorical features dynamically 
# during training rather than preprocessing, reducing data leakage. It uses a random 
# permutation approach to encode categories, calculating the average label value for 
# previous occurrences in the permutation (Xu et al., 2023). 

# CatBoost supports feature combinations, merging categorical features iteratively to 
# improve splits. The algorithm applies a greedy approach to optimize feature interactions 
# (Zhong et al., 2023). Each split in the tree is treated as a new category with two values 
# (Huang et al., 2019). 

# CatBoost has two tree-building modes: Ordered and Plain. Ordered mode mitigates gradient 
# bias, while Plain mode follows the standard GBDT approach with ordered target statistics 
# (Prokhorenkova et al., 2018). 

# While CatBoost performs well with default settings, tuning key parameters improves 
# accuracy. Training can be computationally expensive, but multiple random permutations 
# help enhance robustness.


install.packages('devtools')
devtools::install_github('catboost/catboost', subdir = 'catboost/R-package')

install.packages('devtools')



