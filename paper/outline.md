##Introduction  

In 2015 at the end of the tracking period for the Millennium Development Goals (MDGs) the report Countdown to 2015,released by the World Health Organization, stated that, of the 75 priority countries followed by an ongoing analysis of child mortality monitoring, Mexico was one of twenty five countries that successfully achieved the goal of reducing under 5 mortality by two thirds [@victora_countdown_2016], reducing their national under 5 mortality rate from 48 to 16 deaths per 1000 live births. The health sector reforms and programs that helped achieve this goal [@sepulveda_improvement_2006; @king_public_2009] as well as the specific causes of mortality that were reduced [@sepulveda_improvement_2006] have previously been documented, however, little is known about the within Mexico variability of under 5 mortality and its shifting distribution[@sepulveda_improvement_2006; @wang_global_2016]. As we change paradigms of evaluation from the MDGs to the Sustainable Development Goals (SDGs) a stronger focus has been placed on equity both within and among countries. Not only should we be making progress in reducing poverty, improving health, and increasing years of education but sub-populations with the least access to these resources should be prioritized for improvements in order to lessen the gap.

Evaluating the disparate state of health outcomes within administrative boundaries is not a new field and the lack of available information relevant to the topic is predominately a function of lack of data reporting. Most countries are ill-equipped in terms of their health reporting system's ability to provide analytical evidence that can influence health-based policies for subnational populations [@horton_new_2006]. In the absence of vital registration systems, household surveys are often used to estimate health outcomes; however, how to best assess child mortality from these surveys in terms of survey development, design, and analysis for subpopulations at a small geographic scale is still widely debated [@dwyer-lindgren_error_2013; @mercer_spacetime_2015; @verhulst_child_2016]. Even in countries with near complete vital registration systems, there is little consensus on how to analyze subpopulations, and results are often questioned when they differ from the national trend [@case_rising_2015; @dwyer-lindgren_inequalities_2017]. For both survey and vital registration data there is no consensus on how to analyze the data when small area estimation is of concern.

In this paper we analyze the annual age specific mortality rates under the age of 5 at the municipality level within Mexico. Analyzing health outcomes at small geographical units can identify discrepancies in health that are due to an unequal spatial distribution of health system resources, but also can uncover discrepancies in subpopulations that tend to cluster in space, such as class, race, and ethnicity [@soja_seeking_2010]. Though previous studies have examined how child mortality differs within Mexico, the smallest unit of analysis has only been at the state [@sepulveda_improvement_2006; @wang_global_2016] or district level [@rajaratnam_measuring_2010]. In more recent studies of inequality in mortality rates in the United States [@dwyer-lindgren_inequalities_2017], analyses have shown that state level analysis can mask inequalities that are geographically correlated at more detailed levels. In addition, the quality of the vital registration system in Mexico has been praised for its ability to accurately identify cause of death[@morris_predicting_2003; @mahapatra_civil_2007], but the coverage of the system at a subnational level has been examined less thoroughly in terms of documenting those who are living in poorer rural geographies [@_under-registration_2012]. This lack of coverage may bias results of mortality estimates such that they deviate away from unobserved populations who likely have a very different health profile than those who are observed. In order to assess the extent to which this bias may exist, we estimate the time until registration from birth for each documented birth in Mexico.

This analysis of municipality level mortality in Mexico has four areas of novel analysis and scientific contribution. First we will assess the geographic distribution of quality of vital registration coverage by assessing the municipality distribution of time from birth till registration. Second, we present a novel method for estimating small area child mortality rate which accounts for geographic proximity as well as correlations in time and age. Third, we apply this methodology and compare its results to other more traditional models. Fourth, we compare our models estimates at the municipality level against the national goal of 16 deaths per 1000 live births by calculating the probability of death before age 5, ($~_5q_{0}$) for each municipality.

## Methods  

### Data  
De-identified person level data was extracted from INEGI and SINAC vital registration reports for the years year_start to year_end for birth records. Of the number_of_birth_records birth records that were extracted muni_birthp had a properly identified household location of parents that was used as the geolocation for this analysis, placing each record in one of the 2456 municipalities within Mexico. The records that did not have a municipality associated with them were approximately evenly distributed across states and were discarded from the analysis. Death registration data was extracted from person level de-identified INEGI reports where municipality of residence, year of occurrence, and age of individual given by single year was used provided that information existed for the death record. Of the n_u5_deaths deaths that were reported as under the age of 5, p_u5_deaths had values for year, age, and municipality that were valid. Since data was not linked by person and single year populations by single year age and municipality were not available in other data sources, populations were estimated by taking the births of individuals for a particular municipality age and moving them one year forward in age as calendar year progressed, while also subtracting the deaths for that population. The formula is as follows where $P$ is population number, $D$ is death number, $a$ is a single year age, $t$ is a single year time period, and $l$ is a municipality.

$$
P_{l,a,t} = P_{l,a-1,t-1} - D_{l,a-1,t-1}
$$

This cohort method of tracking mortality and populations makes the assumption of net zero migration for all demographic units.

### Analysis of time till birth registration.  
Each person level birth record data point which had a year of birth also included a year of registration. For each record we calculate the difference between the year of birth and the year of registration and assign the difference to its municipality of residence. The mean time of registration from birth for each district was calculated. In order to assess the degree of geospatial correlation, and possible sociodemographic patterns of individuals that may underly the geographic patterns, that exists in these differences a Moran's I test is run. The Moran's I test assess the degree of spatial autocorrelation that exists within data by examining how much signal can be derived for a single point by only looking at adjacent points within the data set. In our case a single point is a municipality and the adjacent point are those municipalities that share a border with it. The calculation is as follows

$$
I = \frac{N}{W} \frac{\Sigma_i \Sigma_j w_{ij}(x_i - \bar{x})(x_j - \bar{x})}{\Sigma_i (x_i - \bar{x})^2}
$$

where $N$ is the number of spatial units indexed by $i$ and $j$; $x$ is the variable of interest; $\bar{x}$ is the mean of $x$; $w_{ij}$ is a matrix of spatial weights with zeros on the diagonal (i.e., $w_{ii}=0$; and $W$ is the sum of all $w_{ij}$. The statistic test for the probability that the value of I is significantly greater than zero, indicating positive autocorrelation among data.

### Modeling Strategies  
In order to estimate the underlying mortality rate of municipalities within Mexico, especially in areas where observed populations are small, our modeling approach borrows strength across dimensions of geography, age, and time in order to disentangle the true underlying mortality rate from the process error that is observed. This hierarchical smoothing process is used extensively in demographic forecasting and small area estimation in order to draw predictive power from observations that are correlated and not underestimate the standard error of fixed effects[@girosi_demographic_2008, @banerjee_hierarchical_2003, @hodges_adding_2010, @currie_smoothing_2004]. The functional form of the model is as follows where $\phi$ is a random effect term which is specific to a particular municipality, age, and year, and the other notations remain as previously specified.

$$
D_{l,a,t} \sim Poisson(\hat{D}_{l,a,t})
$$
$$
\hat{D}_{l,a,t} = exp(\beta_a + \phi_{l,a,t}) * P_{l,a,t}
$$

The $\phi$ term follows a multivariate normal distribution with covariance matrix $Q^{-1}$ where $Q$ is the precision matrix of the multivariate normal process. For our model, it may also be stated that $\phi$ exhibits behavior of a Gaussian Markov Random Field (GMRF) as each demographic unit of $\phi$ is modeled as conditionally independent from other points with which it does not share a border. This can otherwise be stated as

$$
Q_{x,y} = 0  \iff {u,v} \not\subset E
$$

$Q$ is a GMRF because it is formed by taking the Kronecker product of three well defined GMRFs given the property that the Kronecker product of a set of GMRFs is itself a GMRF [@rue_gaussian_2005]. The three precision matrices that define $Q$ are $Q^t$, $Q^a$, and $Q^l$, which parameterize the correlations that exist between units of time, age, and geography respectively. It can then be seen that $Q$ is simply


$$
Q = Q^t \otimes Q^a \otimes Q^l
$$

$Q^t$ and $Q^a$ define the precision of an AR1 process, a type of GMRF, where the elements of $Q_{i,j}$ for either $Q^t$ or $Q^a$ are as follows

$$
\begin{aligned}
Q^{AR}_{i,j} =
\begin{cases}
    \frac{1}{\sigma^2} ,& \text{if  } i = j = 0 | i = j = max(i) \\
    \frac{1 + \rho^2}{\sigma^2} ,& \text{else if  } i = j \\
    \frac{-\rho}{\sigma^2},  & \text{else if  } i \sim j \\
    0, & \text{otherwise}  
\end{cases}
 \end{aligned}
$$

where $i \sim j$ signifies two years or two age groups that are temporally adjacent to each other for $Q^t$ and $Q^a$ respectively and each matrix has its own $\sigma$ and $\rho$ henceforth referred to as $\sigma_t$, $\rho_t$, $\sigma_a$, and $\rho_a$. In this model, the $\rho$ terms represent the strength of the autocorrelation between adjacent time or age groups where 1 is perfect auto-correlation and 0 is white noise. $\sigma$ represents how much process error happens from one group to the next. Detailed explanations of AR1 models have previously been made[@rue_gaussian_2005]. The use of AR1 GMRF has been used to characterized random processes in time extensively, however, more recent studies have also used AR1 process for correlated age phenomenon as proposed in our model as well [@dwyer-lindgren_inequalities_2017].

To define the precision of the $Q^l$ matrix, we use two different modeling strategies. The more traditional epidemiological approach for modeling areal geographic units is to have the precision of geographical units follow a $lcar$ process [@lee_comparison_2011; @lawson_gaussian_2011] which has been used extensively in small area child mortality estimation [@mercer_spacetime_2015; @dwyer-lindgren_estimation_2014, @dwyer-lindgren_inequalities_2017, @dwyer-lindgren_error_2013]. The $lcar$  model defines the precision matrix such that any two spatial areas that share a border are said to be autoregressive and is parameterized by $\sigma_l$ and $\rho_l$.

The alternative model defines $Q^l$ using a two dimensional matern covariance function defining the elements of the matrix which is parameterized by $\tau_l$ and $\kappa_l$ and whose correlation function uses distance in a two dimensional space as the criteria for correlation rather than shared border[@lindgren_explicit_2011; @rue_gaussian_2005]. This GMRF precision matrix has been well studied in recent years as it has been shown to be able to be projected from a GMRF to a continuous Gaussian Field (GF) by using stochastic partial differential equations [@lindgren_explicit_2011] and has been implemented in a user-friendly format in the `R` software package `INLA` [@lindgren_bayesian_2015]. In this way we can estimate the risk surface of a continuous space rather than discrete points by accounting for the distance and correlation between the points that are sampled from the observed field. While this modeling of continuous space has most frequently been used in the field of ecology [@thorson_importance_2015; @bivand_spatial_2015], a few studies have used this technique to estimate health risk fields and, more specifically, child mortality risk [@musenge_bayesian_2013; @golding_mapping_2017]. A simulation detailed in the supplemental material shows that it is possible to estimate a continuous geographic space while jointly modeling separate correlations in time and age which to our knowledge has not been applied in the field of demography and is not currently implemented in `INLA`.

To distinguish which precision matrix used in each modeling approach use we represent $Q^l$ as $Q^{lcar}$ when using the $lcar$ precision formulation and $Q^{\mathcal{M} }$ when using the Matern formulation.

The full model parameter hierarchy then is as follows

$$
D_{l,a,t} \sim Poisson(\hat{D}_{l,a,t})
$$
$$
\hat{D}_{l,a,t} = \hat{M}_{l,a,t} * P_{l,a,t}
$$
$$
\hat{M}_{l,a,t} = exp(\beta_a + \phi_{l,a,t})
$$
$$
\phi_{l,a,t} \sim \mathcal{N}(0, Q^{-1})
$$
$$
Q = (Q^{lcar} | Q^{\mathcal{M} }) \otimes Q^a \otimes Q^t
$$
$$
Q^{lcar} = f^{lcar}(\rho_l, \sigma_l);
Q^{\mathcal{M} } = f^{\mathcal{M} }(\kappa_l, \tau_l);
Q^{a} = f^{AR1}(\rho_a, \sigma_a); Q^{t} = f^{AR1}(\rho_t, \sigma_t)
$$

In order to estimate our two models, we use a Restricted Maximum Likelihood (REML) approach and the software package TMB[@thorson_importance_2015], which uses integrated nested Laplace approximations and automatic differentiation to find the gradient of the optimization process parameter estimation[@fournier_ad_2012]. From the set of parameters $\{\mathbf{\beta}, \sigma_a, \rho_a, \sigma_t, \rho_t, \sigma_l | \tau_l, \rho_l | \kappa_l, \phi\}$ only the phi array is treated as a random effect. `R` version 3.4.0 was used for the analysis.

### Age Specific Mortality rate estimates  
Estimates of yearly age specific child mortality for each municipality in Mexico were created by running both the $Q^{lcar}$ and $Q^{\mathcal{M} }$ models kfold times, holding out kpercent of the data at random, and evaluated the out of sample negative log likelihood of the data for each model's set of parameters. We choose to use out of sample negative log likelihood approachrather than a more traditional approach of RMSE as to not bias our results towards municipalities that had much larger populations. The final set of models then used the model that produced the lowest average out of sample negative log likelihood and the full data set of observations.

### Analysis of Under 5 mortality distribution and inequality  
To assess the change in distribution of under 5 mortality in Mexican municipalities, we take the age specific rates of each year for each location from the model and calculate the municipalities estimated probability of death before age of 5 ($~_5q_{0}$). From these values, annual measures of absolute and relative inequality are calculated from the municipality distribution using the methods described in prior studies of inequality in life expectancy[@dwyer-lindgren_inequalities_2017]. This process is repeated 1000 times using draws from the covariance matrix of our final parameter estimates to create both mean and uncertainty in our measures. The difference between the measures of inequality are calculated over the time period of analysis and examined to assess whether a significant change in inequality metrics occurred between 2000 and 1015. In addition, the$~_5q_{0}$ for each municipality are taken at 2015, and each estimate is compared against the target MDG4 mortality rate of 16 deaths per 1000 live births, a crude estimate of$~_5q_{0}$. Both the mean and the 95% confidence interval of the$~_5q_{0}$ are compared against the MDG4 target and reported in our final analysis.

## Results  
Analysis of time from birth until registration showed that there was a significant amount of variability in the distribution of births at each municipality with a mean time of mean_time  and a standard deviation of sd_time. In addition to this variability there was a strong geographic correlation between the time delay of births until time to registration with a Moran's I of ttrmoransi indicative of strong positive geographic autocorrelation.

Assessing the two model variants for making estimates of yearly age specific mortality rates, $Q^{lcar}$ and $Q^{\mathcal{M} }$, we found that the $Q^{lcar}$ model performed better on average than the $Q^{\mathcal{M} }$ with out of sample negative log likelihood values of oosnlllcar and oosnllM respectively. Because the values were so similar, we ran the analysis with both sets of models and found that the average absolute difference in predicted values of yearly age specific mortality rate was extremely small (aad_u5mr_est). We proceeded to use the $Q^{lcar}$ method to produce our final result as detailed in the methods section.

Mortality rates for each municipality, single year age, and year were calculated and a full set of map visualizations for the time series may be found [here](http://krheuton-dev.ihme.washington.edu:3838/MXU5MRviz/). The analysis showed that there were strong correlations in all three demographic dimensions with values of $\rho_l$, $\rho_a$ and $\rho_t$ being rhol, rhoa, and rhot respectively. The estimated underlying mortality rate distribution of the time series, standard deviation u5mrsd, was much narrower than the observed data crude mortality rates crude. This is to be expected because of the demographic smoothing that occurs, especially in areas with small populations and observed death counts. We observe strong geographic clustering in our estimates as seen in figure 1 and when a Moran's I of estimated values in 2015 was run, the result showed significant positive spatial autocorrelation rezmoransi.

![Figure 1: Estimated Under 5 Mortality Rate 2015 ](/home/nmarquez/Documents/MXU5MR/analysis/plots/Mexicoest.png "")

Though this study was the first to estimate under 5 mortality and$~_5q_{0}$ at the municipality level within Mexico, we further assessed our results by comparing the aggregated estimates of$~_5q_{0}$ against the reported values of other major institutions. The estimated values of$~_5q_{0}$ for the aggregated 2015 national levels, model_value, were found to be similar to both United Nations estimate of UN_value [@victora_countdown_2016] and the Institute for Health Metrics and Evaluation IHME_value [@wang_global_2016] and these similarities held true for the entire time series of data. Our analysis showed that there has been a considerable drop in child mortality in Mexico, as measured here by$~_5q_{0}$, (figure 2) which is in agreement with the previous literature on the topic [@sepulveda_improvement_2006; @wang_global_2016, @victora_countdown_2016].

![Figure 2: Change In Under 5 Mortality](/home/nmarquez/Documents/MXU5MR/analysis/plots/nat5q0.jpg "")

In order to assess the critique of other similar child mortality analyses, we examined how our estimates of uncertainty in age specific mortality rates were explained by different components of the model. In figures 3 and 4 we show how the the hierarchical $Q^{lcar}$ model varies estimates of uncertainty in the mortality rate as a function of age, population size, and the mortality rate itself. In an analysis of variance where mortality rate standard deviation was the outcome we found that lmr2 of the variance in the standard deviation was explained by the level of the mortality rate, log population size, age, and number of neighbors along with their product wise interactions. The estimated mortality rate, the log population size, and their intersection explained lmr2sub alone.

![Figure 3: Mortality Estimate Uncertainty By Population Size ](/home/nmarquez/Documents/MXU5MR/analysis/plots/logpoperrors.jpg "")
![Figure 4: Mortality Estimate Uncertainty By Mortality Rate ](/home/nmarquez/Documents/MXU5MR/analysis/plots/morterrors.jpg "")

Estimates of absolute and relative inequality of$~_5q_{0}$ were calculated for all years of the study. Relative inequality and absolute inequality were found to be decreasing at significant levels, with absolute inequality decline being abineq and relative inequality decline relineq. Estimates of 2015$~_5q_{0}$ were compared against the MDG4 national target rate of 16 deaths per 1000 live births, or a crude approximate of $.016$ for$~_5q_{0}$. We found that 31% of municipalities, 782 of the 2456 municipalities in the analysis, had a mean value below the MDG4 target while only 13%, 317 municipalities, had the entirety of their 95% confidence interval below the target value. In contrast 38% of municipalities had the entirety of their confidence interval above the target value, 940 municipalities in total.

## Discussion
In this analysis we estimated on the age specific mortality rates of municipalities within Mexico as well as$~_5q_{0}$. We found that there have been significant declines in both measures of absolute and relative inequality as shown in figures 5 and 6. Despite this, less than a third of municipalities have reached the MDG4 national target rate of child mortality reduction by mean estimates and less than a quarter of the municipalities have estimates above the target with great certainty. In contrast, more than one third of the municipalities in the country has a child mortality rate significantly above the national target rate, having their entire confidence interval above the MDG4 target. This indicates that although Mexico has made great strides in reduction of their child mortality, a significant portion of the country still has not met this national goal for improved health outcomes.

![Figure 5: Relative Inequality Time Series](/home/nmarquez/Documents/MXU5MR/analysis/plots/relineqtimeseries.jpg "")
![Figure 6: Absolute Inequality Time Series](/home/nmarquez/Documents/MXU5MR/analysis/plots/absineqtimeseries.jpg "")

In addition to the widening gap in mortality rates that Mexico is experiencing, this study also highlights geographic clusters that have a significant delay from the time to birth to time to registration. Previous studies had estimated that the state of Chiapas, Mexico had less than 50% of children under 1 registered at birth in 2009[@_under-registration_2012]. Our study found significant clustering within Chiapas (figure 7) with municipalities within the state reaching average registration times of chiapas_hi_reg. This difference means that we have extremely varying knowledge base of under five population and mortality when looking at the municipality level. The strong geospatial correlation likely underly other social factors, such as socioeconomic status, proportion of population living in rural setting, and size of indigenous populations, that future analyses should focus on in order to improve the vital registration surveillance in these municipalities.

![Figure 7](/home/nmarquez/Documents/MXU5MR/analysis/plots/regisdiff.jpg "")

### Limitations
Because of the delay in birth registration that we see differentially across municipalities, we observe a smaller population than the true population for many locations. This can bias our estimates in mortality in several ways in either direction depending on if these individuals are recorded in death registries and whether they experience differential levels of mortality than the population that is recorded in the birth registry. If individuals are not recorded in birth registries but are recorded in death registries we would over-estimate the mortality of these locations because the population used in our analysis are an underestimate of the true population. If individuals are not recorded at death and experience a lower or higher rate of mortality than the recorded population, then we would be biasing our results away from the unrecorded population mean. The situation is likely the latter as unrecorded populations in most countries often experience worse health outcomes than the population covered by vital registration systems [@sepulveda_improvement_2006; @horton_new_2006; @_under-registration_2012]. For our analysis, we make the assumption that individuals are not recorded in the death records if they are not in the birth records and that they experience a similar rate of mortality as those who are recorded by the registration systems.

In addition to the lack of full coverage of vital registration, we also have estimated the age specific populations of our districts by aging populations after they are born and removing known deaths that occur. This method does not take into account migration, which is known to have an effect of child mortality estimates in Mexico [@hildebrandt_effects_2005]. While previous studies have estimated that the age specific mortality rate is much lower in under 5 age groups than young adult age groups, any change that does occur in our population due to migration would bias our results depending if there was net in or out migration. Hence, our analysis assumes that there is net zero migration in these age groups in the study period.

### Conclusion
In the years leading up to 2015 Mexico was one of a handful of countries that were on target to reach the MDG4 target of reducing under five mortality by two-thirds. Mexico was able to achieve this goal due to nationwide scale-ups of vaccinations which inevitability led to the near elimination of polio, diphtheria, and measles[@sepulveda_improvement_2006] as well as more attention to sanitation which decreased deaths due to diarrhea[@victora_countdown_2016]. Our analysis is in agreement with these findings and shows that at state and national levels Mexico has indeed seen significant declines in child mortality.

Nevertheless, while Mexico average national level mortality rates has improved our analysis highlighted the differential benefits experienced by municipalities within Mexico. In 2015, we estimated that the underlying under 5 mortality rates of municipalities within Mexico ranged from hi2015 to lo2015, which places small portion of the municipalities within Mexico at a higher rate of mortality than the baseline mortality rate for the MDG4 target in 1990.

As the field of global health expands its lens to not only include average estimates of health outcomes across nations but also the distribution of health outcomes within countries, it is important to make sure we place special emphasis on improving the health of those communities that are falling behind. Within Mexico, there has been shown to be both significant geographic clusters of under surveillance and high child mortality and in order to move forward we must target these locations in order to make the health landscape within Mexico more equitable.

## References
