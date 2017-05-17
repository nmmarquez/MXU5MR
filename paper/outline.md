###Key Points

####Question: How is Mexico achieving its under 5 mortality goals?

Findings: While National level mortality child mortality rates has been reduced
by two thirds within Mexico between 1990 and 2015 there exist a large amount of
inequity in those rates among districts

Meaning: How countries achieve MDG5 goals need to be examined such that we can
examine if communities within countries are being further marginalized.

##Abstract

####Importance
By evaluating 5q0 and child mortality at more granular levels we can begin to
asses the state of health disparities that exist within a single country

####Objective
To provide estimates of the changing under 5 mortality landscape at the district
level between 2006 and 2014 and describe how the distribution of mortality among
districts has changed over time.

####Design
Under 5 mortality count data were taken from registrations reported by
Subsistema de Información sobre Nacimientos (SINAC) and Instituto Nacional de
Estadística y Geografía (INEGI) while population data was calculated from birth
record data from each district as reported by INEGI. Mortality counts were
estimated from this data using a poisson hierarchical mixed effects regression
where the relative risk was taken as the mortality rate estimate for a given
municipality.


Outline

##Introduction  

In 2015 at the end of the tracking period of the Millennium Development goals (MDGs) the report Countdown to 2015 the publication cited that of the 75 priority countries followed by the analysis Mexico was part of the one third countries that was successful in achieving the goal of reducing under 5 mortality by two thirds [@victora_countdown_2016; @lawn_countdown_2007]. The health sector reforms and programs that have made this goal achievable [@sepulveda_improvement_2006; @king_public_2009] as well as the specific causes that have been reduced in order to meet this goal [@sepulveda_improvement_2006] have previously been documented however only a brief discussion on the within Mexico variability of under 5 mortality and its shifting distribution have been discussed [@sepulveda_improvement_2006; @wang_global_2016]. As we change paradigms of evaluation from the MDGs to the Sustainable Development Goals (SDGs) a stronger focus has been placed on equity both within and among countries. Not only should we be making progress in reducing poverty, improving health and increasing years of education but sub populations with the least access to these resources should be increasing the fastest in order to lessen the gap.

Evaluating the disparate state of health outcomes within administrative boundaries is not a new field, however, and the lack of information that we have on the topic is more of a function of data reporting and analysis. Most countries are ill equipped in terms of health reporting systems ability to provide research based findings to influence health based policies for subnational populations [@horton_new_2006]. In the absence of vital registration systems household surveys are often used to estimate health outcomes, however, how to best assess child mortality from these surveys in terms of survey development, design, and analysis for subpopulations and small geographic scale is still widely debated [@dwyer-lindgren_error_2013; @mercer_spacetime_2015; @verhulst_child_2016]. Even in countries with vital registration system their is no consensus on how to analyze subpopulations and results are often debated when they differ from the national trend [@case_rising_2015; @dwyer-lindgren_inequalities_2017]. In addition much like when analyzing survey data there is no consensus on how to analyze the data when small area estimation is of concern.

In this analysis we analyze the annual age specific mortality rates under the age of 5 at the municipality level within Mexico. Analyzing health outcomes at small geographical units can assess discrepancies in the health that are due to an unequal spatial distribution of health system resources but also can uncover discrepancies in subpopulations by class, race, and ethnicity whom tend to cluster in space [@soja_seeking_2010]. Though previous studies have examined how child mortality differs within Mexico at comprehensive level, the smallest unit of analysis has only been at the state level within Mexico [@sepulveda_improvement_2006; @wang_global_2016]. In more recent studies of inequality in mortality in the United States [@dwyer-lindgren_inequalities_2017], analysis has shown that state level analysis can mask inequalities that are geographically correlated at more detailed levels. In addition to this the quality of the vital registration system in Mexico has been praised in terms of being able to accurately identify cause of death [@morris_predicting_2003; @mahapatra_civil_2007] but the coverage of the system has been examined less in terms of documenting those who are living in poorer rural geographies [@_under-registration_2012].

This analysis of municipality level mortality in Mexico has four areas of novel analysis and scientific contribution. First we will assess the geographic distribution of quality of vital registration coverage by assessing the municipality distribution of time from birth till registration. Second, we present a novel method for estimating small area child mortality rate which accounts for geographic proximity. Third, we apply this methodology and compare its results to other more traditional models. Fourth, we asses our models estimate of geographic distribution by assessing the geographic correlation in predicted mortality rates along with how the inequities in under five mortality have evolved, either diminishing, strengthening, or stagnating, over the course of the study period.

## Methods  

### Data  
De-identified person level data was extracted from INEGI and SINAC vital registration reports for the years {year_start} to {year_end} for birth records. Of the {number_of_birth_records} birth records that were extracted  {muni_birthp} had a place of living municipality that was associated with the birth. The records that did not have a municipality associated with them were approximately evenly distributed across states and were discarded from the analysis. Death registration data was extracted from person level de-identified INEGI reports where place of living municipality was recorded, year of occurrence was given, and age of individual given by single year was provided. Of the {n_u5_deaths} deaths that were reported as under the age of 5, {p_u5_deaths} had values for single year age, single year time, and municipality that were valid. Since data was not linked by person and single year populations by single year age and municipality were not available in other data sources populations were estimated by taking the births of individuals for a particular municipality age and moving them one year forward in age as calendar year progressed while also subtracting off the deaths for that population. The formula is as follows

$$
P_{a,t} = P_{a-1,t-1} - D_{a-1,t-1}
$$

where $P$ is population number, $D$ is death number, $a$ is a single year age, and $t$ is a single year time period. This method assumes net zero migration for all demographic units which will have an effect on the mortality rate estimates depending on if net migration is above or below zero [@hildebrandt_effects_2005].

### Analysis of time till birth registration.  
Each person level birth record data point which had a year of birth also included a year of registration. For each record we calculate the difference from the year of birth till the year of registration and assign the difference to its municipality of residence. The mean time of registration from birth for each district was calculated. In order to assess the degree of geospatial correlation that exists in these differences of registration time a Moran's I assessment is run.

### Modeling Strategies  
In order to estimate the underlying mortality rate of municipalities within Mexico, especially in areas where observed populations are small, our modeling approach borrows strength across dimensions of geography, age, and time in order to disentangle the true underlying mortality rate from the process error that is observed. This smoothing process is used extensively in demographic forecasting and small area estimation in order to draw predictive power from observations that are correlated and not underestimate the standard error of fixed effects[@girosi_demographic_2008, @banerjee_hierarchical_2003, @hodges_adding_2010, @currie_smoothing_2004]. The functional form of the model is as follows  

$$
D_{l,a,t} \sim Poisson(\hat{D}_{l,a,t})
$$
$$
\hat{D}_{l,a,t} = exp(\beta_a + \phi_{l,a,t}) * P_{l,a,t}
$$

where $l$ is a municipality and $\phi$ is a random effect term which is specific to a particular municipality, single year age, and single year time, and the other notations remain as previously specified. The $\phi$ term follows a a multivariate normal distribution with covariance matrix $Q^{-1}$ where $Q$ is the precision matrix of the multivariate normal process. For our model, it may also be stated that $\phi$ exhibits behavior of a Gaussian Markov Random Field (GMRF) as each demographic unit of $\phi$ is modeled as conditionally independent from other points which it does not share a border with. This can otherwise be stated as

$$
Q_{x,y} = 0  \iff {u,v} \not\subset E
$$

$Q$ can be shown to be a GMRF because it is formed by taking the Kronecker product of three well defined GMRFs and the property that the Kronecker product of a set of GMRFs is itself a GMRF [@rue_gaussian_2005]. The three precision matrices that define $Q$ are $Q^t$, $Q^a$, and $Q^l$ which parameterize the correlations that exist between units of time, age, and geography respectively. It can then be seen that $Q$ is simply


$$
Q = Q^t \otimes Q^a \otimes Q^l
$$

$Q^t$ and $Q^a$ define the precision of a AR1 process, a type of GMRF, where the elements of $Q_{i,j}$ for either $Q^t$ or $Q^a$ are as follows of

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

where $i \sim j$ signifies two years or two age groups that are temporally adjacent to each other for $Q^t$ and $Q^a$ respectively and each matrix has its own $\sigma$ and $\rho$ henceforth referred to as $\sigma_t$, $\rho_t$, $\sigma_a$, and $\rho_a$. In this model the $rho$ terms represent the strength of the autocorrelation between adjacent time or age groups where 1 is perfect auto-correlation and 0 is white noise. Sigma represents how much process error happens from one group to the next.

In order to define the precision of the $Q^l$ matrix we use two different modeling strategies. The more traditional epidemiological approach for modeling areal geographic units is to have the precision of geographical units follow a $lcar$ process [@lee_comparison_2011; @lawson_gaussian_2011] which has been used extensively in small area child mortality estimation [@mercer_spacetime_2015; @dwyer-lindgren_estimation_2014, @dwyer-lindgren_inequalities_2017, @dwyer-lindgren_error_2013]. The $lcar$  model defines the precision matrix such that any two spatial areas that share a border are said to be autoregressive and is parameterized by $\sigma_l$ and $\rho_l$. Though most studies have limited their analysis to only taking into account spatial and temporal effects more recent studies have begun to take into account the modeling of simultaneous age correlations as well [@dwyer-lindgren_inequalities_2017].  

The alternative model defines $Q^l$ using a two dimensional matern covariance function defining the elements of the matrix  which is parameterized by $\tau_l$ and $\kappa_l$[@lindgren_explicit_2011; @rue_gaussian_2005]. This GMRF precision matrix has been well studied in recent years as it has been show to be able to be projected from a GMRF to a continuous Gaussian Field (GF) by using stochastic partial differential equations [@lindgren_explicit_2011] and has been implemented for user friendly use in the `R` software package `INLA` [@lindgren_bayesian_2015]. In this way we can estimate the risk surface of a continuous space rather than discrete points by accounting for the distance and correlation between the points that are sampled from the observed field. While this modeling of continuous space has more often been used in the field of ecology [@thorson_importance_2015; @bivand_spatial_2015] more recent studies have used this technique in order to estimate health risk fields and more specifically child mortality risk [@musenge_bayesian_2013; @golding_mapping_2017]. While our analysis will not try and estimate a continuous space a simulation detailed in the supplemental material shows that it is possible to estimate a continuous geographic space while jointly modeling separate correlation in time and age which to our knowledge has not been applied in the field of demography and is not currently implemented in `INLA`.

In order to distinguish which precision matrix used in each modeling approach use we will represent $Q^l$ as $Q^{lcar}$ when using the $lcar$ precision formulation and $Q^{\mathcal{M}}$ when using the Matern formulation.

In order to estimate our two models we will use a Restricted Maximum Likelihood (REML) approach and the software package TMB [@thorson_importance_2015] which uses integrated nested Laplace approximations and automatic differentiation to find the gradient of the optimization process for fixed effects [@fournier_ad_2012]. From the set of parameters ${\mathbf{\beta}, \sigma_a, \rho_a, \sigma_t, \rho_t, \sigma_l | \tau_l, \rho_l | \kappa_l, \phi}$ only the phi array is treated as a random effect. `R` version 3.4.0 was used for the analysis.

### Age Specific Mortality rate estimates  
In order to make estimates of yearly age specific child mortality for each municipality in Mexico we ran both the $Q^{lcar}$ and $Q^{\mathcal{M}}$ models {kfold} times holding out {kpercent} of the data at random and evaluated the out of sample negative log likelihood of the data for each model. The final set of models then used the model which produced the lowest average out of sample negative log likelihood and the full data set of observations.  

### Analysis of Under 5 mortality inequality  
In order to asses the change in distribution of under 5 mortality in Mexican municipalities we take the age specific rates of each year for each location and calculate the municipalities $\_5q_0$, the probability of death before age 5. From these values, annual measures of absolute and relative inequality are calculated from the municipality distribution. This process is repeated 1000 times using draws from the covariance matrix of our final parameter estimates in order to assess the uncertainty of the measures.

## Results  
