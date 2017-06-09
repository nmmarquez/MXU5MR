###Key Points

####Question: How is Mexico achieving its under 5 mortality goals?

Findings: While National level child mortality rates have been reduced by two-thirds within Mexico between 1990 and 2015, a large amount of inequity in those rates among municipalities.

Meaning: The improving state of health within Mexico has been experienced differentially by municipalities with some locations having mortality rates similar to the national level values reported in 1990. Improving health access to these marginalized municipalities and reducing health inequalities should be a focus of future health planning.

##Abstract

####Importance
By evaluating child mortality at more granular levels we can begin to assess the state of health disparities that exist within a single country.

####Objective
To provide estimates of the changing under 5 mortality landscape at the district level between 2006 and 2014 and describe how the distribution of mortality rates among districts has changed over time.

####Design
Under 5 mortality count data were taken from registrations reported by Subsistema de Información sobre Nacimientos (SINAC) and Instituto Nacional de Estadística y Geografía (INEGI) while population data was calculated from birth record data from each district as reported by INEGI. Mortality counts were estimated from this data using a poisson hierarchical mixed effects regression where the relative risk was used as the mortality rate estimate for a given municipality.

##Introduction  

In 2015 at the end of the tracking period for the Millennium Development Goals (MDGs) the report Countdown to 2015,released by the World Health Organization, stated that, of the 75 priority countries followed by an ongoing analysis of child mortality monitoring, Mexico was one of twenty five countries that successfully achieved the goal of reducing under 5 mortality by two thirds [@victora_countdown_2016]. The health sector reforms and programs that helped achieve this goal [@sepulveda_improvement_2006; @king_public_2009] as well as the specific causes of mortality that were reduced [@sepulveda_improvement_2006] have previously been documented, however, little is known about the within Mexico variability of under 5 mortality and its shifting distribution[@sepulveda_improvement_2006; @wang_global_2016]. As we change paradigms of evaluation from the MDGs to the Sustainable Development Goals (SDGs) a stronger focus has been placed on equity both within and among countries. Not only should we be making progress in reducing poverty, improving health, and increasing years of education but sub populations with the least access to these resources should be prioritized in order to lessen the gap.

Evaluating the disparate state of health outcomes within administrative boundaries is not a new field, however, and the lack of available information relevant to the topic  is predominately a function of lack of data reporting. Most countries are ill-equipped in terms of their health reporting systems's ability to provide analytical evidence that can influence health-based policies for subnational populations [@horton_new_2006]. In the absence of vital registration systems, household surveys are often used to estimate health outcomes; however, how to best assess child mortality from these surveys in terms of survey development, design, and analysis for subpopulations at a small geographic scale is still widely debated [@dwyer-lindgren_error_2013; @mercer_spacetime_2015; @verhulst_child_2016]. Even in countries with near complete vital registration systems, there is little consensus on how to analyze subpopulations, and results are often questioned when they differ from the national trend [@case_rising_2015; @dwyer-lindgren_inequalities_2017]. In addition, much like when analyzing survey data, there is no consensus on how to analyze the data when small area estimation is of concern.

In this paper we analyze the annual age specific mortality rates under the age of 5 at the municipality level within Mexico. Analyzing health outcomes at small geographical units can identify discrepancies in health that are due to an unequal spatial distribution of health system resources, but also can uncover discrepancies in subpopulations that tend to cluster in space, such as class, race, and ethnicity [@soja_seeking_2010]. Though previous studies have examined how child mortality differs within Mexico, the smallest unit of analysis has only been at the state level[@sepulveda_improvement_2006; @wang_global_2016]. In more recent studies of inequality in mortality rates in the United States [@dwyer-lindgren_inequalities_2017], analyses have shown that state level analysis can mask inequalities that are geographically correlated at more detailed levels. In addition, the quality of the vital registration system in Mexico has been praised for its ability to accurately identify cause of death[@morris_predicting_2003; @mahapatra_civil_2007], but the coverage of the system has been examined less thoroughly in terms of documenting those who are living in poorer rural geographies [@_under-registration_2012]. This lack of coverage may bias results of mortality estimates such that they deviate away from unobserved populations who likely have a very different health profile than those who are observed. In order to assess the extent to which this bias exists, we will estimate the time until registration from birth for each documented birth in Mexico.

By examining how the distribution of mortality changes, we intend to describe how Mexico has shifted its mortality burden distribution at the municipality level. A lowering of the mortality rates is not necessarily correlated with increases or decreases in the relative or absolute inequality of the burden. By measuring both relative and absolute inequality at the start and end of our longitudinal analysis, we intend to highlight one of three scenarios by which Mexico has reduced national mortality rates. As shown in figure 1, the distribution can shift from the 1990 under 5 mortality rate of 48 children per 1000 live births to the target rate of 16 children per 1000 live births in several ways. In scenario 1 both the skew and the variance of the municipality distribution is decreasing, which leads to lower absolute and relative inequality. Scenario 2 shows an instance where skew remains constant and variance decreases, which leads to a decrease in absolute inequality but increase in relative inequality. While arguments can be made for either of these scenarios to be the target distribution of our mortality outcomes, the distribution we wish to avoid is scenario 3, where we have increases in skew and variance which lead to increases in relative and absolute inequality.

![Figure 1](/home/nmarquez/Documents/Classes/statdemog/week2/comparemig.jpg "")  

This analysis of municipality level mortality in Mexico has four areas of novel analysis and scientific contribution. First we will assess the geographic distribution of quality of vital registration coverage by assessing the municipality distribution of time from birth till registration. Second, we present a novel method for estimating small area child mortality rate which accounts for geographic proximity. Third, we apply this methodology and compare its results to other more traditional models. Fourth, we assessour models estimate of geographic distribution by assessing the geographic correlation in predicted mortality rates along with how the inequities in under five mortality have evolved, either diminishing, strengthening, or stagnating, over the course of the study period.

## Methods  

### Data  
De-identified person level data was extracted from INEGI and SINAC vital registration reports for the years year_start to year_end for birth records. Of the number_of_birth_records birth records that were extracted muni_birthp had a properly identified household location of parents that was used as the geolocation for this analysis. The records that did not have a municipality associated with them were approximately evenly distributed across states and were discarded from the analysis. Death registration data was extracted from person level de-identified INEGI reports where municipality of residence, year of occurrence, and age of individual given by single year was used provided that information existed for the death record. Of the n_u5_deaths deaths that were reported as under the age of 5, p_u5_deaths had values for year, age, and municipality that were valid. Since data was not linked by person and single year populations by single year age and municipality were not available in other data sources, populations were estimated by taking the births of individuals for a particular municipality age and moving them one year forward in age as calendar year progressed, while also subtracting the deaths for that population. The formula is as follows where $P$ is population number, $D$ is death number, $a$ is a single year age, $t$ is a single year time period, and $l$ is a municipality.

$$
P_{l,a,t} = P_{l,a-1,t-1} - D_{l,a-1,t-1}
$$

This method assumes net zero migration for all demographic units.

### Analysis of time till birth registration.  
Each person level birth record data point which had a year of birth also included a year of registration. For each record we calculate the difference between the year of birth and the year of registration and assign the difference to its municipality of residence. The mean time of registration from birth for each district was calculated. In order to assess the degree of geospatial correlation that exists in these differences, a Moran's I test is run.

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

In order to define the precision of the $Q^l$ matrix, we use two different modeling strategies. The more traditional epidemiological approach for modeling areal geographic units is to have the precision of geographical units follow a $lcar$ process [@lee_comparison_2011; @lawson_gaussian_2011] which has been used extensively in small area child mortality estimation [@mercer_spacetime_2015; @dwyer-lindgren_estimation_2014, @dwyer-lindgren_inequalities_2017, @dwyer-lindgren_error_2013]. The $lcar$  model defines the precision matrix such that any two spatial areas that share a border are said to be autoregressive and is parameterized by $\sigma_l$ and $\rho_l$.

The alternative model defines $Q^l$ using a two dimensional matern covariance function defining the elements of the matrix which is parameterized by $\tau_l$ and $\kappa_l$ and whose correlation function uses distance in a two dimensional space as the criteria for correlation rather than shared border[@lindgren_explicit_2011; @rue_gaussian_2005]. This GMRF precision matrix has been well studied in recent years as it has been shown to be able to be projected from a GMRF to a continuous Gaussian Field (GF) by using stochastic partial differential equations [@lindgren_explicit_2011] and has been implemented in a user-friendly format in the `R` software package `INLA` [@lindgren_bayesian_2015]. In this way we can estimate the risk surface of a continuous space rather than discrete points by accounting for the distance and correlation between the points that are sampled from the observed field. While this modeling of continuous space has most frequently been used in the field of ecology [@thorson_importance_2015; @bivand_spatial_2015], a few studies have used this technique to estimate health risk fields and, more specifically, child mortality risk [@musenge_bayesian_2013; @golding_mapping_2017]. A simulation detailed in the supplemental material shows that it is possible to estimate a continuous geographic space while jointly modeling separate correlations in time and age which to our knowledge has not been applied in the field of demography and is not currently implemented in `INLA`.

In order to distinguish which precision matrix used in each modeling approach use we represent $Q^l$ as $Q^{lcar}$ when using the $lcar$ precision formulation and $Q^{\mathcal{M} }$ when using the Matern formulation.

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
In order to make estimates of yearly age specific child mortality for each municipality in Mexico, we ran both the $Q^{lcar}$ and $Q^{\mathcal{M} }$ models kfold times holding out kpercent of the data at random, and evaluated the out of sample negative log likelihood of the data for each model. The final set of models then used the model that produced the lowest average out of sample negative log likelihood and the full data set of observations.  

### Analysis of Under 5 mortality inequality  
In order to assess the change in distribution of under 5 mortality in Mexican municipalities, we take the age specific rates of each year for each location from the model and calculate the municipalities estimated probability of death before age of 5,$~_5q_{0}$. From these values, annual measures of absolute and relative inequality are calculated from the municipality distribution using the methods described in prior studies of inequality in life expectancy[@dwyer-lindgren_inequalities_2017]. This process is repeated 1000 times using draws from the covariance matrix of our final parameter estimates in order to assess the uncertainty of the measures. The difference between the measures of inequality are calculated over the time period of analysis in order to assess whether a significant change in inequality metrics exists. In addition, the underlying mortality rate values for each municipality are taken at 2015, and each estimate is compared against the target MDG4 mortality rate of 16 for both the means and the 95% confidence interval of the mortality rate.

## Results  
Analysis of time from birth until registration showed that there was a significant amount of variability in the distribution of births at each municipality mean_time sd_time. In addition to this variability there was a strong geographic correlation between the time delay of births until time to registration with a Moran's I of ttrmoransi.

Assessing the two model variants for making estimates of yearly age specific mortality rates, $Q^{lcar}$ and $Q^{\mathcal{M} }$, we found that the $Q^{lcar}$ model performed better on average than the $Q^{\mathcal{M} }$ with out of sample negative log likelihood values of oosnlllcar and oosnllM respectively. Because the values were so similar, we ran the analysis with both sets of models and found that the average absolute difference in predicted values of yearly age specific mortality rate was extremely small aad_u5mr_est. We proceeded to use the $Q^{lcar}$ method to produce our final result as detailed in the methods section.

Mortality rates for each municipality, single year age, and year were calculated
and a full set of map visualizations for the time series may be found [here](http://krheuton-dev.ihme.washington.edu:3838/MXU5MRviz/). The analysis showed that there were strong correlations in all three demographic dimensions with values of $\rho_l$, $\rho_a$ and $\rho_t$ being rhol, rhoa, and rhot respectively. The estimated underlying mortality rate distribution of the time series, standard deviation u5mrsd, was much narrower than the observed data crude mortality rates crude. This is to be expected because outlier and small area observations are smoothed over in our hierarchical model. Despite this we still see strong geographic clustering in our estimates as seen in figure 2 and the Moran's I of estimated values in 2015 rezmoransi.

![Figure 2](/home/nmarquez/Documents/Classes/statdemog/week2/comparemig.jpg "")

The estimated values of$~_5q_{0}$ for the aggregated 2015 national levels, model_value, were found to be similar to both United Nations estimate of UN_value [@victora_countdown_2016] and the Institute for Health Metrics and Evaluation IHME_value. The comparison between our estimates and the yearly estimates for both these sources as well as the state level$~_5q_{0}$ values for the time series can be found in the appendix.

In order to assess the critique of other similar child mortality analyses, we examined how our estimates of uncertainty in age specific mortality rates were explained by different components of the model. In figures 3 and 4 we show how the the hierarchical $Q^{lcar}$ model varies estimates of uncertainty in the mortality rate as a function of age, population size, and the mortality rate itself. In an analysis of variance where mortality rate standard deviation was the outcome we found that lmr2 of the variance in the standard deviation was explained by the level of the mortality rate, log population size, age, and number of neighbors along with their product wise interactions. The estimated mortality rate, the log population size, and their intersection explained lmr2sub alone.

![Figure 3](/home/nmarquez/Documents/Classes/statdemog/week2/comparemig.jpg "")
![Figure 4](/home/nmarquez/Documents/Classes/statdemog/week2/comparemig.jpg "")

Estimates of absolute and relative inequality of$~_5q_{0}$ were calculated for all years of the study. Relative inequality and absolute inequality were found to be decreasing at significant levels, absolute inequality decline abineq and relative inequality decline relineq.

## Discussion
In this analysis we showed that there has been an increase in the relative inequality of under five mortality in Mexico by district from year_start to year_end. This outcome increases the variance and the skew of the mortality rate distribution. The estimated parameter values of relative and absolute mortality are shown in figure 5. This widening gap of within country mortality rates as national rates decrease is not a new phenomena as previous studies have shown similar outcomes in probability of death in the United States by county[@dwyer-lindgren_inequalities_2017]. This widening gap highlights how subpopulations, namely different municipalities, have differentially benefited from the decreasing levels of mortality in Mexico.

![Figure 5](/home/nmarquez/Documents/Classes/statdemog/week2/comparemig.jpg "")

In addition to the widening gap in mortality rates that Mexico is experiencing, this study also highlights geographic clusters that have a significant delay from the time to birth to time to registration. Previous studies had estimated that the state of Chiapas, Mexico had less than 50% of children under 1 registered at birth in 2009[@_under-registration_2012]. Our study found significant clustering within Chiapas (figure 6) with municipalities within the state reaching average registration times of chiapas_hi_reg. This difference means that we have extremely varying knowledge base of under five population and mortality when looking at the municipality level. The strong geospatial correlation likely underly other social factors, such as socioeconomic status, proportion of population living in rural setting, and size of indigenous populations, that future analyses should focus on in order to improve the vital registration surveillance in these municipalities.

![Figure 6](/home/nmarquez/Documents/Classes/statdemog/week2/comparemig.jpg "") 

### Limitations
Because of the delay in birth registration that we see differentially across municipalities, we observe a smaller population than the true population for many locations. This can bias our estimates in mortality in several ways in either direction depending on if these individuals are recorded in death registries and whether they experience differential levels of mortality than the population that is recorded in the birth registry. If individuals are not recorded in birth registries but are recorded in death registries we would over-estimate the mortality of these locations because the population used in our analysis are an underestimate of the true population. If individuals are not recorded at death and experience a lower or higher rate of mortality than the recorded population, then we would be biasing our results away from the unrecorded population mean. The situation is likely the latter as unrecorded populations in most countries often experience worse health outcomes than the population covered by vital registration systems [@sepulveda_improvement_2006; @horton_new_2006; @_under-registration_2012]. For our analysis, we make the assumption that individuals are not recorded in the death records if they are not in the birth records and that they experience a similar rate of mortality as those who are recorded by the registration systems.

In addition to the lack of full coverage of vital registration, we also have estimated the age specific populations of our districts by aging populations after they are born and removing known deaths that occur. This method does not take into account migration, which is known to have an effect of child mortality estimates in Mexico [@hildebrandt_effects_2005]. While previous studies have estimated that the age specific mortality rate is much lower in under 5 age groups than young adult age groups, any change that does occur in our population due to migration would bias our results depending if there was net in or out migration. Hence, our analysis assumes that there is net zero migration in these age groups in the study period.

### Conclusion
In the years leading up to 2015 Mexico was one of a handful of countries that were on target to reach the MDG4 target of reducing under five mortality by two-thirds. Mexico was able to achieve this goal due to nationwide scale-ups of vaccinations which inevitability led to the near elimination of polio, diphtheria, and measles[@sepulveda_improvement_2006] as well as more attention to sanitation which decreased deaths due to diarrhea[@victora_countdown_2016]. Our analysis is in agreement with these findings and shows that at state and national levels Mexico has indeed seen significant declines.

While Mexico average national level mortality rates has improved our analysis highlighted the differential benefits experienced by municipalities within Mexico. In 2015, we estimated that the underlying under 5 mortality rates of municipalities within Mexico ranged from hi2015 to lo2015 which significantly increased the relative inequity of child mortality distribution within the country.

This finding leaves Mexico in an interesting position to be b0th a role model for obtaining goals set in the MDGs and SDGs. Mexico was lauded for it's dramatic improvements in child health outcomes between 1990 and 2015 [@sepulveda_improvement_2006, @victora_countdown_2016] and now as the SDGs shift towards reducing inequalities within populations and the focus on health as a human right, Mexico has room to be a leader in this regard as well, especially as neighboring countries such as the United States look to improve their disparities in mortality and health outcomes.

## References
