*! eba version 1.2 GI 20June1988 , 22July1988
*! gimpavido@worldbank.org
* Extreme Bound Analysis

program define eba
version 5.0
local varlist "required existing min(3)"
local if "optional"
local in "optional"
local options /*
*/ "Detail X(string) TYpe(int 1) LEvel(real .95) CI(real .95) VIF(real 10000)"
parse "`*'"

/* This creates the dependent variable, the eba variable and the Z vars */
parse "`varlist'", parse(" ")
local depvar "`1'"
mac shift
local ebavar "`1'"
mac shift
local z "`*'"

local S_nz : word count `z'
if `type' > 4 {
	di in red "EBA with combination of more than " in ye "4 " in red /*
	*/ "variables is not supported." 
	exit 198 
	}
if `S_nz' < `type' {
	di in red "Program expects at least " in ye `type' in re " Z variables"
	exit 198 
	}

local i "1"
while "`1'" ~= "" {
	tempvar z`i'
	quietly { gen `z`i'' = `1' }
	macro shift
	local i = `i' + 1
	}

/* This takes care of possible repeated regressors (X variables) */
if "`x'" ~= "" {
	unabbrev `x'
	local x "$S_1"
	}

local min_b . 
local max_b "-10000000"

/* EBA when type==1 */
local i "1"
while `i' <= `S_nz' { 
if `type'==1 {
	quietly fit `depvar' `ebavar' `x' `z`i'' `if' `in'
	
	quietly vif
	local m_vif "$S_1"

	if "`detail'"=="detail" {
		di in gr "z`i'" , in ye _result(1) , `m_vif' , _b[`ebavar'] , /*
		*/ _b[`ebavar']/_se[`ebavar'] , tprob(_result(5), /*
		*/ _b[`ebavar']/_se[`ebavar'])
		}

	if `m_vif' <= `vif' {

	if  tprob(_result(5), _b[`ebavar']/_se[`ebavar']) <= 1 - `level' {
	
		if _b[`ebavar'] < `min_b' {
			local min_z "z`i'"
			local min_b = _b[`ebavar'] 
			local min_obs = _result(1) 
			local min_t = _b[`ebavar']/_se[`ebavar'] 
			local min_p = tprob(_result(5), _b[`ebavar']/_se[`ebavar'])
			local min_c1 = `min_b' - invt(_result(5), `ci')*_se[`ebavar']
			local min_c2 = `min_b' + invt(_result(5), `ci')*_se[`ebavar']
			local min_vif = `m_vif'
			}
		
		if _b[`ebavar'] > `max_b' {
			local max_b = _b[`ebavar'] 
			local max_obs= _result(1) 
			local max_z "z`i'"
			local max_t = _b[`ebavar']/_se[`ebavar'] 
			local max_p = tprob(_result(5), _b[`ebavar']/_se[`ebavar'])
			local max_c1 = `max_b' - invt(_result(5), `ci')*_se[`ebavar']
			local max_c2 = `max_b' + invt(_result(5), `ci')*_se[`ebavar']
			local max_vif = `m_vif'
			}
		} /* This is the level closure */
		} /* This is the vif closure */
	}

/* EBA when type==2 */
if `type'==2 {
	local j = `i'+1
	while `j'<=`S_nz' {
	quietly fit `depvar' `ebavar' `x' `z`i'' `z`j'' `if' `in'
	
	quietly vif
	local m_vif "$S_1"

	if "`detail'"=="detail" {
		di in gr "z`i'" , "z`j'" , in ye _result(1) , `m_vif' , /*
		*/ _b[`ebavar'] , _b[`ebavar']/_se[`ebavar'] , /*
		*/ tprob(_result(5) , _b[`ebavar']/_se[`ebavar'])
		}

	if `m_vif' <= `vif' {

	if  tprob(_result(5), _b[`ebavar']/_se[`ebavar']) <= 1 - `level' {
	
	if _b[`ebavar'] < `min_b' {
			local min_z "z`i' z`j'"
			local min_b = _b[`ebavar'] 
			local min_obs = _result(1) 
			local min_t = _b[`ebavar']/_se[`ebavar'] 
			local min_p = tprob(_result(5), _b[`ebavar']/_se[`ebavar'])
			local min_c1 = `min_b' - invt(_result(5), `ci')*_se[`ebavar']
			local min_c2 = `min_b' + invt(_result(5), `ci')*_se[`ebavar']
			local min_vif = `m_vif'
			}

	if _b[`ebavar'] > `max_b' {
			local max_z "z`i' z`j'"
			local max_b = _b[`ebavar'] 
			local max_obs= _result(1) 
			local max_t = _b[`ebavar']/_se[`ebavar'] 
			local max_p = tprob(_result(5), _b[`ebavar']/_se[`ebavar'])
			local max_c1 = `max_b' - invt(_result(5), `ci')*_se[`ebavar']
			local max_c2 = `max_b' + invt(_result(5), `ci')*_se[`ebavar']
			local max_vif = `m_vif'
			}
		}
		} /* This is the vif closure */
	local j = `j'+1
	}
	}


/* EBA when type==3 */
if `type'==3 {
	local j = `i'+1
	while `j'<=`S_nz' {
	local k = `j' + 1
	while `k' <= `S_nz' {
	quietly fit `depvar' `ebavar' `x' `z`i'' `z`j'' `z`k'' `if' `in'
	
	quietly vif
	local m_vif "$S_1"

	if "`detail'"=="detail" {
	di in gr "z`i'" , "z`j'" , "z`k'" , in ye _result(1) , `m_vif' , /*
	*/ in ye _b[`ebavar'] , _b[`ebavar']/_se[`ebavar'] , /*
	*/ tprob(_result(5) , _b[`ebavar']/_se[`ebavar'])
	}

	if `m_vif' <= `vif' {

	if  tprob(_result(5), _b[`ebavar']/_se[`ebavar']) <= 1 - `level' {
	
	if _b[`ebavar'] < `min_b' {
			local min_z "z`i' z`j' z`k'"
			local min_b = _b[`ebavar'] 
			local min_obs = _result(1) 
			local min_t = _b[`ebavar']/_se[`ebavar'] 
			local min_p = tprob(_result(5), _b[`ebavar']/_se[`ebavar'])
			local min_c1 = `min_b' - invt(_result(5), `ci')*_se[`ebavar']
			local min_c2 = `min_b' + invt(_result(5), `ci')*_se[`ebavar']
			local min_vif = `m_vif'
			}

	if _b[`ebavar'] > `max_b' {
			local max_z "z`i' z`j' z`k'"
			local max_b = _b[`ebavar'] 
			local max_obs= _result(1) 
			local max_t = _b[`ebavar']/_se[`ebavar'] 
			local max_p = tprob(_result(5), _b[`ebavar']/_se[`ebavar'])
			local max_c1 = `max_b' - invt(_result(5), `ci')*_se[`ebavar']
			local max_c2 = `max_b' + invt(_result(5), `ci')*_se[`ebavar']
			local max_vif = `m_vif'
			}
		}
		} /* This is the vif closure */
	local k = `k' + 1
	}
	local j = `j'+ 1
	}
	}


/* EBA when type==4 */
if `type'==4 {
	local j = `i'+1
	while `j'<=`S_nz' {
	local k = `j' + 1
	while `k' <= `S_nz' {
	local i1 = `k' + 1
	while `i1' <= `S_nz' {
	quietly fit `depvar' `ebavar' `x' `z`i'' `z`j'' `z`k'' `z`i1'' `if' `in'
	
	quietly vif
	local m_vif "$S_1"

	if "`detail'"=="detail" {
	di in gr "z`i'" , "z`j'" , "z`k'" , "z`i1'" , in ye _result(1) , /*
	*/ `m_vif' , _b[`ebavar'] , _b[`ebavar']/_se[`ebavar'] , /*
	*/ tprob(_result(5), _b[`ebavar']/_se[`ebavar'])
	}

	if `m_vif' <= `vif' {

	if  tprob(_result(5), _b[`ebavar']/_se[`ebavar']) <= 1 - `level' {
	
	if _b[`ebavar'] < `min_b' {
			local min_z "z`i' z`j' z`k' z`i1'"
			local min_b = _b[`ebavar']
			local min_obs = _result(1) 
			local min_t = _b[`ebavar']/_se[`ebavar'] 
			local min_p = tprob(_result(5), _b[`ebavar']/_se[`ebavar'])
			local min_c1 = `min_b' - invt(_result(5), `ci')*_se[`ebavar']
			local min_c2 = `min_b' + invt(_result(5), `ci')*_se[`ebavar']
			local min_vif = `m_vif'
			}

	if _b[`ebavar'] > `max_b' { 
			local max_z "z`i' z`j' z`k' z`i1'"
			local max_b = _b[`ebavar'] 
			local max_obs= _result(1) 
			local max_t = _b[`ebavar']/_se[`ebavar'] 
			local max_p = tprob(_result(5), _b[`ebavar']/_se[`ebavar'])
			local max_c1 = `max_b' - invt(_result(5), `ci')*_se[`ebavar']
			local max_c2 = `max_b' + invt(_result(5), `ci')*_se[`ebavar']
			local max_vif = `m_vif'
			}
		}
		} /* This is the vif closure */
	local i1 = `i1' + 1
	}
	local k = `k' + 1
	}
	local j = `j'+ 1
	}
	}
local i = `i' + 1
}



/* Display of output */

di _n in gr "Result of EBA on " in ye "`ebavar'" in gr " at " /*
	*/ in ye "`level'" in gr " confidence level and maximum VIF = " /*
	*/ in ye "`vif'"
di _n in gr "Dvar" _col(6) "= " in ye "`depvar'"  
di in gr "X" _col(6) "= [" in ye "`x'" in gr "]"
di in gr "Z" _col(6) "= [" in ye "`z'" in gr "]"
di ""

if `min_b'==. {
	di in red	"No bounds found at the suggested confidence level "
	di in red "and/or maximum VIF."
	di in gr	"Try relaxing the constraints in the " in wh "level(#) " /*
	*/ in gr "and/or " in wh "vif(#) " in gr "options."
	}

di in gr _skip(8) "beta" _skip(9) "t" _skip(6) "p-val" _skip(8) /*
	*/ in ye `ci' in gr " C.I." _skip(8) "VIF" _skip(4) "Zs" 

di in gr "-----|" _dup(2) "---------|" _dup(1) "--------|" /*
	*/ _dup(2) "---------|" _dup(23) "-"

di in gr _skip(1) "min" in ye %9.4f _col(6) `min_b' %9.4f _skip(1) `min_t' /*
	*/ _skip(0) %9.4f `min_p' _skip(1) %9.4f `min_c1' _skip(1) %9.4f /*
	*/ `min_c2' _skip(1) in ye %8.2f `min_vif' /*
	*/ _skip(2) in gr "[" in ye "`min_z'" in gr "]"

di in gr _skip(1) "Max" in ye %9.4f _col(6) `max_b' %9.4f _skip(1) `max_t' /*
	*/ _skip(0) %9.4f `max_p' _skip(1) %9.4f `max_c1' _skip(1) %9.4f /*
	*/ `max_c2' _skip(1) in ye %8.2f `max_vif' /*
	*/ _skip(2) in gr "[" in ye "`max_z'" in gr "]"

di in gr _dup(78) "-"

di in gr "A total of " in ye comb(`S_nz',`type') in gr " combinations of " /*
	*/ in ye "`type'" in gr " regressors from the Z(nx" in ye `S_nz' /*
	*/ in gr ") vector were used."


global S_E_mino	`min_obs'
global S_E_mano	`min_obs'
global S_E_dv		"`depvar'"
global S_E_eba		"`ebavar'"
global S_E_min		`min_b'
global S_E_max		`max_b'
global S_E_minp	`min_p'
global S_E_maxp	`max_p'

end
