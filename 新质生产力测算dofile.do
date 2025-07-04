* 广告：更多数据，百度搜索“马克数据网”

use "D:\xinzhishengchanli3.dta", clear
global positive_var gdp亿元 在岗职工工资元 第三产业就业比重 人均受教育平均年限 教育经费强度 在校学生结构 规上工业企业RD全时当量h 每百人创新企业数 电子商务交易活动企业数企业总数 机器人安装密度 森林覆盖率 环境保护支出一般财政支出 绿色专利申请数专利申请数 公路里程 铁路里程 光缆线路长度 人均互联网接入端口数 废气治理设施处理能力 专利授权数量总人口 新产品开发经费万元GDP 数字经济指数 企业数字化水平
global negative_var 化学需氧量排放GDP 二氧化硫排放GDP 能源消耗量GDP
global all_var $positive_var $negative_var
qui sum year
global min_year=r(min)
global max_year=r(max)
set trace on
forvalues year=$min_year / $max_year{
	use  "D:\xinzhishengchanli3.dta", clear
	keep if year==`year'
	foreach i in $positive_var {
		qui sum `i'
		gen x_`i'=(`i'-r(min))/(r(max)-r(min))
		replace x_`i'=0.00001 if x_`i'==0
	}
	
	foreach i in $negative_var {
		qui sum `i'
		gen x_`i'=(r(max)-`i')/(r(max)-r(min))
		replace x_`i'=0.00001 if x_`i'==0
	}

	foreach i in $all_var {
		egen `i'_sum=sum(x_`i')
		gen y_`i'=x_`i'/`i'_sum
	}

	gen n=_N

	foreach i in $all_var {
		gen y_lny_`i'=y_`i'*ln(y_`i')
	}

	foreach i in $all_var {
		egen y_lny_`i'_sum=sum(y_lny_`i')
	}

	foreach i in $all_var {
		gen E_`i'= -1/ln(n)*y_lny_`i'_sum
	}

	foreach i in $all_var {
		gen d_`i'= 1-E_`i'
	}
	
	egen d_sum = rowtotal(d_*)
	foreach i in $all_var {
		gen W_`i'= d_`i'/d_sum
	}
	
	foreach i in $all_var {
		gen Score_`i'= x_`i'*W_`i'
	}
	
	egen new_quality_forces=rowtotal(Score_*)
	keep prov year $all_var new_quality_forces W_* x_*
	save "data_`year'.dta", replace
}

clear
forvalues i=$min_year / $max_year{
   append using "data_`i'.dta"
   rm "data_`i'.dta"
}

sort prov year
keep prov year $all_var new_quality_forces 
save "entropy_result3.dta", replace




