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
