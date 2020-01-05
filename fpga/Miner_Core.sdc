# 50MHz clock input (XTAL)
create_clock -period 20.000 -name xtal_osc xtal_osc

derive_pll_clocks
derive_clock_uncertainty

