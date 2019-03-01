package main

import (
	"fmt"
	"math"
)

const (
	P_NOM = 0.8
	SLA = 1.0 // set point of the system
	A = 0.5 // value from 0 to 1 to change how the control is conservative
	A1_NOM = 0.1963
	A2_NOM = 0.002
	A3_NOM = 0.5658
	CORE_MIN = 1.0
	CORE_MAX = 2.0
)

var (
	uiOld = 0.0
)

func main() {
	// test variables
	requests := 80.7
	respTime := 5.2

	req := float64(requests) // active requests + queue of requests
	rt := respTime // mean of the response times
	err := SLA/1000 - rt/1000
	ke := (A-1)/(P_NOM-1)*err
	ui := uiOld+(1-P_NOM)*ke
	ut := ui+ke

  core := req*(ut-A1_NOM-1000.0*A2_NOM)/(1000.0*A3_NOM*(A1_NOM-ut))

  approxCore := math.Min(math.Max(math.Abs(core), CORE_MIN), CORE_MAX) // TODO: transform in millicpu

  approxUt := ((1000.0*A2_NOM+A1_NOM)*req+1000.0*A1_NOM*A3_NOM*approxCore)/(req+1000.0*A3_NOM*approxCore)

  fmt.Println("Current rt: ", rt,
       "\nCurrent users: ", req,
       "\nSLA is set to: ", SLA,
       "\nError is: ", err,
       "\nke is: ", ke,
       "\nUi, UiOld, Utilde and approxUtilde are: ", ui, uiOld, ut, approxUt,
       "\nCore and approxCore are: ", core, approxCore)

  uiOld = approxUt-ke

//  return approxCore
}