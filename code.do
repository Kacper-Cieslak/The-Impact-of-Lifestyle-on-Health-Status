import spss country v47 v48 v49 v50 v51 AGE WRKHRS using "/Users/kacpercieslak/Desktop/mikroekonometria/model/ZA8000_v1-0-0.sav"

* Data Cleaning & Feature Engineering
*------------------------

gen to_use = !missing(v47, v48, v49, v50, v51, AGE, WRKHRS)

drop if to_use == 0

gen hours_grouped = WRKHRS

recode hours_grouped (0/20 = 1) (21/40 = 2) (41/60 = 3) (61/80 = 4) (81/100 = 5)

tab hours_grouped

* Data analysis
*------------------------
summarize, detail

* Models #1 Ordered logistic regression 
*------------------------

ologit v51 i.v47 i.v48 i.v49 i.v50 c.AGE i.hours_grouped if to_use ==1

estimates store model1

label variable _est_model1 "all variables"

ologit v51 i.v47 i.v48 i.v49 c.AGE i.hours_grouped if to_use ==1

estimates store model2

label variable _est_model2 "without v50 - fruit & vegetables"

lrtest model1 model2

* Testing model assumptions
*------------------------

estimates restore model1

brant

* Models #2 Generalized Ordered Logit
*------------------------

gologit2 v51 i.v47 i.v48 i.v49 i.v50 c.AGE i.hours_grouped, autofit

* Model evaluation
*------------------------
pwcorr v47-v50 AGE hours_grouped


fitstat

estimates restore model1

fitstat

* Classification Table

estimates restore model2

predict true1, outcome(1)
predict true2, outcome(2)
predict true3, outcome(3)
predict true4, outcome(4)
predict true5, outcome(5)

generate float max_prob =max(true1, true2, true3, true4, true5)
generate float prediction = .

replace prediction = 1 if max_prob==true1
replace prediction = 2 if max_prob==true2
replace prediction = 3 if max_prob==true3
replace prediction = 4 if max_prob==true4
replace prediction = 5 if max_prob==true5

table (v51) (prediction), stat(frequency)

*R^2
display (1330+5109+ 55+361)/15320

*adj R^2
display ((1330+5109+ 55+361) - 6210)/(15320-6210)
